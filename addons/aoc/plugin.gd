@tool
extends EditorPlugin


const COMMAND_RUN_KEY := "advent_of_code/run"
var command_run_event := InputEventKey.new()

const DOCK_SCENE := preload("dock.tscn")
const Dock := preload("dock.gd")
var dock: Dock


func _enter_tree() -> void:
	dock = DOCK_SCENE.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock)
	dock.setup()
	dock.filesystem_changed.connect(EditorInterface.get_resource_filesystem().scan)
	
	command_run_event.keycode = KEY_ENTER
	command_run_event.alt_pressed = true
	
	var palette := EditorInterface.get_command_palette()
	palette.add_command(
		"Run",
		COMMAND_RUN_KEY,
		dock.run_active_solver,
		command_run_event.as_text()
	)


func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.queue_free()
	
	var palette := EditorInterface.get_command_palette()
	palette.remove_command(COMMAND_RUN_KEY)


func _input(event: InputEvent) -> void:
	if command_run_event.is_match(event) and event.pressed and _script_focussed():
		get_tree().root.set_input_as_handled()
		dock.run_active_solver()


func _script_focussed() -> bool:
	var focussed_node := get_tree().root.gui_get_focus_owner()
	
	# Early exit if the current node isn't a CodeEdit
	if not focussed_node is CodeEdit:
		return false
	
	# Get a list of all code editors (CodeEdit children of the script editor)
	var script_editor := EditorInterface.get_script_editor()
	var todo := script_editor.get_children()
	var code_editors: Array[CodeEdit]
	while not todo.is_empty():
		var current := todo.pop_back()
		todo += current.get_children()
		if current is CodeEdit:
			code_editors.push_back(current)
	
	# Check if the currently focussed node is one of the code editors
	return focussed_node in code_editors
