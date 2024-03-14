@tool
class_name KTwindow extends Window

const TIMER_TEXT:String = "%s : %s : %s"
const BREAK_TEXT:String = "%d min"
const IMAGE_ROOT_PATH:String = "res://addons/koala_time/images/"
const IMAGE_EXTENSION:String = "png"
const ERR:String = "--> KT: An error occurred when trying to access the path!"
var new_break_time:int
var file_array = []

var message := {
	1:   "Stretch those legs!",
	2:   "Eyes need rest too.",
	3:   "Time for a breather!",
	4:   "Refresh your mind.",
	5:   "Break time, buddy!",
	6:   "Take a walk outside.",
	7:   "A break awaits you.",
	8:   "Pause and relax.",
	9:   "Stretch and unwind.",
	10:  "Blink away fatigue.",
	11:  "Relaxation incoming!",
	12:  "Let's stretch it out!",
	13:  "Move those muscles!",
	14:  "A moment of zen.",
	15:  "Eyes off the screen.",
	16:  "Chill for a bit.",
	17:  "Take a breather.",
	18:  "Time to recharge.",
	19:  "Ready for a break?",
	20:  "Refresh and revive.",
	21:  "Clear your mind.",
	22:  "Breathe deeply now.",
	23:  "Brain break time!",
	24:  "Unwind and relax.",
	25:  "Relaxation station.",
	26:  "Step away for a sec.",
	27:  "Time to chillax.",
	28:  "Switch off, recharge.",
	29:  "Refresh your focus.",
	30:  "Let's take five.",
	31:  "Detox from screens.",
	32:  "A break is brewing.",
	33:  "Relax and rejuvenate.",
	34:  "Revitalize yourself.",
	35:  "Get up and move.",
	36:  "Ease your mind.",
	37:  "Break, don't break!",
	38:  "Revive your energy.",
	39:  "Step back and relax.",
	40:  "Relax, it's break time.",
	41:  "Time to decompress.",
	42:  "Take a little breather.",
	43:  "Just breathe, relax.",
	44:  "Break time, cheers!",
	45:  "Unplug for a while.",
	46:  "Relax and recharge.",
	47:  "Take a mini vacation.",
	48:  "Disconnect, rejuvenate.",
	49:  "Break time bliss!",
	50:  "Recharge your batteries!",
	51:  "Refresh your focus, friend.",
	52:  "Give your mind a break.",
	53:  "Eyes off, relax on.",
	54:  "A short break, big impact.",
	55:  "Take a breather, champ.",
	56:  "Step away, clear mind.",
	57:  "Reset and re-energize.",
	58:  "Relax, you've earned it.",
	59:  "Pause, then play better.",
	60:  "Unwind, then conquer.",
	61:  "Detox from the screen.",
	62:  "Rejuvenate your spirit.",
	63:  "Mindfulness moment now.",
	64:  "Reboot your brain.",
	65:  "Break time, find peace.",
	66:  "A moment to recharge.",
	67:  "Step back, find balance.",
	68:  "Refresh, refocus, restart.",
	69:  "Revive your creativity.",
	70:  "Take a timeout, superstar.",
	71:  "Decompress and de-stress.",
	72:  "Unplug, unwind, relax.",
	73:  "A brief escape awaits.",
	74:  "Break the routine, relax.",
	75:  "Renew your energy, now.",
	76:  "Refreshment break, ah!",
	77:  "Quick break, big results.",
	78:  "Time out for tranquility.",
	79:  "Chill out, cool down.",
	80:  "Take five, rejuvenate.",
	81:  "Relax, then rock on.",
	82:  "Reconnect with yourself.",
	83:  "Hit pause, find peace.",
	84:  "Revitalize your spirit.",
	85:  "Refresh, then return.",
	86:  "Unwind, then work wonders.",
	87:  "Breathe, reset, resume.",
	88:  "Pause for self-care.",
	89:  "Recharge, refuel, relax.",
	90:  "Refreshment break, hooray!",
	91:  "Short break, big benefits.",
	92:  "A break, the best medicine.",
	93:  "Time to chill, recharge.",
	94:  "Revitalize, then conquer.",
	95:  "A quick break, huge help.",
	96:  "Find calm, then conquer.",
	97:  "Short break, sharp mind.",
	98:  "Pause for positivity.",
	99:  "Refresh, then rock it!",
	100: "A break, a better you.",
}


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

	# Set random Text
	$Control/MessageMarginContainer/MessageLabel.text = message[randi_range(1,100)]

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
