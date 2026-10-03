@tool
extends PanelContainer

const MeshGen = preload("res://addons/pixel_mesh_builder/core/mesh_generator.gd")

const ICON_PENCIL = preload("res://addons/pixel_mesh_builder/icons/pencil.svg")
const ICON_BUCKET = preload("res://addons/pixel_mesh_builder/icons/bucket.svg")
const ICON_LINE = preload("res://addons/pixel_mesh_builder/icons/line.svg")
const ICON_RECT = preload("res://addons/pixel_mesh_builder/icons/rect.svg")
const ICON_CIRCLE = preload("res://addons/pixel_mesh_builder/icons/circle.svg")
const ICON_ERASER = preload("res://addons/pixel_mesh_builder/icons/eraser.svg")
const ICON_PICKER = preload("res://addons/pixel_mesh_builder/icons/picker.svg")

const ICON_MIRROR_X = preload("res://addons/pixel_mesh_builder/icons/mirror_x.svg")
const ICON_MIRROR_Y = preload("res://addons/pixel_mesh_builder/icons/mirror_y.svg")
const ICON_GRID = preload("res://addons/pixel_mesh_builder/icons/grid.svg")
const ICON_LAYERS = preload("res://addons/pixel_mesh_builder/icons/layers.svg")
const ICON_UNDO = preload("res://addons/pixel_mesh_builder/icons/undo.svg")
const ICON_REDO = preload("res://addons/pixel_mesh_builder/icons/redo.svg")
const ICON_IMPORT = preload("res://addons/pixel_mesh_builder/icons/import.svg")

const ICON_ROTATE = preload("res://addons/pixel_mesh_builder/icons/rotate.svg")
const ICON_CAMERA = preload("res://addons/pixel_mesh_builder/icons/camera.svg")
const ICON_RESET = preload("res://addons/pixel_mesh_builder/icons/reset.svg")
const ICON_CUBE = preload("res://addons/pixel_mesh_builder/icons/cube.svg")
const ICON_NEW = preload("res://addons/pixel_mesh_builder/icons/new.svg")
const ICON_SAVE = preload("res://addons/pixel_mesh_builder/icons/save.svg")
const ICON_FOLDER = preload("res://addons/pixel_mesh_builder/icons/folder.svg")
const ICON_EXPORT = preload("res://addons/pixel_mesh_builder/icons/export.svg")
const ICON_IMAGE = preload("res://addons/pixel_mesh_builder/icons/image.svg")
const ICON_NUMBER = preload("res://addons/pixel_mesh_builder/icons/number.svg")

const DIR_BASE = "res://assets/pixel_3d"
const DIR_MODELS = "res://assets/pixel_3d/models"
const DIR_SOURCE = "res://assets/pixel_3d/source"
const DIR_SPRITES = "res://assets/pixel_3d/sprites"
const FILE_AUTOSAVE = "res://assets/pixel_3d/source/.autosave.pmb.json"

@onready var canvas: PixelCanvasControl = $Margin/VBoxMain/BodySplit/LeftCard/HBoxCanvas/CanvasContainer/PixelCanvas

@onready var btn_pencil: Button = $Margin/VBoxMain/BodySplit/LeftCard/HBoxCanvas/ToolRail/MarginRail/VBoxTools/BtnPencil
@onready var btn_bucket: Button = $Margin/VBoxMain/BodySplit/LeftCard/HBoxCanvas/ToolRail/MarginRail/VBoxTools/BtnBucket
@onready var btn_line: Button = $Margin/VBoxMain/BodySplit/LeftCard/HBoxCanvas/ToolRail/MarginRail/VBoxTools/BtnLine
@onready var btn_rect: Button = $Margin/VBoxMain/BodySplit/LeftCard/HBoxCanvas/ToolRail/MarginRail/VBoxTools/BtnRect
@onready var btn_circle: Button = $Margin/VBoxMain/BodySplit/LeftCard/HBoxCanvas/ToolRail/MarginRail/VBoxTools/BtnCircle
@onready var btn_eraser: Button = $Margin/VBoxMain/BodySplit/LeftCard/HBoxCanvas/ToolRail/MarginRail/VBoxTools/BtnEraser
@onready var btn_picker: Button = $Margin/VBoxMain/BodySplit/LeftCard/HBoxCanvas/ToolRail/MarginRail/VBoxTools/BtnPicker

@onready var grid_size_opt: OptionButton = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/ViewBox/GridSizeOpt
@onready var btn_mirror_x: Button = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/ViewBox/BtnMirrorX
@onready var btn_mirror_y: Button = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/ViewBox/BtnMirrorY
@onready var btn_grid_lines: Button = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/ViewBox/BtnGridLines
@onready var btn_depth_numbers: Button = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/ViewBox/BtnDepthNumbers

@onready var depth_btns_container: HBoxContainer = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/DepthBox/DepthBtnsContainer
@onready var depth_spin: SpinBox = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/DepthBox/DepthSpin

@onready var edit_project_name: LineEdit = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/ProjectBox/ProjectNameEdit
@onready var lbl_save_status: Label = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/ProjectBox/SaveStatusBadge
@onready var btn_new_project: Button = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/ProjectBox/BtnNewProject
@onready var btn_quick_save: Button = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/ProjectBox/BtnQuickSave
@onready var btn_browse_projects: Button = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/ProjectBox/BtnBrowseProjects
@onready var btn_quick_export: Button = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/ProjectBox/BtnQuickExport

@onready var btn_undo: Button = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/FileBox/BtnUndo
@onready var btn_redo: Button = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/FileBox/BtnRedo
@onready var btn_import: Button = $Margin/VBoxMain/TopBar/TopMargin/TopHBox/FileBox/BtnImport

@onready var banner_recovery: PanelContainer = $Margin/VBoxMain/RecoveryBanner
@onready var btn_restore_session: Button = $Margin/VBoxMain/RecoveryBanner/BannerMargin/BannerHBox/BtnRestoreSession
@onready var btn_discard_session: Button = $Margin/VBoxMain/RecoveryBanner/BannerMargin/BannerHBox/BtnDiscardSession

@onready var lbl_toast: Label = $Margin/VBoxMain/BodySplit/LeftCard/HBoxCanvas/CanvasContainer/ToastNotification

@onready var modal_browser: PanelContainer = $ProjectBrowserModal
@onready var btn_close_browser: Button = $ProjectBrowserModal/Center/Card/Margin/VBox/HeaderHBox/BtnCloseBrowser
@onready var search_project_edit: LineEdit = $ProjectBrowserModal/Center/Card/Margin/VBox/SearchEdit
@onready var project_item_list: ItemList = $ProjectBrowserModal/Center/Card/Margin/VBox/ListScroll/ProjectItemList
@onready var lbl_empty_browser: Label = $ProjectBrowserModal/Center/Card/Margin/VBox/LblEmpty
@onready var btn_delete_project: Button = $ProjectBrowserModal/Center/Card/Margin/VBox/FooterHBox/BtnDeleteProject
@onready var btn_cancel_browser: Button = $ProjectBrowserModal/Center/Card/Margin/VBox/FooterHBox/BtnCancelBrowser
@onready var btn_load_confirm: Button = $ProjectBrowserModal/Center/Card/Margin/VBox/FooterHBox/BtnLoadConfirm
@onready var lbl_browser_count: Label = $ProjectBrowserModal/Center/Card/Margin/VBox/HeaderHBox/TitleVBox/HeaderTitleHBox/BadgeCount

@onready var modal_unsaved: PanelContainer = $UnsavedModal
@onready var lbl_unsaved_prompt: Label = $UnsavedModal/Center/Card/Margin/VBox/LblPrompt
@onready var btn_discard_changes: Button = $UnsavedModal/Center/Card/Margin/VBox/ButtonsHBox/BtnDiscardChanges
@onready var btn_cancel_unsaved: Button = $UnsavedModal/Center/Card/Margin/VBox/ButtonsHBox/BtnCancelUnsaved
@onready var btn_save_and_continue: Button = $UnsavedModal/Center/Card/Margin/VBox/ButtonsHBox/BtnSaveAndContinue

