@tool
class_name SegmentedButtonGroup
extends PanelContainer

signal selection_changed(index: int, button: Button)

enum Mode {
	RADIO,
	TOGGLE,
	ACTION
}

@export var mode: Mode = Mode.RADIO:
	set(val):
		mode = val
		_update_styles()

@export var is_vertical: bool = false:
	set(val):
		is_vertical = val
		_rebuild_layout()

@export var is_action_group: bool = false:
	set(val):
		is_action_group = val
		if val:
			mode = Mode.ACTION
		_update_styles()

@export var is_toggle_group: bool = false:
	set(val):
		is_toggle_group = val
		if val:
			mode = Mode.TOGGLE
		_update_styles()

@export var accent_color: Color = Color("#2563eb"):
	set(val):
		accent_color = val
		_update_styles()

@export var active_text_color: Color = Color("#ffffff"):
	set(val):
		active_text_color = val
		_update_styles()

@export var inactive_text_color: Color = Color("#94a3b8"):
	set(val):
		inactive_text_color = val
		_update_styles()

@export var track_color: Color = Color("#12141a"):
	set(val):
		track_color = val
		_update_styles()

@export var border_color: Color = Color("#222733"):
	set(val):
		border_color = val
		_update_styles()

@export var divider_color: Color = Color("#2a303f"):
	set(val):
		divider_color = val
		queue_redraw()

@export var corner_radius: int = 7:
	set(val):
		corner_radius = val
		_update_styles()

@export var pill_radius: int = 5:
	set(val):
		pill_radius = val
		_update_styles()

@export var pill_padding: int = 2:
	set(val):
		pill_padding = val
		_update_styles()

@export var button_content_margin: int = 6:
	set(val):
		button_content_margin = val
		button_content_margin_x = val
		button_content_margin_y = val
		_update_styles()

@export var button_content_margin_x: int = 8:
	set(val):
		button_content_margin_x = val
		_update_styles()

@export var button_content_margin_y: int = 6:
	set(val):
		button_content_margin_y = val
		_update_styles()

@export var icon_max_width: int = 16:
	set(val):
		icon_max_width = val
		_update_styles()

var button_group: ButtonGroup
var box_container: BoxContainer
var buttons: Array[Button] = []

var _style_track: StyleBoxFlat
var _style_active: StyleBoxFlat
var _style_inactive_normal: StyleBoxFlat
var _style_inactive_hover: StyleBoxFlat
var _style_disabled: StyleBoxEmpty

func _init() -> void:
	button_group = ButtonGroup.new()
	button_group.allow_unpress = false
	button_group.pressed.connect(_on_group_button_pressed)
	_setup_internal_container()
	_update_styles()

func _ready() -> void:
	_setup_internal_container()
	_update_styles()
	_collect_initial_buttons()

func _setup_internal_container() -> void:
	if box_container and is_instance_valid(box_container):
		return
	
	if is_vertical:
		box_container = VBoxContainer.new()
	else:
		box_container = HBoxContainer.new()
	
	box_container.name = "BoxContainer"
	box_container.set("theme_override_constants/separation", 0)
	box_container.size_flags_horizontal = SIZE_EXPAND_FILL
	box_container.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(box_container)

func _rebuild_layout() -> void:
	if not box_container or not is_instance_valid(box_container):
		return
	var existing_btns = buttons.duplicate()
	for b in existing_btns:
		if b.get_parent() == box_container:
			box_container.remove_child(b)
	box_container.queue_free()
	box_container = null
	_setup_internal_container()
	buttons.clear()
	for b in existing_btns:
		register_button(b)

func _collect_initial_buttons() -> void:
	for child in get_children():
		if child is Button and child != box_container:
			remove_child(child)
			register_button(child)

