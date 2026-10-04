@tool
class_name PixelCanvasControl
extends Control

signal pixel_changed()
signal color_picked(color: Color, depth: int)
signal history_changed(can_undo: bool, can_redo: bool)

enum ToolMode { PENCIL, BUCKET, LINE, RECT, CIRCLE, ERASER, PICKER }

var grid_size: Vector2i = Vector2i(16, 16)
var current_tool: ToolMode = ToolMode.PENCIL
var current_color: Color = Color.BLACK
var current_depth: int = 1

var mirror_x: bool = false
var mirror_y: bool = false

var show_grid: bool = true
var show_depth_numbers: bool = true

var pixels: Dictionary = {}

var undo_stack: Array[Dictionary] = []
var redo_stack: Array[Dictionary] = []
const MAX_UNDO_STEPS: int = 50

var is_mouse_down: bool = false
var active_button: int = 0
var hovered_coord: Vector2i = Vector2i(-1, -1)
var stroke_started: bool = false

var shape_start_coord: Vector2i = Vector2i(-1, -1)
var shape_current_coord: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	custom_minimum_size = Vector2(240, 240)
	mouse_filter = MOUSE_FILTER_PASS
	focus_mode = FOCUS_ALL

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func save_undo_state() -> void:
	undo_stack.append(pixels.duplicate(true))
	if undo_stack.size() > MAX_UNDO_STEPS:
		undo_stack.pop_front()
	redo_stack.clear()
	history_changed.emit(can_undo(), can_redo())

func undo() -> void:
	if not can_undo():
		return
	redo_stack.append(pixels.duplicate(true))
	pixels = undo_stack.pop_back()
	queue_redraw()
	pixel_changed.emit()
	history_changed.emit(can_undo(), can_redo())

func redo() -> void:
	if not can_redo():
		return
	undo_stack.append(pixels.duplicate(true))
	pixels = redo_stack.pop_back()
	queue_redraw()
	pixel_changed.emit()
	history_changed.emit(can_undo(), can_redo())

func can_undo() -> bool:
	return not undo_stack.is_empty()

func can_redo() -> bool:
	return not redo_stack.is_empty()

func set_grid_size(new_size: Vector2i) -> void:
	save_undo_state()
	grid_size = new_size
	var valid_pixels: Dictionary = {}
	for c in pixels.keys():
		if c.x < grid_size.x and c.y < grid_size.y:
			valid_pixels[c] = pixels[c]
	pixels = valid_pixels
	queue_redraw()
	pixel_changed.emit()

func clear_canvas() -> void:
	if pixels.is_empty():
		return
	save_undo_state()
	pixels.clear()
	queue_redraw()
	pixel_changed.emit()

func reset_canvas() -> void:
	pixels.clear()
	undo_stack.clear()
	redo_stack.clear()
	history_changed.emit(false, false)
	queue_redraw()
	pixel_changed.emit()

func load_from_image(image: Image) -> void:
	save_undo_state()
	pixels.clear()
	var w: int = mini(image.get_width(), grid_size.x)
	var h: int = mini(image.get_height(), grid_size.y)
	
	for y in range(h):
		for x in range(w):
			var col: Color = image.get_pixel(x, y)
			if col.a > 0.05:
				col.a = 1.0
				pixels[Vector2i(x, y)] = { "color": col, "depth": 1 }
	queue_redraw()
	pixel_changed.emit()

func export_data() -> Dictionary:
	var px_list: Array = []
	for coord in pixels.keys():
		var p = pixels[coord]
		var col: Color = p.get("color", Color.WHITE)
		px_list.append({
			"x": coord.x,
			"y": coord.y,
			"color": col.to_html(false),
			"depth": p.get("depth", 1)
		})
	return {
		"grid_size_x": grid_size.x,
		"grid_size_y": grid_size.y,
		"pixels": px_list
	}

func import_data(data: Dictionary) -> void:
	save_undo_state()
	var gx = int(data.get("grid_size_x", 16))
	var gy = int(data.get("grid_size_y", 16))
	grid_size = Vector2i(gx, gy)
	pixels.clear()
	var px_list = data.get("pixels", [])
	for item in px_list:
		var coord = Vector2i(int(item.get("x", 0)), int(item.get("y", 0)))
		var col = Color.from_string(str(item.get("color", "ffffff")), Color.WHITE)
		var dep = int(item.get("depth", 1))
		pixels[coord] = { "color": col, "depth": dep }
	queue_redraw()
	pixel_changed.emit()

func get_cell_size() -> float:
	var avail_w = size.x
	var avail_h = size.y
	return minf(avail_w / float(grid_size.x), avail_h / float(grid_size.y))