@onready var preview_3d: PixelPreview3D = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/PreviewCard/VBox/PreviewContainer
@onready var btn_cam_mode: Button = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/PreviewCard/VBox/Header/BtnCamMode
@onready var btn_auto_rotate: Button = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/PreviewCard/VBox/Header/BtnAutoRotate
@onready var btn_reset_cam: Button = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/PreviewCard/VBox/Header/BtnResetCam
@onready var lbl_stats: Label = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/PreviewCard/VBox/LblStats

@onready var palette_presets_opt: OptionButton = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/PaletteCard/PaletteVBox/MarginP/InnerVBox/PaletteHeader/PalettePresetsOpt
@onready var color_picker: ColorPickerButton = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/PaletteCard/PaletteVBox/MarginP/InnerVBox/ColorRow/ColorPickerButton
@onready var lbl_hex: Label = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/PaletteCard/PaletteVBox/MarginP/InnerVBox/ColorRow/LblHex
@onready var palette_grid: GridContainer = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/PaletteCard/PaletteVBox/MarginP/InnerVBox/PaletteGrid

@onready var voxel_size_spin: SpinBox = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/MeshCard/MeshVBox/MarginM/InnerVBox/SizeRow/VoxelSizeSpin
@onready var face_shading_cb: CheckBox = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/MeshCard/MeshVBox/MarginM/InnerVBox/TogglesGrid/FaceShadingCheck
@onready var center_xz_cb: CheckBox = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/MeshCard/MeshVBox/MarginM/InnerVBox/TogglesGrid/CenterXZCheck
@onready var ground_y_cb: CheckBox = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/MeshCard/MeshVBox/MarginM/InnerVBox/TogglesGrid/GroundYCheck
@onready var cull_faces_cb: CheckBox = $Margin/VBoxMain/BodySplit/RightScroll/RightVBox/MeshCard/MeshVBox/MarginM/InnerVBox/TogglesGrid/CullFacesCheck


@onready var modal_export: PanelContainer = $ExportModal
@onready var btn_close_export_modal: Button = $ExportModal/Center/Card/Margin/VBox/HeaderHBox/BtnCloseExportModal
@onready var btn_cancel_export_modal: Button = $ExportModal/Center/Card/Margin/VBox/FooterHBox/BtnCancelExportModal
@onready var btn_export_glb_modal: Button = $ExportModal/Center/Card/Margin/VBox/OptionsVBox/BtnExportGlbModal
@onready var btn_export_tres_modal: Button = $ExportModal/Center/Card/Margin/VBox/OptionsVBox/BtnExportTresModal
@onready var btn_export_png_modal: Button = $ExportModal/Center/Card/Margin/VBox/OptionsVBox/BtnExportPngModal
@onready var btn_export_all_modal: Button = $ExportModal/Center/Card/Margin/VBox/OptionsVBox/BtnExportAllModal

@onready var file_dialog_import: FileDialog = $FileDialogImport
@onready var file_dialog_save: FileDialog = $FileDialogSave

var editor_interface: EditorInterface
var undo_redo: EditorUndoRedoManager
var depth_buttons: Array[Button] = []
var tools_segmented_control: SegmentedButtonGroup
var depth_segmented_control: SegmentedButtonGroup
var project_actions_group: SegmentedButtonGroup
var history_actions_group: SegmentedButtonGroup
var mirror_segmented_group: SegmentedButtonGroup
var view_guides_group: SegmentedButtonGroup
var preview_cam_group: SegmentedButtonGroup
var current_grid_opt_index: int = 1
var current_loaded_project_name: String = ""

var has_unsaved_changes: bool = false
var autosave_timer: Timer
var pending_action_after_unsaved: Callable = Callable()
var cached_project_files: Array[Dictionary] = []
var toast_tween: Tween

var style_btn_normal: StyleBoxFlat
var style_btn_hover: StyleBoxFlat
var style_btn_active: StyleBoxFlat

const PALETTE_PRESETS = {
	"Material Vibrant": [
		Color("#ffffff"), Color("#cbd5e1"), Color("#64748b"), Color("#1e293b"),
		Color("#000000"), Color("#ef4444"), Color("#f97316"), Color("#facc15"),
		Color("#84cc16"), Color("#22c55e"), Color("#06b6d4"), Color("#3b82f6"),
		Color("#6366f1"), Color("#a855f7"), Color("#ec4899"), Color("#78350f")
	],
	"PICO-8": [
		Color("#000000"), Color("#1d2b53"), Color("#7e2553"), Color("#008751"),
		Color("#ab5236"), Color("#5f574f"), Color("#c2c3c7"), Color("#fff1e8"),
		Color("#ff004d"), Color("#ffa300"), Color("#ffec27"), Color("#00e436"),
		Color("#29adff"), Color("#83769c"), Color("#ff77a8"), Color("#ffccaa")
	],
	"Game Boy Retro": [
		Color("#0f380f"), Color("#306230"), Color("#8bac0f"), Color("#9bbc0f")
	],
	"NES Classic": [
		Color("#7c7c7c"), Color("#0000fc"), Color("#0000bc"), Color("#4428bc"),
		Color("#940084"), Color("#a80020"), Color("#a81000"), Color("#881400"),
		Color("#503000"), Color("#007800"), Color("#006800"), Color("#005800"),
		Color("#004058"), Color("#000000"), Color("#bcbcbc"), Color("#fc7460")
	],
	"Cyberpunk Neon": [
		Color("#050505"), Color("#0ff0fc"), Color("#ff2a85"), Color("#ffe600"),
		Color("#7122fa"), Color("#00ff66"), Color("#ff003c"), Color("#1a1a2e"),
		Color("#16213e"), Color("#0f3460"), Color("#e94560"), Color("#533483"),
		Color("#e2f3f5"), Color("#22eaaa"), Color("#101010"), Color("#ffffff")
	],
	"Endesga 32": [
		Color("#be4a2f"), Color("#d77643"), Color("#ead4aa"), Color("#e4a672"),
		Color("#b86f50"), Color("#733e39"), Color("#3e2731"), Color("#a22633"),
		Color("#e43b44"), Color("#f77622"), Color("#feae34"), Color("#fee761"),
		Color("#63c74d"), Color("#3e8948"), Color("#265c42"), Color("#193c3e"),
		Color("#124e89"), Color("#0099db"), Color("#2ce8f5"), Color("#ffffff"),
		Color("#c0cbdc"), Color("#8b9bb4"), Color("#5a6988"), Color("#3a4466"),
		Color("#262b44"), Color("#181425"), Color("#ff0044"), Color("#68386c"),
		Color("#b55088"), Color("#f6757a"), Color("#e8b796"), Color("#c28569")
	]
}

func _ready() -> void:
	init_material_styles()
	init_project_browser_ui()
	setup_icons()
	setup_grid_options()
	setup_depth_buttons()
	setup_tool_buttons()
	setup_topbar_action_groups()
	setup_palette_presets()
	load_palette_preset("Material Vibrant")
	color_picker.color = Color.BLACK
	canvas.current_color = Color.BLACK
	lbl_hex.text = "#000000"
	setup_connections()
	setup_autosave_timer()
	set_active_tool(PixelCanvasControl.ToolMode.PENCIL)
	
	btn_mirror_x.button_pressed = false
	btn_mirror_y.button_pressed = false
	btn_grid_lines.button_pressed = true
	btn_depth_numbers.button_pressed = true
	btn_auto_rotate.button_pressed = false
	btn_cam_mode.button_pressed = true
	btn_undo.disabled = true
	btn_redo.disabled = true
	if edit_project_name.text == "untitled" or edit_project_name.text == "sin_titulo" or edit_project_name.text.is_empty():
		edit_project_name.text = get_available_new_project_name()
		current_loaded_project_name = ""
	update_save_status_ui()
	check_session_recovery()
	update_preview()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if has_unsaved_changes and not canvas.pixels.is_empty():
			_on_autosave_timeout()

