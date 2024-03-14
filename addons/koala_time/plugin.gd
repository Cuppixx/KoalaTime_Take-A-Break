@tool
extends EditorPlugin

const DOCK:Resource = preload("res://addons/koala_time/resources/dock.tscn")
var dock:KoalaTimeDock

func _enter_tree() -> void:
	dock = DOCK.instantiate()
	dock.plugin_is_running = true
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)

func _exit_tree() -> void:
	if dock:
		dock.write_data()
		dock.write_savefile()
		remove_control_from_docks(dock)
		dock.queue_free()
