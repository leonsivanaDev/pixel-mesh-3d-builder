@tool
class_name PixelMeshGenerator
extends RefCounted

const FACE_DEFS = {
	"top": {
		"normal": Vector3(0, 1, 0),
		"verts": [Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 1, 0), Vector3(0, 1, 0)],
		"dir": Vector3i(0, 1, 0),
		"shade": 1.0
	},
	"front": {
		"normal": Vector3(0, 0, 1),
		"verts": [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(0, 1, 1)],
		"dir": Vector3i(0, 0, 1),
		"shade": 0.92
	},
	"right": {
		"normal": Vector3(1, 0, 0),
		"verts": [Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(1, 1, 1)],
		"dir": Vector3i(1, 0, 0),
		"shade": 0.82
	},
	"left": {
		"normal": Vector3(-1, 0, 0),
		"verts": [Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(0, 1, 0)],
		"dir": Vector3i(-1, 0, 0),
		"shade": 0.75
	},
	"back": {
		"normal": Vector3(0, 0, -1),
		"verts": [Vector3(1, 0, 0), Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(1, 1, 0)],
		"dir": Vector3i(0, 0, -1),
		"shade": 0.70
	},
	"bottom": {
		"normal": Vector3(0, -1, 0),
		"verts": [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 1), Vector3(0, 0, 1)],
		"dir": Vector3i(0, -1, 0),
		"shade": 0.55
	}
}

static func generate_mesh(
	pixels: Dictionary,
	grid_size: Vector2i,
	global_depth: int = 1,
	voxel_size: float = 0.1,
	center_xz: bool = true,
	ground_y: bool = true,
	cull_faces: bool = true,
	use_face_shading: bool = true,
	symmetric_depth: bool = true,
	use_greedy_meshing: bool = true
) -> ArrayMesh:
	if pixels.is_empty():
		return null

	var voxels: Dictionary = {}
	var min_pos = Vector3i(999999, 999999, 999999)
	var max_pos = Vector3i(-999999, -999999, -999999)

	for p_coord in pixels.keys():
		var cell_data = pixels[p_coord]
		var col: Color = Color.WHITE
		var depth: int = global_depth

		if cell_data is Dictionary:
			col = cell_data.get("color", Color.WHITE)
			depth = cell_data.get("depth", global_depth)
		elif cell_data is Color:
			col = cell_data
			depth = global_depth

		col.a = 1.0

		var vy: int = (grid_size.y - 1 - p_coord.y)
		var vx: int = p_coord.x

		var z_start: int = -int(depth / 2) if symmetric_depth else 0
		var z_end: int = z_start + depth

		for vz in range(z_start, z_end):
			var vpos = Vector3i(vx, vy, vz)
			voxels[vpos] = col
			min_pos.x = mini(min_pos.x, vx)
			min_pos.y = mini(min_pos.y, vy)
			min_pos.z = mini(min_pos.z, vz)
			max_pos.x = maxi(max_pos.x, vx)
			max_pos.y = maxi(max_pos.y, vy)
			max_pos.z = maxi(max_pos.z, vz)

	if voxels.is_empty():
		return null

	var offset = Vector3.ZERO
	if center_xz:
		offset.x = (float(min_pos.x + max_pos.x + 1)) * 0.5
		offset.z = (float(min_pos.z + max_pos.z + 1)) * 0.5
	if ground_y:
		offset.y = float(min_pos.y)
	else:
		offset.y = (float(min_pos.y + max_pos.y + 1)) * 0.5

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.metallic_specular = 0.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	st.set_material(mat)

	if use_greedy_meshing and cull_faces:
		_build_greedy_mesh(st, voxels, offset, voxel_size, use_face_shading)
	else:
		_build_standard_mesh(st, voxels, offset, voxel_size, cull_faces, use_face_shading)

	var mesh = st.commit()
	if mesh and mesh.get_surface_count() > 0:
		mesh.surface_set_material(0, mat)
	return mesh

