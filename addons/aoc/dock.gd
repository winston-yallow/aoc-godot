@tool
extends PanelContainer


signal filesystem_changed()


const PATH_TEMPLATE_SCRIPT := "res://solvers/%02d.gd"
const PATH_TEMPLATE_INPUT := "res://data-inputs/%02d-data.txt"
const PATH_TEMPLATE_OUTPUT := "res://data-outputs/%02d-part-%d.txt"

const SCRIPT_TEMPLATE = """extends Day


func solve_first(input: String) -> String:
	return "TODO: Implemented Part 1"


func solve_second(input: String) -> String:
	return "TODO: Implemented Part 2"
"""


@onready var _main_vbox: VBoxContainer = $ScrollContainer/MarginContainer/MainVBox
@onready var _margin_container: MarginContainer = %MarginContainer
@onready var _btn_initialize: Button = %Initialize
@onready var _btn_run1: Button = %Run1
@onready var _btn_run2: Button = %Run2
@onready var _btn_copy: Button = %Copy
@onready var _input_day: SpinBox = %Day
@onready var _input_data: TextEdit = %Override
@onready var _results: RichTextLabel = %Results

@onready var _titles: Array[Label] = [%Title]
@onready var _subtitles: Array[Label] = [%RunTitle, %ActionsTitle, %ResultsTitle]
@onready var _panels: Array[PanelContainer] = [%SetupPanel, %ActionsPanel, %ResultsPanel]


func setup() -> void:
	add_theme_stylebox_override("panel", get_theme_stylebox("LaunchPadNormal", "EditorStyles"))
	
	for i in _titles:
		i.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))
		i.add_theme_font_size_override("font_size", get_theme_font_size("doc_title_size", "EditorFonts"))
	
	for i in _subtitles:
		i.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))
		i.add_theme_font_size_override("font_size", get_theme_font_size("title_size", "EditorFonts"))
	
	for i in _panels:
		i.add_theme_stylebox_override("panel", get_theme_stylebox("PanelForeground", "EditorStyles"))
	
	_main_vbox.add_theme_constant_override("separation", get_theme_constant("v_separation", "EditorProperty"))
	
	var margin := get_theme_constant("inspector_margin", "Editor") / 2.0
	_margin_container.add_theme_constant_override("margin_left", margin)
	_margin_container.add_theme_constant_override("margin_top", margin)
	_margin_container.add_theme_constant_override("margin_right", margin)
	_margin_container.add_theme_constant_override("margin_bottom", margin)
	
	_results.add_theme_stylebox_override("normal",  get_theme_stylebox("PanelForeground", "EditorStyles"))
	
	_btn_initialize.icon = get_theme_icon("ScriptCreate", "EditorIcons")
	_btn_run1.icon = get_theme_icon("MainPlay", "EditorIcons")
	_btn_run2.icon = get_theme_icon("MainPlay", "EditorIcons")
	_btn_copy.icon = get_theme_icon("ActionCopy", "EditorIcons")
	
	_btn_initialize.pressed.connect(func():
		_initialize(_input_day.value, _input_data.text)
	)
	_btn_run1.pressed.connect(func():
		_run(_input_day.value, 1, _get_input(_input_day.value))
	)
	_btn_run2.pressed.connect(func():
		_run(_input_day.value, 2, _get_input(_input_day.value))
	)
	_btn_copy.pressed.connect(func():
		var text := _results.get_parsed_text()
		DisplayServer.clipboard_set(text)
		DisplayServer.clipboard_set_primary(text)
	)


func _get_input(day: int) -> String:
	if not _input_data.text.strip_edges().is_empty():
		return _input_data.text
	
	var input_path := PATH_TEMPLATE_INPUT % day
	if FileAccess.file_exists(input_path):
		var input_file = FileAccess.open(input_path, FileAccess.READ)
		return input_file.get_as_text()
	
	return ""


func _initialize(day: int, input_data: String) -> void:
	var notes: Array[Dictionary] = []
	
	# Create input data if it does not exist
	var input_path := PATH_TEMPLATE_INPUT % day
	if input_data.is_empty():
		notes.push_back({
			"color": "error_color",
			"msg": 'no input data provided',
		})
	if FileAccess.file_exists(input_path):
		notes.push_back({
			"color": "error_color",
			"msg": 'input data at "%s" already exist' % input_path,
		})
	if notes.is_empty():
		var input_file = FileAccess.open(input_path, FileAccess.WRITE)
		input_file.store_string(input_data)
		notes.push_back({
			"color": "success_color",
			"msg": 'created input data at "%s"' % input_path,
		})
	
	# Create script if it does not exist
	var script_path := PATH_TEMPLATE_SCRIPT % day
	if FileAccess.file_exists(script_path):
		notes.push_back({
			"color": "error_color",
			"msg": 'script at "%s" already exist' % script_path,
		})
	else:
		var script_file = FileAccess.open(script_path, FileAccess.WRITE)
		script_file.store_string(SCRIPT_TEMPLATE)
		notes.push_back({
			"color": "success_color",
			"msg": 'created script at "%s"' % script_path,
		})
	
	_show_notes(notes)
	
	filesystem_changed.emit()


func _run(day: int, part: int, input: String) -> void:
	var notes: Array[Dictionary] = []
	
	input = input.strip_edges()
	if input.is_empty():
		notes.push_back({"color": "error_color", "msg": "no input provided"})
	
	var script_path := PATH_TEMPLATE_SCRIPT % day
	var day_instance: Day
	if not FileAccess.file_exists(script_path):
		notes.push_back({
			"color": "error_color",
			"msg": 'no script exist at "%s"' % script_path,
		})
	else:
		var script: GDScript = load(script_path)
		if _find_base_script(script) == Day:
			day_instance = script.new()
		else:
			notes.push_back({
				"color": "error_color",
				"msg": 'script at "%s" does not inherit from Day' % script_path,
			})
	
	if not notes.is_empty():
		_show_notes(notes)
		return
	
	var output := day_instance.solve(part, input)
	var output_path := PATH_TEMPLATE_OUTPUT % [day, part]
	var output_file := FileAccess.open(output_path, FileAccess.WRITE)
	output_file.store_string(output)
	filesystem_changed.emit()
	
	_results.clear()
	_results.add_text(output)


func _show_notes(notes: Array[Dictionary]) -> void:
	_results.clear()
	for item in notes:
		_results.push_list(0, RichTextLabel.LIST_DOTS, false)
		_results.push_color(get_theme_color(item.color, "Editor"))
		_results.add_text(item.msg)
		_results.pop()
		_results.pop()


func _find_base_script(script: Script) -> Script:
	while script.get_base_script() != null:
		script = script.get_base_script()
	return script
