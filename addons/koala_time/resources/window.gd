@tool
class_name KTwindow extends Window

const TIMER_TEXT:String = "%s : %s : %s"
const BREAK_TEXT:String = "%d min"
const IMAGE_ROOT_PATH:String = "res://addons/koala_time/images/"
const IMAGE_EXTENSION:String = "png"
const ERR:String = "--> KT: An error occurred when trying to access the path!"
var new_break_time:int
var file_array = []

@onready var next_button:Button = $Control/SettingsMarginContainer/MarginContainer/VBoxContainer/Button
@onready var break_time_label:Label = $Control/SettingsMarginContainer/MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var break_time_slider:HSlider = $Control/SettingsMarginContainer/MarginContainer/VBoxContainer/HBoxContainer/HSlider
@onready var timer_label:Label = $Control/TimerMarginContainer/TimerLabel

func _notification(what:int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			queue_free()

func _ready() -> void:
	# Set random Background
	_get_dir_contents(IMAGE_ROOT_PATH)
	if file_array.size() > 0:
		$Control/TextureRect.texture = load(file_array[randi_range(0,file_array.size()-1)])

	# Set Settings and Data
	_on_timer_timeout()
	break_time_label.text = BREAK_TEXT % [new_break_time / 60]
	break_time_slider.value = new_break_time / 60
	next_button.pressed.connect(func() -> void: queue_free())
	break_time_slider.drag_ended.connect(func(_bool:bool) -> void:
		new_break_time = break_time_slider.value * 60
		break_time_label.text = BREAK_TEXT % [new_break_time / 60]
	)

func _get_dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir(): _get_dir_contents(path+"/"+file_name)
			else:
				if file_name.get_extension().to_lower() == IMAGE_EXTENSION:
					#print("--> KT Found file: " + file_name) # <-- Debug Files Found
					file_array.append(dir.get_current_dir(true)+"/"+file_name)
			file_name = dir.get_next()
	else: push_error(ERR)

var hours:String = str(0)
var minutes:String = str(0)
var seconds:String = str(0)
func _on_timer_timeout() -> void:
	seconds = str(int(seconds) + 1)
	if int(seconds) >= 60: seconds = str(0); minutes = str(int(minutes) + 1)
	if int(minutes) >= 60: minutes = str(0); hours = str(int(hours) + 1)

	var final_hours:String = hours
	var final_minutes:String = minutes
	var final_seconds:String = seconds
	if int(final_hours) < 10: final_hours = str(0)+hours
	if int(final_minutes) < 10: final_minutes = str(0)+minutes
	if int(final_seconds) < 10: final_seconds = str(0)+seconds
	timer_label.text = TIMER_TEXT % [final_hours,final_minutes,final_seconds]