static func _build_standard_mesh(
	st: SurfaceTool,
	voxels: Dictionary,
	offset: Vector3,
	voxel_size: float,
	cull_faces: bool,
	use_face_shading: bool
) -> void:
	for vpos in voxels.keys():
		var col: Color = voxels[vpos]
		var base_pos = (Vector3(vpos.x, vpos.y, vpos.z) - offset) * voxel_size

		for face_key in FACE_DEFS:
			var face_info = FACE_DEFS[face_key]
			var neighbor_pos = vpos + face_info["dir"]

			if cull_faces and voxels.has(neighbor_pos):
				continue

			var fnorm: Vector3 = face_info["normal"]
			var fverts: Array = face_info["verts"]
			var shade: float = face_info["shade"] if use_face_shading else 1.0
			var shaded_col = Color(
				clampf(col.r * shade, 0.0, 1.0),
				clampf(col.g * shade, 0.0, 1.0),
				clampf(col.b * shade, 0.0, 1.0),
				1.0
			)

			var p0: Vector3 = base_pos + (fverts[0] * voxel_size)
			var p1: Vector3 = base_pos + (fverts[1] * voxel_size)
			var p2: Vector3 = base_pos + (fverts[2] * voxel_size)
			var p3: Vector3 = base_pos + (fverts[3] * voxel_size)

			_add_quad(st, p0, p1, p2, p3, fnorm, shaded_col)

static func _build_greedy_mesh(
	st: SurfaceTool,
	voxels: Dictionary,
	offset: Vector3,
	voxel_size: float,
	use_face_shading: bool
) -> void:
	for face_key in FACE_DEFS:
		var face_info = FACE_DEFS[face_key]
		var fnorm: Vector3 = face_info["normal"]
		var fdir: Vector3i = face_info["dir"]
		var shade: float = face_info["shade"] if use_face_shading else 1.0

		var slices: Dictionary = {}

		for vpos in voxels.keys():
			var neighbor = vpos + fdir
			if voxels.has(neighbor):
				continue

			var col: Color = voxels[vpos]
			var shaded_col = Color(
				clampf(col.r * shade, 0.0, 1.0),
				clampf(col.g * shade, 0.0, 1.0),
				clampf(col.b * shade, 0.0, 1.0),
				1.0
			)

			var plane_val: int = 0
			var uv = Vector2i.ZERO

			match face_key:
				"top", "bottom":
					plane_val = vpos.y
					uv = Vector2i(vpos.x, vpos.z)
				"front", "back":
					plane_val = vpos.z
					uv = Vector2i(vpos.x, vpos.y)
				"right", "left":
					plane_val = vpos.x
					uv = Vector2i(vpos.z, vpos.y)

			if not slices.has(plane_val):
				slices[plane_val] = {}
			slices[plane_val][uv] = shaded_col

		for plane_val in slices.keys():
			var cell_map: Dictionary = slices[plane_val]
			var visited: Dictionary = {}

			for uv in cell_map.keys():
				if visited.has(uv):
					continue

				var cell_col: Color = cell_map[uv]

				var w = 1
				while cell_map.has(Vector2i(uv.x + w, uv.y)) and not visited.has(Vector2i(uv.x + w, uv.y)) and cell_map[Vector2i(uv.x + w, uv.y)] == cell_col:
					w += 1

				var h = 1
				var can_expand_h = true
				while can_expand_h:
					var next_v = uv.y + h
					for check_u in range(uv.x, uv.x + w):
						var check_uv = Vector2i(check_u, next_v)
						if not cell_map.has(check_uv) or visited.has(check_uv) or cell_map[check_uv] != cell_col:
							can_expand_h = false
							break
					if can_expand_h:
						h += 1

				for row in range(uv.y, uv.y + h):
					for col_idx in range(uv.x, uv.x + w):
						visited[Vector2i(col_idx, row)] = true

				_emit_greedy_quad(st, face_key, plane_val, uv.x, uv.y, w, h, offset, voxel_size, fnorm, cell_col)