func get_grid_rect() -> Rect2:
	var cs = get_cell_size()
	var w = cs * grid_size.x
	var h = cs * grid_size.y
	var ox = (size.x - w) * 0.5
	var oy = (size.y - h) * 0.5
	return Rect2(ox, oy, w, h)

func pos_to_grid(pos: Vector2) -> Vector2i:
	var grect = get_grid_rect()
	if not grect.has_point(pos):
		return Vector2i(-1, -1)
	var cs = get_cell_size()
	if cs <= 0.0:
		return Vector2i(-1, -1)
	var gx = int((pos.x - grect.position.x) / cs)
	var gy = int((pos.y - grect.position.y) / cs)
	return Vector2i(clampi(gx, 0, grid_size.x - 1), clampi(gy, 0, grid_size.y - 1))

func _get_symmetric_coords(coord: Vector2i) -> Array[Vector2i]:
	var list: Array[Vector2i] = [coord]
	var mx = grid_size.x - 1 - coord.x
	var my = grid_size.y - 1 - coord.y

	if mirror_x and mx != coord.x:
		list.append(Vector2i(mx, coord.y))
	if mirror_y and my != coord.y:
		list.append(Vector2i(coord.x, my))
	if mirror_x and mirror_y and mx != coord.x and my != coord.y:
		list.append(Vector2i(mx, my))
	return list

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var key = event as InputEventKey
		if key.ctrl_pressed:
			if key.keycode == KEY_Z:
				if key.shift_pressed:
					redo()
				else:
					undo()
				accept_event()
				return
			elif key.keycode == KEY_Y:
				redo()
				accept_event()
				return

	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.pressed:
			grab_focus()
			is_mouse_down = true
			active_button = mb.button_index
			stroke_started = false
			var coord = pos_to_grid(mb.position)
			if coord.x >= 0 and coord.y >= 0:
				if is_shape_tool():
					shape_start_coord = coord
					shape_current_coord = coord
					queue_redraw()
				elif current_tool == ToolMode.PICKER:
					apply_tool(coord, mb.button_index)
				else:
					save_undo_state()
					stroke_started = true
					apply_tool(coord, mb.button_index)
		else:
			if is_shape_tool() and is_mouse_down and shape_start_coord.x >= 0 and shape_current_coord.x >= 0:
				commit_shape(active_button)
				shape_start_coord = Vector2i(-1, -1)
				shape_current_coord = Vector2i(-1, -1)
			is_mouse_down = false
			active_button = 0
			stroke_started = false
			queue_redraw()

	elif event is InputEventMouseMotion:
		var mm = event as InputEventMouseMotion
		var coord = pos_to_grid(mm.position)
		if coord != hovered_coord:
			hovered_coord = coord
			queue_redraw()
		if is_mouse_down and coord.x >= 0 and coord.y >= 0:
			if is_shape_tool():
				shape_current_coord = coord
				queue_redraw()
			elif current_tool == ToolMode.PICKER:
				apply_tool(coord, active_button)
			else:
				apply_tool(coord, active_button)

func is_shape_tool() -> bool:
	return current_tool == ToolMode.LINE or current_tool == ToolMode.RECT or current_tool == ToolMode.CIRCLE

func apply_tool(coord: Vector2i, button: int) -> void:
	if current_tool == ToolMode.PICKER:
		if pixels.has(coord):
			var data = pixels[coord]
			current_color = data["color"]
			current_depth = data["depth"]
			color_picked.emit(current_color, current_depth)
		return

	if button == MOUSE_BUTTON_RIGHT or current_tool == ToolMode.ERASER:
		erase_pixel(coord)
	elif button == MOUSE_BUTTON_LEFT:
		match current_tool:
			ToolMode.PENCIL:
				paint_pixel(coord, current_color, current_depth)
			ToolMode.BUCKET:
				flood_fill(coord, current_color, current_depth)

func commit_shape(button: int) -> void:
	if shape_start_coord.x < 0 or shape_current_coord.x < 0:
		return
	save_undo_state()
	var coords = get_shape_coords(shape_start_coord, shape_current_coord)
	var is_erase = (button == MOUSE_BUTTON_RIGHT)
	for c in coords:
		if is_erase:
			for sc in _get_symmetric_coords(c):
				pixels.erase(sc)
		else:
			var solid_col = Color(current_color.r, current_color.g, current_color.b, 1.0)
			var cell_data = { "color": solid_col, "depth": current_depth }
			for sc in _get_symmetric_coords(c):
				pixels[sc] = cell_data

	queue_redraw()
	pixel_changed.emit()