func init_material_styles() -> void:
	style_btn_normal = StyleBoxFlat.new()
	style_btn_normal.bg_color = Color("#1e222a")
	style_btn_normal.border_color = Color("#2c323f")
	style_btn_normal.set_border_width_all(1)
	style_btn_normal.set_corner_radius_all(6)
	style_btn_normal.content_margin_left = 8
	style_btn_normal.content_margin_right = 8
	style_btn_normal.content_margin_top = 6
	style_btn_normal.content_margin_bottom = 6

	style_btn_hover = StyleBoxFlat.new()
	style_btn_hover.bg_color = Color("#2a303c")
	style_btn_hover.border_color = Color("#40495a")
	style_btn_hover.set_border_width_all(1)
	style_btn_hover.set_corner_radius_all(6)
	style_btn_hover.content_margin_left = 8
	style_btn_hover.content_margin_right = 8
	style_btn_hover.content_margin_top = 6
	style_btn_hover.content_margin_bottom = 6

	style_btn_active = StyleBoxFlat.new()
	style_btn_active.bg_color = Color("#2563eb")
	style_btn_active.border_color = Color("#60a5fa")
	style_btn_active.set_border_width_all(1)
	style_btn_active.set_corner_radius_all(6)
	style_btn_active.content_margin_left = 8
	style_btn_active.content_margin_right = 8
	style_btn_active.content_margin_top = 6
	style_btn_active.content_margin_bottom = 6

func apply_btn_style(btn: Button, is_active: bool) -> void:
	if not btn:
		return
	if is_active:
		btn.add_theme_stylebox_override("normal", style_btn_active)
		btn.add_theme_stylebox_override("hover", style_btn_active)
		btn.add_theme_stylebox_override("pressed", style_btn_active)
		btn.add_theme_stylebox_override("hover_pressed", style_btn_active)
	else:
		btn.add_theme_stylebox_override("normal", style_btn_normal)
		btn.add_theme_stylebox_override("hover", style_btn_hover)
		btn.add_theme_stylebox_override("pressed", style_btn_normal)
		btn.add_theme_stylebox_override("hover_pressed", style_btn_hover)

func setup_icons() -> void:
	btn_pencil.icon = ICON_PENCIL
	btn_bucket.icon = ICON_BUCKET
	btn_line.icon = ICON_LINE
	btn_rect.icon = ICON_RECT
	btn_circle.icon = ICON_CIRCLE
	btn_eraser.icon = ICON_ERASER
	btn_picker.icon = ICON_PICKER

	btn_mirror_x.icon = ICON_MIRROR_X
	btn_mirror_y.icon = ICON_MIRROR_Y
	btn_grid_lines.icon = ICON_GRID
	btn_depth_numbers.icon = ICON_NUMBER
	btn_undo.icon = ICON_UNDO
	btn_redo.icon = ICON_REDO
	btn_import.icon = ICON_IMPORT

	btn_new_project.icon = ICON_NEW
	btn_quick_save.icon = ICON_SAVE
	btn_browse_projects.icon = ICON_FOLDER
	btn_quick_export.icon = ICON_EXPORT

	btn_cam_mode.icon = ICON_CAMERA
	btn_auto_rotate.icon = ICON_ROTATE
	btn_reset_cam.icon = ICON_RESET

	btn_export_glb_modal.icon = ICON_CUBE
	btn_export_tres_modal.icon = ICON_SAVE
	btn_export_png_modal.icon = ICON_IMAGE
	btn_export_all_modal.icon = ICON_EXPORT
	for b in [btn_export_glb_modal, btn_export_tres_modal, btn_export_png_modal, btn_export_all_modal]:
		if b:
			b.expand_icon = true
			b.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
			b.add_theme_constant_override("icon_max_width", 16)
			b.add_theme_constant_override("h_separation", 8)

	var icon_btns = [
		btn_pencil, btn_bucket, btn_line, btn_rect, btn_circle, btn_eraser, btn_picker,
		btn_mirror_x, btn_mirror_y, btn_grid_lines, btn_depth_numbers,
		btn_undo, btn_redo, btn_import, btn_new_project, btn_quick_save, btn_browse_projects, btn_quick_export,
		btn_cam_mode, btn_auto_rotate, btn_reset_cam
	]
	for b in icon_btns:
		if b:
			b.expand_icon = true
			b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			b.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
			b.add_theme_constant_override("icon_max_width", 16)
	
	for b in [btn_pencil, btn_bucket, btn_line, btn_rect, btn_circle, btn_eraser, btn_picker]:
		if b:
			b.add_theme_constant_override("icon_max_width", 18)