static func _emit_greedy_quad(
	st: SurfaceTool,
	face_key: String,
	plane_val: int,
	u: int,
	v: int,
	w: int,
	h: int,
	offset: Vector3,
	voxel_size: float,
	fnorm: Vector3,
	col: Color
) -> void:
	var p0 = Vector3.ZERO
	var p1 = Vector3.ZERO
	var p2 = Vector3.ZERO
	var p3 = Vector3.ZERO

	match face_key:
		"top":
			var y_pos = float(plane_val + 1)
			p0 = Vector3(u, y_pos, v + h)
			p1 = Vector3(u + w, y_pos, v + h)
			p2 = Vector3(u + w, y_pos, v)
			p3 = Vector3(u, y_pos, v)
		"bottom":
			var y_pos = float(plane_val)
			p0 = Vector3(u, y_pos, v)
			p1 = Vector3(u + w, y_pos, v)
			p2 = Vector3(u + w, y_pos, v + h)
			p3 = Vector3(u, y_pos, v + h)
		"front":
			var z_pos = float(plane_val + 1)
			p0 = Vector3(u, v, z_pos)
			p1 = Vector3(u + w, v, z_pos)
			p2 = Vector3(u + w, v + h, z_pos)
			p3 = Vector3(u, v + h, z_pos)
		"back":
			var z_pos = float(plane_val)
			p0 = Vector3(u + w, v, z_pos)
			p1 = Vector3(u, v, z_pos)
			p2 = Vector3(u, v + h, z_pos)
			p3 = Vector3(u + w, v + h, z_pos)
		"right":
			var x_pos = float(plane_val + 1)
			p0 = Vector3(x_pos, v, u + w)
			p1 = Vector3(x_pos, v, u)
			p2 = Vector3(x_pos, v + h, u)
			p3 = Vector3(x_pos, v + h, u + w)
		"left":
			var x_pos = float(plane_val)
			p0 = Vector3(x_pos, v, u)
			p1 = Vector3(x_pos, v, u + w)
			p2 = Vector3(x_pos, v + h, u + w)
			p3 = Vector3(x_pos, v + h, u)

	p0 = (p0 - offset) * voxel_size
	p1 = (p1 - offset) * voxel_size
	p2 = (p2 - offset) * voxel_size
	p3 = (p3 - offset) * voxel_size

	_add_quad(st, p0, p1, p2, p3, fnorm, col)

static func _add_quad(st: SurfaceTool, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, normal: Vector3, col: Color) -> void:
	st.set_normal(normal)
	st.set_color(col)
	st.set_uv(Vector2(0, 1))
	st.add_vertex(p0)

	st.set_normal(normal)
	st.set_color(col)
	st.set_uv(Vector2(1, 1))
	st.add_vertex(p1)

	st.set_normal(normal)
	st.set_color(col)
	st.set_uv(Vector2(1, 0))
	st.add_vertex(p2)

	st.set_normal(normal)
	st.set_color(col)
	st.set_uv(Vector2(0, 1))
	st.add_vertex(p0)

	st.set_normal(normal)
	st.set_color(col)
	st.set_uv(Vector2(1, 0))
	st.add_vertex(p2)

	st.set_normal(normal)
	st.set_color(col)
	st.set_uv(Vector2(0, 0))
	st.add_vertex(p3)

static func create_collision_shape(mesh: ArrayMesh, shape_type: String) -> Shape3D:
	if mesh == null:
		return null
	match shape_type:
		"Box":
			var aabb: AABB = mesh.get_aabb()
			var box = BoxShape3D.new()
			box.size = aabb.size
			return box
		"Convex":
			return mesh.create_convex_shape()
		"Trimesh":
			return mesh.create_trimesh_shape()
	return null

static func export_to_gltf(mesh: ArrayMesh, path: String) -> Error:
	if not mesh:
		return ERR_INVALID_DATA
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	var node = MeshInstance3D.new()
	node.name = "PixelModel"
	node.mesh = mesh
	var err = gltf_doc.append_from_scene(node, gltf_state)
	if err == OK:
		err = gltf_doc.write_to_filesystem(gltf_state, path)
	node.free()
	return err