func _update_styles() -> void:
	_style_track = StyleBoxFlat.new()
	_style_track.bg_color = track_color
	_style_track.border_color = border_color
	_style_track.set_border_width_all(1)
	_style_track.set_corner_radius_all(corner_radius)
	_style_track.set_content_margin_all(pill_padding)
	add_theme_stylebox_override("panel", _style_track)

	_style_active = StyleBoxFlat.new()
	_style_active.bg_color = accent_color
	_style_active.border_color = Color(accent_color.r * 1.35, accent_color.g * 1.35, accent_color.b * 1.35, 1.0)
	_style_active.set_border_width_all(1)
	_style_active.set_corner_radius_all(pill_radius)
	_style_active.content_margin_left = button_content_margin_x
	_style_active.content_margin_right = button_content_margin_x
	_style_active.content_margin_top = button_content_margin_y
	_style_active.content_margin_bottom = button_content_margin_y

	_style_inactive_normal = StyleBoxFlat.new()
	_style_inactive_normal.bg_color = Color.TRANSPARENT
	_style_inactive_normal.set_corner_radius_all(pill_radius)
	_style_inactive_normal.content_margin_left = button_content_margin_x
	_style_inactive_normal.content_margin_right = button_content_margin_x
	_style_inactive_normal.content_margin_top = button_content_margin_y
	_style_inactive_normal.content_margin_bottom = button_content_margin_y

	_style_inactive_hover = StyleBoxFlat.new()
	_style_inactive_hover.bg_color = Color(0.18, 0.21, 0.28, 0.65)
	_style_inactive_hover.set_corner_radius_all(pill_radius)
	_style_inactive_hover.content_margin_left = button_content_margin_x
	_style_inactive_hover.content_margin_right = button_content_margin_x
	_style_inactive_hover.content_margin_top = button_content_margin_y
	_style_inactive_hover.content_margin_bottom = button_content_margin_y

	_style_disabled = StyleBoxEmpty.new()

	for b in buttons:
		_apply_button_theme(b)
	queue_redraw()

func _apply_button_theme(btn: Button) -> void:
	if not btn or not is_instance_valid(btn):
		return
	
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_stylebox_override("disabled", _style_disabled)
	btn.add_theme_color_override("font_disabled_color", Color(inactive_text_color.r, inactive_text_color.g, inactive_text_color.b, 0.35))
	btn.add_theme_color_override("icon_disabled_color", Color(inactive_text_color.r, inactive_text_color.g, inactive_text_color.b, 0.35))

	btn.expand_icon = true
	if btn.text.is_empty():
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.add_theme_constant_override("h_separation", 6)
	btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	if icon_max_width > 0:
		btn.add_theme_constant_override("icon_max_width", icon_max_width)

	if mode == Mode.ACTION:
		btn.toggle_mode = false
		btn.button_group = null
		btn.add_theme_stylebox_override("normal", _style_inactive_normal)
		btn.add_theme_stylebox_override("hover", _style_inactive_hover)
		btn.add_theme_stylebox_override("pressed", _style_active)
		btn.add_theme_stylebox_override("hover_pressed", _style_active)
		btn.add_theme_color_override("font_color", inactive_text_color)
		btn.add_theme_color_override("font_hover_color", active_text_color)
		btn.add_theme_color_override("font_pressed_color", active_text_color)
		btn.add_theme_color_override("icon_normal_color", inactive_text_color)
		btn.add_theme_color_override("icon_hover_color", active_text_color)
		btn.add_theme_color_override("icon_pressed_color", active_text_color)
	elif mode == Mode.RADIO:
		btn.toggle_mode = true
		btn.button_group = button_group
		btn.add_theme_stylebox_override("pressed", _style_active)
		btn.add_theme_stylebox_override("hover_pressed", _style_active)
		if btn.button_pressed:
			btn.add_theme_stylebox_override("normal", _style_active)
			btn.add_theme_stylebox_override("hover", _style_active)
			btn.add_theme_color_override("font_color", active_text_color)
			btn.add_theme_color_override("font_hover_color", active_text_color)
			btn.add_theme_color_override("font_pressed_color", active_text_color)
			btn.add_theme_color_override("font_hover_pressed_color", active_text_color)
			btn.add_theme_color_override("icon_normal_color", active_text_color)
			btn.add_theme_color_override("icon_hover_color", active_text_color)
			btn.add_theme_color_override("icon_pressed_color", active_text_color)
			btn.add_theme_color_override("icon_hover_pressed_color", active_text_color)
		else:
			btn.add_theme_stylebox_override("normal", _style_inactive_normal)
			btn.add_theme_stylebox_override("hover", _style_inactive_hover)
			btn.add_theme_color_override("font_color", inactive_text_color)
			btn.add_theme_color_override("font_hover_color", active_text_color)
			btn.add_theme_color_override("font_pressed_color", active_text_color)
			btn.add_theme_color_override("icon_normal_color", inactive_text_color)
			btn.add_theme_color_override("icon_hover_color", active_text_color)
			btn.add_theme_color_override("icon_pressed_color", active_text_color)
	elif mode == Mode.TOGGLE:
		btn.button_group = null
		btn.add_theme_stylebox_override("pressed", _style_active)
		btn.add_theme_stylebox_override("hover_pressed", _style_active)
		if btn.toggle_mode and btn.button_pressed:
			btn.add_theme_stylebox_override("normal", _style_active)
			btn.add_theme_stylebox_override("hover", _style_active)
			btn.add_theme_color_override("font_color", active_text_color)
			btn.add_theme_color_override("font_hover_color", active_text_color)
			btn.add_theme_color_override("font_pressed_color", active_text_color)
			btn.add_theme_color_override("font_hover_pressed_color", active_text_color)
			btn.add_theme_color_override("icon_normal_color", active_text_color)
			btn.add_theme_color_override("icon_hover_color", active_text_color)
			btn.add_theme_color_override("icon_pressed_color", active_text_color)
			btn.add_theme_color_override("icon_hover_pressed_color", active_text_color)
		else:
			btn.add_theme_stylebox_override("normal", _style_inactive_normal)
			btn.add_theme_stylebox_override("hover", _style_inactive_hover)
			btn.add_theme_color_override("font_color", inactive_text_color)
			btn.add_theme_color_override("font_hover_color", active_text_color)
			btn.add_theme_color_override("font_pressed_color", active_text_color)
			btn.add_theme_color_override("icon_normal_color", inactive_text_color)
			btn.add_theme_color_override("icon_hover_color", active_text_color)
			btn.add_theme_color_override("icon_pressed_color", active_text_color)