func setup_topbar_action_groups() -> void:
	if not mirror_segmented_group:
		mirror_segmented_group = SegmentedButtonGroup.new()
		mirror_segmented_group.is_vertical = false
		mirror_segmented_group.mode = SegmentedButtonGroup.Mode.TOGGLE
		mirror_segmented_group.accent_color = Color("#2563eb")
		mirror_segmented_group.track_color = Color("#111318")
		mirror_segmented_group.border_color = Color("#212530")
		mirror_segmented_group.divider_color = Color("#262c3a")
		mirror_segmented_group.corner_radius = 7
		mirror_segmented_group.pill_radius = 5
		mirror_segmented_group.pill_padding = 2
		mirror_segmented_group.button_content_margin_x = 8
		mirror_segmented_group.button_content_margin_y = 6
		mirror_segmented_group.icon_max_width = 16
		
		var v_box = btn_mirror_x.get_parent()
		v_box.add_child(mirror_segmented_group)
		v_box.move_child(mirror_segmented_group, 1)
		
		btn_mirror_x.custom_minimum_size = Vector2(30, 28)
		btn_mirror_y.custom_minimum_size = Vector2(30, 28)
		
		mirror_segmented_group.register_button(btn_mirror_x)
		mirror_segmented_group.register_button(btn_mirror_y)

	if not view_guides_group:
		view_guides_group = SegmentedButtonGroup.new()
		view_guides_group.is_vertical = false
		view_guides_group.mode = SegmentedButtonGroup.Mode.TOGGLE
		view_guides_group.accent_color = Color("#2563eb")
		view_guides_group.track_color = Color("#111318")
		view_guides_group.border_color = Color("#212530")
		view_guides_group.divider_color = Color("#262c3a")
		view_guides_group.corner_radius = 7
		view_guides_group.pill_radius = 5
		view_guides_group.pill_padding = 2
		view_guides_group.button_content_margin_x = 8
		view_guides_group.button_content_margin_y = 6
		view_guides_group.icon_max_width = 16
		
		var v_box = btn_grid_lines.get_parent()
		v_box.add_child(view_guides_group)
		v_box.move_child(view_guides_group, 2)
		
		btn_grid_lines.custom_minimum_size = Vector2(30, 28)
		btn_depth_numbers.custom_minimum_size = Vector2(30, 28)
		
		view_guides_group.register_button(btn_grid_lines)
		view_guides_group.register_button(btn_depth_numbers)

	if not preview_cam_group:
		preview_cam_group = SegmentedButtonGroup.new()
		preview_cam_group.is_vertical = false
		preview_cam_group.mode = SegmentedButtonGroup.Mode.TOGGLE
		preview_cam_group.accent_color = Color("#2563eb")
		preview_cam_group.track_color = Color("#111318")
		preview_cam_group.border_color = Color("#212530")
		preview_cam_group.divider_color = Color("#262c3a")
		preview_cam_group.corner_radius = 7
		preview_cam_group.pill_radius = 5
		preview_cam_group.pill_padding = 2
		preview_cam_group.button_content_margin_x = 6
		preview_cam_group.button_content_margin_y = 5
		preview_cam_group.icon_max_width = 16
		
		var cam_parent = btn_cam_mode.get_parent()
		cam_parent.add_child(preview_cam_group)
		
		btn_cam_mode.custom_minimum_size = Vector2(28, 26)
		btn_auto_rotate.custom_minimum_size = Vector2(28, 26)
		btn_reset_cam.custom_minimum_size = Vector2(28, 26)
		
		btn_cam_mode.toggle_mode = true
		btn_auto_rotate.toggle_mode = true
		btn_reset_cam.toggle_mode = false
		
		preview_cam_group.register_button(btn_cam_mode)
		preview_cam_group.register_button(btn_auto_rotate)
		preview_cam_group.register_button(btn_reset_cam)

	if not project_actions_group:
		project_actions_group = SegmentedButtonGroup.new()
		project_actions_group.is_vertical = false
		project_actions_group.mode = SegmentedButtonGroup.Mode.ACTION
		project_actions_group.accent_color = Color("#2563eb")
		project_actions_group.track_color = Color("#111318")
		project_actions_group.border_color = Color("#212530")
		project_actions_group.divider_color = Color("#262c3a")
		project_actions_group.corner_radius = 7
		project_actions_group.pill_radius = 5
		project_actions_group.pill_padding = 2
		project_actions_group.button_content_margin_x = 8
		project_actions_group.button_content_margin_y = 6
		project_actions_group.icon_max_width = 16
		
		var p_box = btn_quick_save.get_parent()
		p_box.add_child(project_actions_group)
		
		btn_new_project.custom_minimum_size = Vector2(32, 28)
		btn_quick_save.custom_minimum_size = Vector2(32, 28)
		btn_browse_projects.custom_minimum_size = Vector2(32, 28)
		btn_quick_export.custom_minimum_size = Vector2(32, 28)
		
		project_actions_group.register_button(btn_new_project)
		project_actions_group.register_button(btn_quick_save)
		project_actions_group.register_button(btn_browse_projects)
		project_actions_group.register_button(btn_quick_export)

	if not history_actions_group:
		history_actions_group = SegmentedButtonGroup.new()
		history_actions_group.is_vertical = false
		history_actions_group.mode = SegmentedButtonGroup.Mode.ACTION
		history_actions_group.accent_color = Color("#2563eb")
		history_actions_group.track_color = Color("#111318")
		history_actions_group.border_color = Color("#212530")
		history_actions_group.divider_color = Color("#262c3a")
		history_actions_group.corner_radius = 7
		history_actions_group.pill_radius = 5
		history_actions_group.pill_padding = 2
		history_actions_group.button_content_margin_x = 8
		history_actions_group.button_content_margin_y = 6
		history_actions_group.icon_max_width = 16
		
		var f_box = btn_undo.get_parent()
		f_box.add_child(history_actions_group)
		f_box.move_child(history_actions_group, 0)
		
		btn_undo.custom_minimum_size = Vector2(32, 28)
		btn_redo.custom_minimum_size = Vector2(32, 28)
		
		history_actions_group.register_button(btn_undo)
		history_actions_group.register_button(btn_redo)
	
	apply_btn_style(btn_import, false)
	btn_import.custom_minimum_size = Vector2(32, 28)
	btn_import.expand_icon = true
	btn_import.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_import.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	btn_import.add_theme_constant_override("icon_max_width", 16)


func setup_tool_buttons() -> void:
	if not tools_segmented_control:
		var parent = btn_pencil.get_parent()
		var rail_container = parent.get_parent()
		tools_segmented_control = SegmentedButtonGroup.new()
		tools_segmented_control.is_vertical = true
		tools_segmented_control.accent_color = Color("#2563eb")
		tools_segmented_control.track_color = Color("#111318")
		tools_segmented_control.border_color = Color("#212530")
		tools_segmented_control.divider_color = Color("#262c3a")
		tools_segmented_control.corner_radius = 8
		tools_segmented_control.pill_radius = 6
		tools_segmented_control.pill_padding = 3
		tools_segmented_control.button_content_margin_x = 8
		tools_segmented_control.button_content_margin_y = 8
		tools_segmented_control.icon_max_width = 18
		rail_container.add_child(tools_segmented_control)
		
		var tools = [btn_pencil, btn_bucket, btn_line, btn_rect, btn_circle, btn_eraser, btn_picker]
		for b in tools:
			if b:
				b.custom_minimum_size = Vector2(34, 34)
				tools_segmented_control.register_button(b)
		
		parent.visible = false
		tools_segmented_control.selection_changed.connect(func(_idx, btn):
			_on_tool_group_pressed(btn)
		)

func _on_tool_group_pressed(btn: BaseButton) -> void:
	if btn == btn_pencil:
		canvas.current_tool = PixelCanvasControl.ToolMode.PENCIL
	elif btn == btn_bucket:
		canvas.current_tool = PixelCanvasControl.ToolMode.BUCKET
	elif btn == btn_line:
		canvas.current_tool = PixelCanvasControl.ToolMode.LINE
	elif btn == btn_rect:
		canvas.current_tool = PixelCanvasControl.ToolMode.RECT
	elif btn == btn_circle:
		canvas.current_tool = PixelCanvasControl.ToolMode.CIRCLE
	elif btn == btn_eraser:
		canvas.current_tool = PixelCanvasControl.ToolMode.ERASER
	elif btn == btn_picker:
		canvas.current_tool = PixelCanvasControl.ToolMode.PICKER

func set_active_tool(mode: PixelCanvasControl.ToolMode) -> void:
	canvas.current_tool = mode
	if not tools_segmented_control:
		return
	match mode:
		PixelCanvasControl.ToolMode.PENCIL:
			tools_segmented_control.select_index(0)
		PixelCanvasControl.ToolMode.BUCKET:
			tools_segmented_control.select_index(1)
		PixelCanvasControl.ToolMode.LINE:
			tools_segmented_control.select_index(2)
		PixelCanvasControl.ToolMode.RECT:
			tools_segmented_control.select_index(3)
		PixelCanvasControl.ToolMode.CIRCLE:
			tools_segmented_control.select_index(4)
		PixelCanvasControl.ToolMode.ERASER:
			tools_segmented_control.select_index(5)
		PixelCanvasControl.ToolMode.PICKER:
			tools_segmented_control.select_index(6)

func setup_grid_options() -> void:
	grid_size_opt.clear()
	grid_size_opt.add_item("8 × 8", 8)
	grid_size_opt.add_item("16 × 16", 16)
	grid_size_opt.add_item("24 × 24", 24)
	grid_size_opt.add_item("32 × 32", 32)
	grid_size_opt.select(1)
	current_grid_opt_index = 1
	grid_size_opt.item_selected.connect(_on_grid_size_changed)

func setup_depth_buttons() -> void:
	for child in depth_btns_container.get_children():
		child.queue_free()
	depth_buttons.clear()

	depth_segmented_control = SegmentedButtonGroup.new()
	depth_segmented_control.is_vertical = false
	depth_segmented_control.accent_color = Color("#2563eb")
	depth_segmented_control.track_color = Color("#111318")
	depth_segmented_control.border_color = Color("#212530")
	depth_segmented_control.divider_color = Color("#262c3a")
	depth_segmented_control.corner_radius = 7
	depth_segmented_control.pill_radius = 5
	depth_segmented_control.pill_padding = 2
	depth_segmented_control.button_content_margin_x = 4
	depth_segmented_control.button_content_margin_y = 2
	depth_segmented_control.icon_max_width = 0
	depth_btns_container.add_child(depth_segmented_control)

	for d in range(1, 9):
		var btn = depth_segmented_control.add_item(str(d), null, "Altura Z: %d vóxeles de profundidad" % d)
		btn.custom_minimum_size = Vector2(26, 26)
		depth_buttons.append(btn)

	depth_segmented_control.selection_changed.connect(func(idx, _btn):
		var d = idx + 1
		depth_spin.value = d
		canvas.current_depth = d
	)
	depth_segmented_control.select_index(0)

