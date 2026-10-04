@tool
extends EditorPlugin

const MAIN_PANEL = preload("res://addons/pixel_mesh_builder/ui/pixel_builder_panel.tscn")
const ICON_PLUGIN = preload("res://addons/pixel_mesh_builder/icons/cube.svg")

var main_panel_instance: Control

func _enter_tree() -> void:
	main_panel_instance = MAIN_PANEL.instantiate()
	main_panel_instance.editor_interface = get_editor_interface()
	main_panel_instance.undo_redo = get_undo_redo()

	main_panel_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_panel_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_panel_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)

func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		main_panel_instance.visible = visible

func _get_plugin_name() -> String:
	return "Pixel 3D"

func _get_plugin_icon() -> Texture2D:
	return ICON_PLUGIN
