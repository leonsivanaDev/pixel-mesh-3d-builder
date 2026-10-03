@tool
class_name PixelPreview3D
extends SubViewportContainer

@onready var viewport: SubViewport = $SubViewport
@onready var camera_pivot: Node3D = $SubViewport/CameraPivot
@onready var camera: Camera3D = $SubViewport/CameraPivot/Camera3D
@onready var mesh_instance: MeshInstance3D = $SubViewport/PreviewMesh
@onready var world_env: WorldEnvironment = $SubViewport/WorldEnvironment
@onready var dir_light: DirectionalLight3D = $SubViewport/DirLight
@onready var fill_light: DirectionalLight3D = $SubViewport/FillLight
@onready var grid_floor: MeshInstance3D = $SubViewport/GridFloor

var auto_rotate: bool = false
var is_dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var base_view_size: float = 2.6
var is_orthogonal: bool = true
var camera_initialized: bool = false

func _ready() -> void:
	stretch = true
	mouse_filter = MOUSE_FILTER_STOP
	setup_viewport_world()

func setup_viewport_world() -> void:
	if not viewport:
		return
	viewport.own_world_3d = true

	if camera:
		camera.current = true
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = base_view_size
		camera.position = Vector3(0, 0, 8.0)
		camera_pivot.position = Vector3(0, 0.4, 0)
		camera_pivot.rotation_degrees = Vector3(-25, 35, 0)
		camera_initialized = true

	if world_env:
		var env = Environment.new()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.11, 0.115, 0.135)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.5, 0.52, 0.58)
		env.ambient_light_energy = 1.0
		world_env.environment = env

	if grid_floor and not grid_floor.mesh:
		var plane = PlaneMesh.new()
		plane.size = Vector2(2.4, 2.4)
		var pmat = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.16, 0.17, 0.20, 0.8)
		pmat.roughness = 0.9
		grid_floor.mesh = plane
		grid_floor.position = Vector3(0, -0.01, 0)

func set_camera_projection(ortho: bool) -> void:
	is_orthogonal = ortho
	if not camera:
		return
	if ortho:
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = base_view_size
		camera.position = Vector3(0, 0, 8.0)
	else:
		camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		camera.fov = 35.0
		camera.position = Vector3(0, 0, base_view_size * 1.8)

func _process(delta: float) -> void:
	if auto_rotate and not is_dragging and camera_pivot:
		camera_pivot.rotation.y += delta * 0.75

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT or mb.button_index == MOUSE_BUTTON_RIGHT or mb.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = mb.pressed
			last_mouse_pos = mb.position
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(0.9)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(1.1)

	elif event is InputEventMouseMotion and is_dragging and camera_pivot:
		var mm = event as InputEventMouseMotion
		var delta_pos = mm.position - last_mouse_pos
		last_mouse_pos = mm.position

		camera_pivot.rotation.y -= delta_pos.x * 0.01
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - delta_pos.y * 0.01, -PI * 0.48, PI * 0.48)

func zoom_camera(factor: float) -> void:
	if not camera:
		return
	if is_orthogonal:
		camera.size = clampf(camera.size * factor, 0.5, 15.0)
		base_view_size = camera.size
	else:
		camera.position.z = clampf(camera.position.z * factor, 0.8, 25.0)

func set_mesh(mesh: ArrayMesh) -> void:
	if not mesh_instance:
		mesh_instance = get_node_or_null("SubViewport/PreviewMesh")
	if not mesh_instance:
		return
	if mesh and mesh.get_surface_count() > 0:
		mesh_instance.mesh = mesh
		mesh_instance.visible = true
	else:
		mesh_instance.visible = false

func update_mesh(mesh: ArrayMesh) -> void:
	set_mesh(mesh)

func reset_camera() -> void:
	if camera_pivot and camera:
		camera_pivot.rotation_degrees = Vector3(-25, 35, 0)
		camera_pivot.position = Vector3(0, 0.4, 0)
		base_view_size = 2.6
		if is_orthogonal:
			camera.size = base_view_size
			camera.position = Vector3(0, 0, 8.0)
		else:
			camera.position = Vector3(0, 0, 4.5)