func highlight_depth_button(depth: int) -> void:
	if not depth_segmented_control:
		return
	if depth >= 1 and depth <= depth_buttons.size():
		depth_segmented_control.select_index(depth - 1)

func setup_palette_presets() -> void:
	palette_presets_opt.clear()
	for p_name in PALETTE_PRESETS.keys():
		palette_presets_opt.add_item(p_name)
	palette_presets_opt.item_selected.connect(func(idx):
		var p_name = palette_presets_opt.get_item_text(idx)
		load_palette_preset(p_name)
	)

func load_palette_preset(p_name: String) -> void:
	if not PALETTE_PRESETS.has(p_name):
		return
	var colors: Array = PALETTE_PRESETS[p_name]
	for child in palette_grid.get_children():
		child.queue_free()

	for col in colors:
		var c = col as Color
		var swatch = Button.new()
		swatch.custom_minimum_size = Vector2(22, 22)
		swatch.tooltip_text = "#" + c.to_html(false).to_upper()
		
		var sb = StyleBoxFlat.new()
		sb.bg_color = c
		sb.set_corner_radius_all(4)
		swatch.add_theme_stylebox_override("normal", sb)
		
		var sb_h = StyleBoxFlat.new()
		sb_h.bg_color = c
		sb_h.border_color = Color.WHITE
		sb_h.set_border_width_all(2)
		sb_h.set_corner_radius_all(4)
		swatch.add_theme_stylebox_override("hover", sb_h)
		swatch.add_theme_stylebox_override("pressed", sb_h)
		
		swatch.pressed.connect(func():
			color_picker.color = c
			canvas.current_color = c
			lbl_hex.text = "#" + c.to_html(false).to_upper()
		)
		palette_grid.add_child(swatch)

	if not colors.is_empty():
		var first_col = colors[0] as Color
		color_picker.color = first_col
		canvas.current_color = first_col
		lbl_hex.text = "#" + first_col.to_html(false).to_upper()

var _connections_initialized: bool = false

func setup_connections() -> void:
	if _connections_initialized:
		return
	_connections_initialized = true
	canvas.pixel_changed.connect(_on_canvas_pixel_changed)
	canvas.color_picked.connect(func(col, d):
		var solid = Color(col.r, col.g, col.b, 1.0)
		color_picker.color = solid
		lbl_hex.text = "#" + solid.to_html(false).to_upper()
		set_brush_depth(d)
	)
	canvas.history_changed.connect(func(can_u, can_r):
		btn_undo.disabled = not can_u
		btn_redo.disabled = not can_r
	)

	color_picker.color_changed.connect(func(col):
		var solid = Color(col.r, col.g, col.b, 1.0)
		canvas.current_color = solid
		lbl_hex.text = "#" + solid.to_html(false).to_upper()
	)

	depth_spin.value_changed.connect(func(val):
		var d = int(val)
		canvas.current_depth = d
		highlight_depth_button(d)
	)

	btn_mirror_x.toggled.connect(func(val):
		canvas.mirror_x = val
		canvas.queue_redraw()
	)
	btn_mirror_y.toggled.connect(func(val):
		canvas.mirror_y = val
		canvas.queue_redraw()
	)

	btn_grid_lines.toggled.connect(func(val):
		canvas.show_grid = val
		canvas.queue_redraw()
	)
	btn_depth_numbers.toggled.connect(func(val):
		canvas.show_depth_numbers = val
		canvas.queue_redraw()
	)

	btn_new_project.pressed.connect(on_new_project_pressed)
	btn_quick_save.pressed.connect(func(): save_current_project(true))
	btn_browse_projects.pressed.connect(open_project_browser)
	btn_quick_export.pressed.connect(open_export_modal)
	edit_project_name.text_changed.connect(func(_t): _on_project_name_edited())

	btn_close_browser.pressed.connect(func(): modal_browser.visible = false)
	btn_cancel_browser.pressed.connect(func(): modal_browser.visible = false)
	search_project_edit.text_changed.connect(func(_t): filter_project_browser_list())
	project_item_list.item_activated.connect(_on_project_item_activated)
	btn_load_confirm.pressed.connect(_on_load_confirm_pressed)
	btn_delete_project.pressed.connect(_on_delete_project_pressed)

	btn_restore_session.pressed.connect(_on_restore_session_pressed)
	btn_discard_session.pressed.connect(_on_discard_session_pressed)

	btn_save_and_continue.pressed.connect(_on_save_and_continue_pressed)
	btn_discard_changes.pressed.connect(_on_discard_changes_pressed)
	btn_cancel_unsaved.pressed.connect(_on_cancel_unsaved_pressed)

	btn_export_glb_modal.pressed.connect(func():
		modal_export.visible = false
		export_current_model_glb(true)
	)
	btn_export_tres_modal.pressed.connect(func():
		modal_export.visible = false
		export_current_model_tres(true)
	)
	btn_export_png_modal.pressed.connect(func():
		modal_export.visible = false
		export_current_canvas_png(true)
	)
	btn_export_all_modal.pressed.connect(_on_export_all_pressed)
	btn_close_export_modal.pressed.connect(func(): modal_export.visible = false)
	btn_cancel_export_modal.pressed.connect(func(): modal_export.visible = false)

	btn_undo.pressed.connect(func(): canvas.undo())
	btn_redo.pressed.connect(func(): canvas.redo())

	btn_import.pressed.connect(func(): file_dialog_import.popup_centered_ratio(0.7))
	file_dialog_import.file_selected.connect(_on_import_file_selected)

	btn_auto_rotate.toggled.connect(func(val):
		preview_3d.auto_rotate = val
	)
	btn_cam_mode.toggled.connect(func(val):
		preview_3d.set_camera_projection(val)
	)
	btn_reset_cam.pressed.connect(func(): preview_3d.reset_camera())

	voxel_size_spin.value_changed.connect(func(_val): update_preview())
	face_shading_cb.toggled.connect(func(_val): update_preview())
	center_xz_cb.toggled.connect(func(_val): update_preview())
	ground_y_cb.toggled.connect(func(_val): update_preview())
	cull_faces_cb.toggled.connect(func(_val): update_preview())

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not (event is InputEventKey):
		return
	var key = event as InputEventKey
	if not key.pressed:
		return

	if key.ctrl_pressed:
		if key.keycode == KEY_Z:
			if key.shift_pressed:
				canvas.redo()
			else:
				canvas.undo()
			accept_event()
			return
		elif key.keycode == KEY_Y:
			canvas.redo()
			accept_event()
			return
		elif key.keycode == KEY_S:
			save_current_project(true)
			accept_event()
			return
		elif key.keycode == KEY_N:
			on_new_project_pressed()
			accept_event()
			return

	match key.keycode:
		KEY_B, KEY_P:
			set_active_tool(PixelCanvasControl.ToolMode.PENCIL)
			accept_event()
		KEY_G, KEY_F:
			set_active_tool(PixelCanvasControl.ToolMode.BUCKET)
			accept_event()
		KEY_L:
			set_active_tool(PixelCanvasControl.ToolMode.LINE)
			accept_event()
		KEY_R:
			set_active_tool(PixelCanvasControl.ToolMode.RECT)
			accept_event()
		KEY_C:
			set_active_tool(PixelCanvasControl.ToolMode.CIRCLE)
			accept_event()
		KEY_E:
			set_active_tool(PixelCanvasControl.ToolMode.ERASER)
			accept_event()
		KEY_I:
			set_active_tool(PixelCanvasControl.ToolMode.PICKER)
			accept_event()
		KEY_X:
			btn_mirror_x.button_pressed = not btn_mirror_x.button_pressed
			accept_event()
		KEY_Y:
			btn_mirror_y.button_pressed = not btn_mirror_y.button_pressed
			accept_event()
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8:
			var d = key.keycode - KEY_1 + 1
			set_brush_depth(d)
			accept_event()

