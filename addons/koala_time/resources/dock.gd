@tool
class_name KoalaTimeDock extends Control

@onready var timer:Timer = $BreakTimer
@onready var timer_label:Label = $VBoxContainer/TimerLabel
@onready var skip_button:Button = $VBoxContainer/HBoxContainer/SkipButton
@onready var stop_button:Button = $VBoxContainer/HBoxContainer/StopButton

# Path and Stats
const KT_WINDOW:Resource = preload("res://addons/koala_time/resources/window.tscn")
const ROOT_PATH:String = "user://"
const FILE_NAME:String = "koala_time.tres"
var stats:StatsDataKT

# Timer Stuff
const TIMER_TEXT:String = "%s:%s:%s"
var break_time_counter:int
var break_time:int

var plugin_is_running:bool = false
func _ready() -> void:
	if plugin_is_running:
		# Verify previous saved data
		if _verify_file() == false:
			stats = StatsDataKT.new()
			write_savefile()
		else: stats = _load_savefile()
		break_time_counter = stats.break_time_counter
		break_time = stats.break_time

		_on_break_timer_timeout()
		_start_timer()

		skip_button.pressed.connect(func() -> void: _open_new_session_window())
		stop_button.pressed.connect(func() -> void:
			if timer.paused == false: timer.paused = true
			else: timer.paused = false
		)

func _on_break_timer_timeout() -> void:
	var hours:String = str(break_time_counter / 3600)
	var minutes:String = str(break_time_counter % 3600 / 60)
	var seconds:String = str(break_time_counter % 3600 % 60)
	timer_label.text = format_time(TIMER_TEXT,hours,minutes,seconds)
	if break_time_counter == 0:
		_open_new_session_window()
	break_time_counter -= 1

func format_time(FORMAT:String,hours:String,minutes:String,seconds:String) -> String:
	if int(hours) < 10: hours = str(0)+hours
	if int(minutes) < 10: minutes = str(0)+minutes
	if int(seconds) < 10: seconds = str(0)+seconds
	return FORMAT % [hours,minutes,seconds]

func _open_new_session_window() -> void:
	timer.stop()
	var window:KTwindow = KT_WINDOW.instantiate()

	window.position = DisplayServer.screen_get_size() / 2 - window.size / 2
	window.new_break_time = break_time
	window.is_editor_hint_custom = false
	add_child(window,false,Node.INTERNAL_MODE_FRONT)
	window.set_current_screen(DisplayServer.window_get_current_screen())

	window.tree_exiting.connect(func() -> void:
		break_time_counter = window.new_break_time
		break_time = window.new_break_time
		_on_break_timer_timeout()
		_start_timer()
	)

func _start_timer() -> void:
	timer.paused = false
	timer.start(1)

# Data and File related functions
func write_data() -> void:
	stats.break_time_counter = break_time_counter
	stats.break_time = break_time

func write_savefile() -> void:
	ResourceSaver.save(stats,ROOT_PATH+FILE_NAME,0)

func _load_savefile() -> Resource:
	return ResourceLoader.load(ROOT_PATH+FILE_NAME,"",0)

func _verify_file() -> bool:
	if DirAccess.open(ROOT_PATH).file_exists(FILE_NAME) == true: return true
	else: return false