func get_shape_coords(p1: Vector2i, p2: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	match current_tool:
		ToolMode.LINE:
			result = get_line_coords(p1, p2)
		ToolMode.RECT:
			result = get_rect_coords(p1, p2)
		ToolMode.CIRCLE:
			result = get_circle_coords(p1, p2)
	return result

func get_line_coords(p1: Vector2i, p2: Vector2i) -> Array[Vector2i]:
	var list: Array[Vector2i] = []
	var x0 = p1.x
	var y0 = p1.y
	var x1 = p2.x
	var y1 = p2.y
	var dx = absi(x1 - x0)
	var dy = -absi(y1 - y0)
	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1
	var err = dx + dy

	while true:
		if x0 >= 0 and x0 < grid_size.x and y0 >= 0 and y0 < grid_size.y:
			list.append(Vector2i(x0, y0))
		if x0 == x1 and y0 == y1:
			break
		var e2 = 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy
	return list

func get_rect_coords(p1: Vector2i, p2: Vector2i) -> Array[Vector2i]:
	var list: Array[Vector2i] = []
	var min_x = mini(p1.x, p2.x)
	var max_x = maxi(p1.x, p2.x)
	var min_y = mini(p1.y, p2.y)
	var max_y = maxi(p1.y, p2.y)

	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if x == min_x or x == max_x or y == min_y or y == max_y:
				if x >= 0 and x < grid_size.x and y >= 0 and y < grid_size.y:
					list.append(Vector2i(x, y))
	return list

func get_circle_coords(p1: Vector2i, p2: Vector2i) -> Array[Vector2i]:
	var list: Array[Vector2i] = []
	var x0 = mini(p1.x, p2.x)
	var x1 = maxi(p1.x, p2.x)
	var y0 = mini(p1.y, p2.y)
	var y1 = maxi(p1.y, p2.y)

	var a = absi(x1 - x0)
	var b = absi(y1 - y0)
	var b1 = b & 1

	if a == 0 and b == 0:
		if x0 >= 0 and x0 < grid_size.x and y0 >= 0 and y0 < grid_size.y:
			list.append(Vector2i(x0, y0))
		return list

	if a == 0:
		for y in range(y0, y1 + 1):
			if x0 >= 0 and x0 < grid_size.x and y >= 0 and y < grid_size.y:
				list.append(Vector2i(x0, y))
		return list

	if b == 0:
		for x in range(x0, x1 + 1):
			if x >= 0 and x < grid_size.x and y0 >= 0 and y0 < grid_size.y:
				list.append(Vector2i(x, y0))
		return list

	var dx: int = 4 * (1 - a) * b * b
	var dy: int = 4 * (b1 + 1) * a * a
	var err: int = dx + dy + b1 * a * a
	var e2: int = 0

	y0 += (b + 1) / 2
	y1 = y0 - b1
	a = 8 * a * a
	b1 = 8 * b * b

	var add_pt = func(pt: Vector2i):
		if pt.x >= 0 and pt.x < grid_size.x and pt.y >= 0 and pt.y < grid_size.y:
			if not list.has(pt):
				list.append(pt)

	while x0 <= x1:
		add_pt.call(Vector2i(x1, y0))
		add_pt.call(Vector2i(x0, y0))
		add_pt.call(Vector2i(x0, y1))
		add_pt.call(Vector2i(x1, y1))

		e2 = 2 * err
		if e2 <= dy:
			y0 += 1
			y1 -= 1
			dy += a
			err += dy
		if e2 >= dx or 2 * err > dy:
			x0 += 1
			x1 -= 1
			dx += b1
			err += dx

	while y0 - y1 <= b:
		add_pt.call(Vector2i(x0 - 1, y0))
		add_pt.call(Vector2i(x1 + 1, y0))
		y0 += 1
		add_pt.call(Vector2i(x0 - 1, y1))
		add_pt.call(Vector2i(x1 + 1, y1))
		y1 -= 1

	return list

func paint_pixel(coord: Vector2i, col: Color, depth: int) -> void:
	var solid_col = Color(col.r, col.g, col.b, 1.0)
	var cell_data = { "color": solid_col, "depth": depth }
	
	for sc in _get_symmetric_coords(coord):
		pixels[sc] = cell_data

	queue_redraw()
	pixel_changed.emit()

func erase_pixel(coord: Vector2i) -> void:
	for sc in _get_symmetric_coords(coord):
		pixels.erase(sc)
	queue_redraw()
	pixel_changed.emit()

func flood_fill(start_coord: Vector2i, new_col: Color, new_depth: int) -> void:
	var solid_col = Color(new_col.r, new_col.g, new_col.b, 1.0)
	var start_data = pixels.get(start_coord, null)
	var start_col = start_data["color"] if start_data else Color(0, 0, 0, 0)
	var start_d = start_data["depth"] if start_data else 0

	if start_col == solid_col and start_d == new_depth:
		return

	var queue: Array[Vector2i] = [start_coord]
	var visited: Dictionary = {}

	while not queue.is_empty():
		var curr = queue.pop_back()
		if visited.has(curr):
			continue
		visited[curr] = true

		if curr.x < 0 or curr.x >= grid_size.x or curr.y < 0 or curr.y >= grid_size.y:
			continue

		var c_data = pixels.get(curr, null)
		var c_col = c_data["color"] if c_data else Color(0, 0, 0, 0)
		var c_d = c_data["depth"] if c_data else 0

		if c_col == start_col and c_d == start_d:
			for sc in _get_symmetric_coords(curr):
				pixels[sc] = { "color": solid_col, "depth": new_depth }
			queue.append(Vector2i(curr.x + 1, curr.y))
			queue.append(Vector2i(curr.x - 1, curr.y))
			queue.append(Vector2i(curr.x, curr.y + 1))
			queue.append(Vector2i(curr.x, curr.y - 1))

	queue_redraw()
	pixel_changed.emit()

func _draw() -> void:
	var grect = get_grid_rect()
	var cs = get_cell_size()
	if cs <= 0.0:
		return

	draw_rect(grect, Color(1.0, 1.0, 1.0, 1.0))

	var font = ThemeDB.fallback_font
	var font_size = clampi(int(cs * 0.42), 8, 22)

	for coord in pixels.keys():
		var data = pixels[coord]
		var col: Color = data["color"]
		var depth: int = data.get("depth", 1)
		var r = Rect2(grect.position.x + coord.x * cs, grect.position.y + coord.y * cs, cs, cs)

		draw_rect(r, col)

		if show_depth_numbers and cs >= 12.0:
			var lum = col.get_luminance()
			var text_col = Color(0.1, 0.1, 0.1, 0.9) if lum > 0.55 else Color(0.95, 0.95, 0.95, 0.9)
			var text_str = str(depth)
			var text_w = font.get_string_size(text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
			var text_pos = Vector2(
				r.position.x + (cs - text_w) * 0.5,
				r.position.y + (cs * 0.5) + (font_size * 0.35)
			)
			draw_string(font, text_pos, text_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_col)

	if is_shape_tool() and is_mouse_down and shape_start_coord.x >= 0 and shape_current_coord.x >= 0:
		var preview_coords = get_shape_coords(shape_start_coord, shape_current_coord)
		var is_erase = (active_button == MOUSE_BUTTON_RIGHT)
		var preview_col = Color(1.0, 0.2, 0.2, 0.6) if is_erase else Color(current_color.r, current_color.g, current_color.b, 0.7)
		
		for c in preview_coords:
			for sc in _get_symmetric_coords(c):
				var r = Rect2(grect.position.x + sc.x * cs, grect.position.y + sc.y * cs, cs, cs)
				draw_rect(r, preview_col)
				draw_rect(r, Color(0.15, 0.45, 0.9, 0.8), false, 1.0)

	if show_grid and cs >= 3.0:
		var grid_col = Color(0.12, 0.16, 0.24, 0.09)
		for x in range(grid_size.x + 1):
			var px = grect.position.x + x * cs
			draw_line(Vector2(px, grect.position.y), Vector2(px, grect.position.y + grect.size.y), grid_col)
		for y in range(grid_size.y + 1):
			var py = grect.position.y + y * cs
			draw_line(Vector2(grect.position.x, py), Vector2(grect.position.x + grid_size.x * cs, py), grid_col)

	if mirror_x:
		var mid_x = grect.position.x + (grid_size.x * cs * 0.5)
		draw_line(Vector2(mid_x, grect.position.y), Vector2(mid_x, grect.position.y + grect.size.y), Color(0.05, 0.6, 0.95, 0.9), 2.0)

	if mirror_y:
		var mid_y = grect.position.y + (grid_size.y * cs * 0.5)
		draw_line(Vector2(grect.position.x, mid_y), Vector2(grect.position.x + grid_size.x * cs, mid_y), Color(0.95, 0.5, 0.05, 0.9), 2.0)

	draw_rect(grect, Color(0.70, 0.74, 0.80, 1.0), false, 1.5)

	if hovered_coord.x >= 0 and hovered_coord.y >= 0:
		var hr = Rect2(grect.position.x + hovered_coord.x * cs, grect.position.y + hovered_coord.y * cs, cs, cs)
		draw_rect(hr, Color(0.15, 0.45, 0.9, 0.85), false, 1.5)
		
		if mirror_x or mirror_y:
			for sc in _get_symmetric_coords(hovered_coord):
				if sc != hovered_coord:
					var shr = Rect2(grect.position.x + sc.x * cs, grect.position.y + sc.y * cs, cs, cs)
					draw_rect(shr, Color(0.2, 0.65, 0.95, 0.65), false, 1.5)
