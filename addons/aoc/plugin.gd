@tool
extends EditorPlugin


const DOCK_SCENE := preload("dock.tscn")
const Dock := preload("dock.gd")
var dock: Dock


func _enter_tree() -> void:
	dock = DOCK_SCENE.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock)
	dock.setup()
	dock.filesystem_changed.connect(get_editor_interface().get_resource_filesystem().scan)


func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.queue_free()