func register_button(btn: Button) -> void:
	if not btn:
		return
	if not box_container or not is_instance_valid(box_container):
		_setup_internal_container()
	if btn.get_parent() != box_container:
		if btn.get_parent():
			btn.reparent(box_container, false)
		else:
			box_container.add_child(btn)
	
	if not buttons.has(btn):
		buttons.append(btn)
	
	_apply_button_theme(btn)
	
	if not btn.toggled.is_connected(_on_button_toggled):
		btn.toggled.connect(func(_val): _on_button_toggled(btn))
	if not btn.pressed.is_connected(_on_button_pressed_internal):
		btn.pressed.connect(func(): _on_button_pressed_internal(btn))

func add_item(text: String, icon: Texture2D = null, tooltip: String = "") -> Button:
	var btn = Button.new()
	btn.text = text
	btn.icon = icon
	btn.tooltip_text = tooltip
	btn.expand_icon = true
	if text.is_empty():
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	register_button(btn)
	return btn

func _on_group_button_pressed(btn: BaseButton) -> void:
	if mode != Mode.RADIO:
		return
	var idx = buttons.find(btn as Button)
	if idx >= 0:
		_refresh_all_button_colors()
		selection_changed.emit(idx, btn as Button)
		queue_redraw()

func _on_button_toggled(btn: Button) -> void:
	_apply_button_theme(btn)
	queue_redraw()

func _on_button_pressed_internal(btn: Button) -> void:
	_apply_button_theme(btn)
	queue_redraw()

func _refresh_all_button_colors() -> void:
	for b in buttons:
		_apply_button_theme(b)

func refresh() -> void:
	_refresh_all_button_colors()
	queue_redraw()

func select_index(idx: int) -> void:
	if mode != Mode.RADIO:
		return
	if idx >= 0 and idx < buttons.size():
		buttons[idx].button_pressed = true
		_refresh_all_button_colors()
		queue_redraw()

func get_selected_index() -> int:
	if mode != Mode.RADIO:
		return -1
	for i in range(buttons.size()):
		if buttons[i].button_pressed:
			return i
	return -1

func get_selected_button() -> Button:
	var idx = get_selected_index()
	if idx >= 0:
		return buttons[idx]
	return null

func get_button(idx: int) -> Button:
	if idx >= 0 and idx < buttons.size():
		return buttons[idx]
	return null

func clear() -> void:
	buttons.clear()
	if box_container and is_instance_valid(box_container):
		for child in box_container.get_children():
			child.queue_free()
	queue_redraw()

func _draw() -> void:
	if buttons.size() < 2 or not box_container:
		return
	
	var box_offset = box_container.position
	for i in range(buttons.size() - 1):
		var b1 = buttons[i]
		var b2 = buttons[i + 1]
		if not b1.visible or not b2.visible:
			continue
		if (b1.toggle_mode and b1.button_pressed) or (b2.toggle_mode and b2.button_pressed):
			continue
		
		var b_pos = box_offset + b1.position
		if not is_vertical:
			var x = b_pos.x + b1.size.x
			var y1 = b_pos.y + 4.0
			var y2 = b_pos.y + b1.size.y - 4.0
			draw_line(Vector2(x, y1), Vector2(x, y2), divider_color, 1.0)
		else:
			var y = b_pos.y + b1.size.y
			var x1 = b_pos.x + 4.0
			var x2 = b_pos.x + b1.size.x - 4.0
			draw_line(Vector2(x1, y), Vector2(x2, y), divider_color, 1.0)