func set_brush_depth(d: int) -> void:
	depth_spin.value = d
	canvas.current_depth = d
	highlight_depth_button(d)

func _on_grid_size_changed(index: int) -> void:
	var sz = grid_size_opt.get_item_id(index)
	var new_size = Vector2i(sz, sz)
	if new_size == canvas.grid_size:
		return
	if not canvas.pixels.is_empty():
		var act = func():
			current_grid_opt_index = index
			canvas.set_grid_size(new_size)
			update_preview()
		request_confirm_action(act, "Resizing canvas to %d×%d will crop pixels outside the bounds. Do you want to continue?" % [sz, sz])
	else:
		current_grid_opt_index = index
		canvas.set_grid_size(new_size)
		update_preview()

func _on_import_file_selected(path: String) -> void:
	var img = Image.new()
	var err = img.load(path)
	if err != OK:
		push_error("[Pixel 3D] Error loading image: " + path)
		return
	canvas.load_from_image(img)
	var auto_name = path.get_file().get_basename().validate_filename()
	if not auto_name.is_empty():
		edit_project_name.text = auto_name
		current_loaded_project_name = ""
	update_preview()
	display_toast("✓ Image imported: " + path.get_file())

func update_preview() -> void:
	var mesh = generate_current_mesh()
	preview_3d.update_mesh(mesh)
	update_stats_label()

func update_stats_label() -> void:
	var px_count = canvas.pixels.size()
	var max_z = 0
	var total_voxels = 0
	for d in canvas.pixels.values():
		var depth_val = int(d.get("depth", 1))
		if depth_val > max_z:
			max_z = depth_val
		total_voxels += depth_val
	lbl_stats.text = "%d px | %d voxels | Max Z: %d" % [px_count, total_voxels, max_z]

func generate_current_mesh() -> ArrayMesh:
	var vs = voxel_size_spin.value
	var cxz = center_xz_cb.button_pressed
	var gy = ground_y_cb.button_pressed
	var cull = cull_faces_cb.button_pressed
	var fsh = face_shading_cb.button_pressed
	var sym = true
	var greedy = true
	return MeshGen.generate_mesh(canvas.pixels, canvas.grid_size, 1, vs, cxz, gy, cull, fsh, sym, greedy)


func _on_save_file_selected(path: String) -> void:
	var mesh = generate_current_mesh()
	if not mesh:
		return
	if path.ends_with(".glb") or path.ends_with(".gltf"):
		var err = MeshGen.export_to_gltf(mesh, path)
		if err == OK:
			print("[Pixel 3D] 3D Model successfully exported to GLB: ", path)
			display_toast("✓ Exported to: " + path.get_file())
		else:
			push_error("[Pixel 3D] Error exporting GLB file: " + path)
	else:
		var err = ResourceSaver.save(mesh, path)
		if err == OK:
			print("[Pixel 3D] Mesh successfully saved to: ", path)
			display_toast("✓ Resource saved: " + path.get_file())
		else:
			push_error("[Pixel 3D] Error saving mesh to: " + path)

func setup_autosave_timer() -> void:
	autosave_timer = Timer.new()
	autosave_timer.one_shot = true
	autosave_timer.wait_time = 2.5
	autosave_timer.timeout.connect(_on_autosave_timeout)
	add_child(autosave_timer)

func _on_canvas_pixel_changed() -> void:
	has_unsaved_changes = true
	update_save_status_ui()
	update_preview()
	if autosave_timer and autosave_timer.is_inside_tree():
		autosave_timer.start(2.5)

func _on_autosave_timeout() -> void:
	if not has_unsaved_changes or canvas.pixels.is_empty():
		return
	ensure_directories()
	var proj_name = get_clean_project_name()
	var save_dict = {
		"version": "1.0",
		"name": proj_name,
		"timestamp": Time.get_unix_time_from_system(),
		"date_str": Time.get_datetime_string_from_system(false, true),
		"canvas_data": canvas.export_data(),
		"settings": {
			"voxel_size": voxel_size_spin.value,
			"center_xz": center_xz_cb.button_pressed,
			"ground_y": ground_y_cb.button_pressed,
			"cull_faces": cull_faces_cb.button_pressed,
			"face_shading": face_shading_cb.button_pressed,
			"symmetric_depth": true,
			"greedy_mesh": true
		}
	}
	var f = FileAccess.open(FILE_AUTOSAVE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(save_dict))
		f.close()

func _on_project_name_edited() -> void:
	has_unsaved_changes = true
	update_save_status_ui()

func update_save_status_ui() -> void:
	if not lbl_save_status:
		return
	if has_unsaved_changes:
		lbl_save_status.text = "●"
		lbl_save_status.tooltip_text = "Unsaved changes (Ctrl + S to save)"
		lbl_save_status.add_theme_color_override("font_color", Color("#f59e0b"))
	else:
		lbl_save_status.text = "✓"
		lbl_save_status.tooltip_text = "Saved in assets/pixel_3d/"
		lbl_save_status.add_theme_color_override("font_color", Color("#10b981"))

func ensure_directories() -> void:
	var da = DirAccess.open("res://")
	if da:
		if not da.dir_exists("assets"):
			da.make_dir("assets")
		if not da.dir_exists("assets/pixel_3d"):
			da.make_dir("assets/pixel_3d")
		if not da.dir_exists("assets/pixel_3d/models"):
			da.make_dir("assets/pixel_3d/models")
		if not da.dir_exists("assets/pixel_3d/source"):
			da.make_dir("assets/pixel_3d/source")
		if not da.dir_exists("assets/pixel_3d/sprites"):
			da.make_dir("assets/pixel_3d/sprites")

func get_clean_project_name() -> String:
	var nm = edit_project_name.text.strip_edges()
	if nm.is_empty():
		nm = "pixel_model"
	nm = nm.replace(" ", "_").validate_filename()
	if nm.is_empty():
		nm = "pixel_model"
	return nm

func get_available_new_project_name() -> String:
	ensure_directories()
	var da = DirAccess.open(DIR_SOURCE)
	var existing: Dictionary = {}
	if da:
		da.list_dir_begin()
		var fname = da.get_next()
		while fname != "":
			if not da.current_is_dir() and fname.ends_with(".pmb.json"):
				var bname = fname.trim_suffix(".pmb.json")
				existing[bname] = true
			fname = da.get_next()
		da.list_dir_end()
	
	var idx = 1
	while true:
		var candidate = "model_%d" % idx
		if not existing.has(candidate) and not existing.has("modelo_%d" % idx):
			return candidate
		idx += 1
	return "model_1"

func on_new_project_pressed() -> void:
	request_safe_action(
		Callable(self, "_do_create_new_project"),
		"The current model has unsaved modifications. Do you want to save them before creating a new project?"
	)

func _do_create_new_project() -> void:
	canvas.reset_canvas()
	current_loaded_project_name = ""
	edit_project_name.text = get_available_new_project_name()
	has_unsaved_changes = false
	btn_undo.disabled = true
	btn_redo.disabled = true
	update_save_status_ui()
	update_preview()
	if FileAccess.file_exists(FILE_AUTOSAVE):
		DirAccess.remove_absolute(FILE_AUTOSAVE)
	display_toast("✓ New project: " + edit_project_name.text)

func export_current_model_glb(show_toast: bool = true) -> bool:
	ensure_directories()
	var mesh = generate_current_mesh()
	if not mesh:
		display_toast("⚠️ No voxels drawn to export")
		return false
	var proj_name = get_clean_project_name()
	var glb_path = "%s/%s.glb" % [DIR_MODELS, proj_name]
	var err = MeshGen.export_to_gltf(mesh, glb_path)
	if err == OK:
		if editor_interface:
			editor_interface.get_resource_filesystem().scan()
		if show_toast:
			display_toast("✓ Model exported: models/%s.glb" % proj_name)
		return true
	else:
		push_error("[Pixel 3D] Error exporting GLB file: " + glb_path)
		display_toast("❌ Failed to export GLB")
		return false

