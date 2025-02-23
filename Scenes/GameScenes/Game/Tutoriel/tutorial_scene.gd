@icon("res://Images/meme/kapix.jpg")
class_name TutorialScene extends GameScene

#region Variables

@onready var dialogue: DialogueScreen = $WindowBox/Dialogue
var tutorial_stage = 0:
	set(toriel):
		if toriel < 0:
			return
		tutorial_stage = toriel
		update_stage(toriel)
var text_counter = 0
var pos_counter = 0
#endregion

# Basic Godot functions
func _ready() -> void:
	super._ready()
	spawner.force_active = false
	tutorial_stage = 1

func _process(delta: float) -> void:
	super._process(delta)
	match tutorial_stage:
		1:
			stage_1(delta)
		2:
			stage_2(delta)

# Stage functions
func update_stage(num):
	text_counter = 0
	match num:
		1:
			stage_1(-1)
		2:
			stage_2(-1)

func stage_1(delta: float):
	if delta < 0:
		print_rich("[hint=Stage1]Stage start[/hint]")
		# Logic
		for button in camera_buttons:
			button.visible = false
		big_boi.lock_movement = true
		# Text
		var data = DialogueScreen.TextDataV1.new()
		var arr: Array[DialogueScreen.TextDataV1]
		data.text = " Damn Master, I need more cash to survive in this Dungeon's economy"
		data.delay_parameters = {0: 2.0, 1: 0.05, 12: 0.8, 13: 0.05}
		arr.push_back(data)
		
		data = DialogueScreen.TextDataV1.new()
		data.text = "I don't care at this point,\n I will perish no matter what!"
		data.delay_parameters = {0: 0.05, 26: 0.5, 27: 0.05}
		arr.push_back(data)
	#dialogue.set_text("Damn Master, I need more cash to survive in this Dungeon's economy", {0:0.05, 11: 0.8, 12: 0.05})
		dialogue.set_text(arr)
		# End of non continuous section
		return
	if text_counter == 3:
		tutorial_stage = 2

func stage_2(delta: float):
	if delta < 0:
		print_rich("[hint=Stage2]Stage start[/hint]")
		# Logic
		for button in camera_buttons:
			button.visible = true
		big_boi.lock_movement = false
		# Text
		var data = DialogueScreen.TextDataV1.new()
		data.text = "Use the arrows to move the beginning of the line"
		var arr: Array[DialogueScreen.TextDataV1]
		arr.push_back(data)
		data = DialogueScreen.TextDataV1.new()
		data.text = "Make me move from one side to the other few times"
		arr.push_back(data)
		dialogue.set_text(arr)
		# End of non continuous section
		return
	if pos_counter >= 5:
		print("DONE")
		tutorial_stage = 3

# Signal functions
func on_dialogue_text_append_end():
	text_counter += 1

func on_line_position_changed(pos: PlayerLine1.last_pos):
	if tutorial_stage == 2 && text_counter == 3:
		if pos == PlayerLine1.last_pos.RIGHT || pos == PlayerLine1.last_pos.LEFT:
			pos_counter += 1

# System functions
func on_paused(paused):
	super.on_paused(paused)
	dialogue.on_paused(paused)