func export_current_model_tres(show_toast: bool = true) -> bool:
	ensure_directories()
	var mesh = generate_current_mesh()
	if not mesh:
		display_toast("⚠️ No voxels drawn to export")
		return false
	var proj_name = get_clean_project_name()
	var tres_path = "%s/%s.tres" % [DIR_MODELS, proj_name]
	var err = ResourceSaver.save(mesh, tres_path)
	if err == OK:
		if editor_interface:
			editor_interface.get_resource_filesystem().scan()
		if show_toast:
			display_toast("✓ Resource saved: models/%s.tres" % proj_name)
		return true
	else:
		push_error("[Pixel 3D] Error saving .tres resource: " + tres_path)
		display_toast("❌ Failed to save .tres resource")
		return false

func export_current_canvas_png(show_toast: bool = true) -> bool:
	ensure_directories()
	if canvas.pixels.is_empty():
		display_toast("⚠️ No pixels drawn to export")
		return false
	var proj_name = get_clean_project_name()
	var png_path = "%s/%s.png" % [DIR_SPRITES, proj_name]
	var img = Image.create(canvas.grid_size.x, canvas.grid_size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.0, 0.0, 0.0, 0.0))
	for coord in canvas.pixels.keys():
		if coord.x >= 0 and coord.x < canvas.grid_size.x and coord.y >= 0 and coord.y < canvas.grid_size.y:
			var col: Color = canvas.pixels[coord].get("color", Color.WHITE)
			img.set_pixel(coord.x, coord.y, col)
	var err = img.save_png(png_path)
	if err == OK:
		if editor_interface:
			editor_interface.get_resource_filesystem().scan()
		if show_toast:
			display_toast("✓ Sprite exported: sprites/%s.png" % proj_name)
		return true
	else:
		push_error("[Pixel 3D] Error exporting Sprite PNG: " + png_path)
		display_toast("❌ Failed to export Sprite PNG")
		return false

func open_export_modal() -> void:
	if not modal_export:
		return
	modal_export.visible = true

func _on_export_all_pressed() -> void:
	modal_export.visible = false
	var ok_glb = export_current_model_glb(false)
	var ok_tres = export_current_model_tres(false)
	var ok_png = export_current_canvas_png(false)
	if ok_glb or ok_tres or ok_png:
		display_toast("✓ Exported: .glb, .tres and .png")

func save_current_project(show_toast: bool = true) -> bool:
	ensure_directories()
	var proj_name = get_clean_project_name()
	edit_project_name.text = proj_name

	var pmb_path = "%s/%s.pmb.json" % [DIR_SOURCE, proj_name]
	
	if FileAccess.file_exists(pmb_path) and proj_name != current_loaded_project_name:
		var act = func():
			current_loaded_project_name = proj_name
			_write_project_file(proj_name, pmb_path, show_toast)
		request_confirm_action(act, "A model named '%s' already exists. Do you want to overwrite it?" % proj_name)
		return false
	
	current_loaded_project_name = proj_name
	return _write_project_file(proj_name, pmb_path, show_toast)

func _write_project_file(proj_name: String, pmb_path: String, show_toast: bool) -> bool:
	var save_dict = {
		"version": "1.0",
		"name": proj_name,
		"timestamp": Time.get_unix_time_from_system(),
		"date_str": Time.get_datetime_string_from_system(false, true),
		"canvas_data": canvas.export_data(),
		"settings": {
			"voxel_size": voxel_size_spin.value,
			"center_xz": center_xz_cb.button_pressed,
			"ground_y": ground_y_cb.button_pressed,
			"cull_faces": cull_faces_cb.button_pressed,
			"face_shading": face_shading_cb.button_pressed,
			"symmetric_depth": true,
			"greedy_mesh": true
		}
	}
	var f = FileAccess.open(pmb_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(save_dict, "\t"))
		f.close()
	else:
		push_error("[Pixel 3D] Error saving source file: " + pmb_path)
		return false

	var old_pmb = "%s/%s.pmb" % [DIR_SOURCE, proj_name]
	if FileAccess.file_exists(old_pmb):
		DirAccess.remove_absolute(old_pmb)

	if FileAccess.file_exists(FILE_AUTOSAVE):
		DirAccess.remove_absolute(FILE_AUTOSAVE)
	var old_autosave = "res://assets/pixel_3d/source/.autosave.pmb"
	if FileAccess.file_exists(old_autosave):
		DirAccess.remove_absolute(old_autosave)

	has_unsaved_changes = false
	update_save_status_ui()

	if editor_interface:
		editor_interface.get_resource_filesystem().scan()

	if show_toast:
		display_toast("✓ Project saved to source/" + proj_name + ".pmb.json")
	return true

func load_project_file(pmb_path: String) -> bool:
	if not FileAccess.file_exists(pmb_path):
		return false
	var f = FileAccess.open(pmb_path, FileAccess.READ)
	if not f:
		return false
	var text = f.get_as_text()
	f.close()

	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		push_error("[Pixel 3D] Error reading .pmb file: " + pmb_path)
		return false

	var data = json.get_data()
	if not (data is Dictionary):
		return false

	var proj_name = data.get("name", pmb_path.get_file().get_basename())
	edit_project_name.text = proj_name
	current_loaded_project_name = proj_name

	var cdata = data.get("canvas_data", {})
	if not cdata.is_empty():
		canvas.import_data(cdata)
		var gx = int(cdata.get("grid_size_x", 16))
		if gx <= 8: grid_size_opt.select(0)
		elif gx <= 16: grid_size_opt.select(1)
		elif gx <= 24: grid_size_opt.select(2)
		else: grid_size_opt.select(3)

	var s = data.get("settings", {})
	if not s.is_empty():
		voxel_size_spin.value = float(s.get("voxel_size", 0.1))
		center_xz_cb.button_pressed = bool(s.get("center_xz", true))
		ground_y_cb.button_pressed = bool(s.get("ground_y", true))
		cull_faces_cb.button_pressed = bool(s.get("cull_faces", true))
		face_shading_cb.button_pressed = bool(s.get("face_shading", true))

	update_preview()
	has_unsaved_changes = false
	update_save_status_ui()
	display_toast("✓ Model '%s' loaded successfully" % proj_name)
	return true

func display_toast(msg: String) -> void:
	if not lbl_toast:
		return
	lbl_toast.text = msg
	lbl_toast.modulate = Color(1, 1, 1, 1)
	lbl_toast.visible = true
	if toast_tween and toast_tween.is_valid():
		toast_tween.kill()
	toast_tween = create_tween()
	toast_tween.tween_interval(2.8)
	toast_tween.tween_property(lbl_toast, "modulate:a", 0.0, 0.6)
	toast_tween.tween_callback(func(): lbl_toast.visible = false)

func request_confirm_action(action: Callable, prompt_msg: String) -> void:
	pending_action_after_unsaved = action
	lbl_unsaved_prompt.text = prompt_msg
	modal_unsaved.visible = true

func request_safe_action(action: Callable, prompt_msg: String = "") -> void:
	if has_unsaved_changes and not canvas.pixels.is_empty():
		pending_action_after_unsaved = action
		if not prompt_msg.is_empty():
			lbl_unsaved_prompt.text = prompt_msg
		else:
			lbl_unsaved_prompt.text = "There are unsaved changes in '%s'. If you continue, they will be lost." % get_clean_project_name()
		modal_unsaved.visible = true
	else:
		action.call()

func _on_save_and_continue_pressed() -> void:
	save_current_project(true)
	modal_unsaved.visible = false
	if pending_action_after_unsaved.is_valid():
		var act = pending_action_after_unsaved
		pending_action_after_unsaved = Callable()
		act.call()

func _on_discard_changes_pressed() -> void:
	has_unsaved_changes = false
	update_save_status_ui()
	modal_unsaved.visible = false
	if pending_action_after_unsaved.is_valid():
		var act = pending_action_after_unsaved
		pending_action_after_unsaved = Callable()
		act.call()

func _on_cancel_unsaved_pressed() -> void:
	modal_unsaved.visible = false
	pending_action_after_unsaved = Callable()
	grid_size_opt.select(current_grid_opt_index)

func init_project_browser_ui() -> void:
	project_item_list.fixed_icon_size = Vector2i(46, 46)
	project_item_list.icon_mode = ItemList.ICON_MODE_LEFT
	project_item_list.auto_height = false
	
	var sb_list = StyleBoxFlat.new()
	sb_list.bg_color = Color("#0f1116")
	sb_list.border_color = Color("#202532")
	sb_list.set_border_width_all(1)
	sb_list.set_corner_radius_all(8)
	sb_list.set_content_margin_all(8)
	project_item_list.add_theme_stylebox_override("panel", sb_list)
	
	var sb_selected = StyleBoxFlat.new()
	sb_selected.bg_color = Color("#1d283c")
	sb_selected.border_color = Color("#3b82f6")
	sb_selected.set_border_width_all(1)
	sb_selected.set_corner_radius_all(6)
	project_item_list.add_theme_stylebox_override("selected", sb_selected)
	project_item_list.add_theme_stylebox_override("selected_focus", sb_selected)
	
	var sb_hover = StyleBoxFlat.new()
	sb_hover.bg_color = Color("#171b24")
	sb_hover.set_corner_radius_all(6)
	project_item_list.add_theme_stylebox_override("hovered", sb_hover)

func generate_thumbnail_from_data(cdata: Dictionary) -> ImageTexture:
	var gx = int(cdata.get("grid_size_x", 16))
	var gy = int(cdata.get("grid_size_y", 16))
	if gx <= 0 or gy <= 0:
		gx = 16
		gy = 16
	var img = Image.create(gx, gy, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.11, 0.12, 0.16, 1.0))
	var pxs = cdata.get("pixels", [])
	for p in pxs:
		if p is Dictionary:
			var x = int(p.get("x", 0))
			var y = int(p.get("y", 0))
			if x >= 0 and x < gx and y >= 0 and y < gy:
				var col = Color.from_string(str(p.get("color", "#ffffff")), Color.WHITE)
				img.set_pixel(x, y, col)
	img.resize(46, 46, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(img)

func open_project_browser() -> void:
	ensure_directories()
	modal_browser.visible = true
	search_project_edit.text = ""
	refresh_project_browser_list()
	if search_project_edit.is_inside_tree():
		search_project_edit.grab_focus()

func refresh_project_browser_list() -> void:
	cached_project_files.clear()
	var da = DirAccess.open(DIR_SOURCE)
	if da:
		da.list_dir_begin()
		var fname = da.get_next()
		while fname != "":
			if not da.current_is_dir() and fname.ends_with(".pmb.json") and not fname.begins_with("."):
				var full_path = DIR_SOURCE + "/" + fname
				var f = FileAccess.open(full_path, FileAccess.READ)
				if f:
					var text = f.get_as_text()
					f.close()
					var json = JSON.new()
					if json.parse(text) == OK:
						var data = json.get_data()
						if data is Dictionary:
							var cdata = data.get("canvas_data", {})
							var pixels = cdata.get("pixels", [])
							var pcount = pixels.size()
							var dstr = str(data.get("date_str", ""))
							var bname = fname.replace(".pmb.json", "")
							cached_project_files.append({
								"path": full_path,
								"name": bname,
								"pixels": pcount,
								"date": dstr,
								"canvas_data": cdata
							})
			fname = da.get_next()
		da.list_dir_end()
	
	cached_project_files.sort_custom(func(a, b): return a["name"] < b["name"])
	filter_project_browser_list()

func filter_project_browser_list() -> void:
	project_item_list.clear()
	var q = search_project_edit.text.strip_edges().to_lower()
	var count = 0

	for item in cached_project_files:
		var nm = str(item["name"])
		if q.is_empty() or q in nm.to_lower():
			var pcount = item["pixels"]
			var dstr = item["date"]
			var sub = "%d px" % pcount
			if not dstr.is_empty():
				sub += " • " + dstr
			var display_text = "%s\n%s" % [nm, sub]
			
			var thumb = generate_thumbnail_from_data(item.get("canvas_data", {}))
			var idx = project_item_list.add_item(display_text, thumb)
			project_item_list.set_item_metadata(idx, item["path"])
			count += 1

	lbl_empty_browser.visible = (count == 0)
	lbl_browser_count.text = "%d" % count
	btn_load_confirm.disabled = (count == 0)
	btn_delete_project.disabled = (count == 0)
	if count > 0:
		project_item_list.select(0)

func _on_project_item_activated(idx: int) -> void:
	_on_load_confirm_pressed()

func _on_load_confirm_pressed() -> void:
	var sel = project_item_list.get_selected_items()
	if sel.is_empty():
		return
	var path = str(project_item_list.get_item_metadata(sel[0]))
	modal_browser.visible = false
	request_safe_action(Callable(self, "load_project_file").bind(path))

func _on_delete_project_pressed() -> void:
	var sel = project_item_list.get_selected_items()
	if sel.is_empty():
		return
	var path = str(project_item_list.get_item_metadata(sel[0]))
	var fname = path.get_file()
	var base = fname.replace(".pmb.json", "").replace(".pmb", "").replace(".json", "")
	var act = func():
		_execute_delete_project(path, base)
	request_confirm_action(act, "Permanently delete model '%s'? This action cannot be undone." % base)

func _execute_delete_project(path: String, base: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	var pmb_old = "%s/%s.pmb" % [DIR_SOURCE, base]
	if FileAccess.file_exists(pmb_old):
		DirAccess.remove_absolute(pmb_old)
	var glb_path = "%s/%s.glb" % [DIR_MODELS, base]
	if FileAccess.file_exists(glb_path):
		DirAccess.remove_absolute(glb_path)
	var tres_path = "%s/%s.tres" % [DIR_MODELS, base]
	if FileAccess.file_exists(tres_path):
		DirAccess.remove_absolute(tres_path)
	
	if current_loaded_project_name == base:
		current_loaded_project_name = ""
	
	if editor_interface:
		editor_interface.get_resource_filesystem().scan()
	display_toast("✓ Model '%s' deleted" % base)
	refresh_project_browser_list()

func check_session_recovery() -> void:
	if FileAccess.file_exists(FILE_AUTOSAVE) or FileAccess.file_exists("res://assets/pixel_3d/source/.autosave.pmb"):
		banner_recovery.visible = true
	else:
		banner_recovery.visible = false

func _on_restore_session_pressed() -> void:
	if FileAccess.file_exists(FILE_AUTOSAVE):
		load_project_file(FILE_AUTOSAVE)
		banner_recovery.visible = false
		display_toast("✓ Unsaved session restored")
	elif FileAccess.file_exists("res://assets/pixel_3d/source/.autosave.pmb"):
		load_project_file("res://assets/pixel_3d/source/.autosave.pmb")
		banner_recovery.visible = false
		display_toast("✓ Unsaved session restored")

func _on_discard_session_pressed() -> void:
	if FileAccess.file_exists(FILE_AUTOSAVE):
		DirAccess.remove_absolute(FILE_AUTOSAVE)
	if FileAccess.file_exists("res://assets/pixel_3d/source/.autosave.pmb"):
		DirAccess.remove_absolute("res://assets/pixel_3d/source/.autosave.pmb")
	banner_recovery.visible = false
