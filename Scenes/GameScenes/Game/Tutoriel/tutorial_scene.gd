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
## Used in checking position is stage 2, for number of obstacles spawned in stage 3 (last)
var pos_counter = 0
## Used as distance variable in stage 3 and timer in stage 4
var distance = 0.0
var player_hit = false
var bone = preload("res://Scenes/Obstacles/Gravity/Obstacle1/gravity_obstacle_1.tscn")
var ball = preload("res://Scenes/Obstacles/Homing/Obstacle1/homing_gravity_1.tscn")
var data_bone = preload("res://Scenes/Obstacles/Gravity/Obstacle1/gravity_obstacle_1.tres")
var data_ball = preload("res://Scenes/Obstacles/Homing/Obstacle1/homing_gravity_1.tres")
#endregion

# Basic Godot functions
func _ready() -> void:
	super._ready()
	spawner.force_active = false
	tutorial_stage = 1
	lock_diff = true

func _process(delta: float) -> void:
	super._process(delta)
	match tutorial_stage:
		1:
			stage_1(delta)
		2:
			stage_2(delta)
		3:
			stage_3(delta)
		4:
			stage_4(delta)

func _input(_event: InputEvent) -> void:
	super._input(_event)
	
	if Input.is_key_pressed(KEY_CTRL):
		player_hit = false
		if Input.is_key_pressed(KEY_6):
			tutorial_stage += 1
		if Input.is_key_pressed(KEY_5):
			tutorial_stage -= 1

func _click_catcher_input(_event: InputEvent) -> void:
	if _event is InputEventScreenTouch && _event.is_pressed() && !GmM.paused:
		dialogue.on_force()

# Stage functions
func update_stage(num):
	text_counter = 0
	match num:
		1:
			stage_1(-1)
		2:
			stage_2(-1)
		3:
			stage_3(-1)
		4:
			stage_4(-1)

func stage_1(delta: float):
	if delta < 0:
		print_rich("[hint=Stage1]Stage start[/hint]")
		# Logic
		lock_buttons = true
		#for button in camera_buttons:
			#button.visible = false
		big_boi.lock_movement = true
		small_bubble.force_disactive = true
		# Text
		var data = DialogueScreen.TextDataV1.new()
		var arr: Array[DialogueScreen.TextDataV1]
		data.text = " Damn Master, I need more cash to survive in this Dungeon's economy."
		data.delay_parameters = {0: 2.0, 1: 0.05, 12: 0.8, 13: 0.05}
		arr.push_back(data)
		
		data = DialogueScreen.TextDataV1.new()
		data.text = "I don't care at this point,\nI will perish no matter what!"
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
		lock_buttons = false
		#for button in camera_buttons:
			#button.visible = true
		big_boi.lock_movement = false
		# Text
		var data = DialogueScreen.TextDataV1.new()
		data.text = "Click the bottom left and right sides of the sceen to move the ending of the Main Line."
		var arr: Array[DialogueScreen.TextDataV1]
		arr.push_back(data)
		data = DialogueScreen.TextDataV1.new()
		data.text = "Make me move from one side to the other few times to proceed."
		arr.push_back(data)
		dialogue.set_text(arr)
		return
	if pos_counter >= 5:
		tutorial_stage = 3

# This static -> this process -> spawn boned -> congratulate/warn player -> spawn multiple bones
func stage_3(delta: float):
	if delta < 0:
		print_rich("[hint=Stage3]Stage start[/hint]")
		# Logic
		small_bubble.force_disactive = false
		lock_buttons = true
		#for button in camera_buttons:
			#button.visible = false
		big_boi.lock_movement = true
		big_boi.last_point_pos = PlayerLine1.last_pos.MIDDLE
		pos_counter = 0
		# Text
		var data = DialogueScreen.TextDataV1.new()
		var arr: Array[DialogueScreen.TextDataV1]
		data.text = "Neat!\nNow, you should learn how to defend me using MAGIC!"
		data.delay_parameters = {0: 0.05, 5: 0.8, 6: 0.05, 50: 0.12}
		arr.push_back(data)
		data = DialogueScreen.TextDataV1.new()
		data.text = "You have to swipe your finger over the arrows to use repulsion magic.\nYou must swipe the screen," + \
			" not just hold your finger!"
		data.delay_parameters = {0: 0.05, 68: 0.15, 69: 0.05}
		arr.push_back(data)
		dialogue.set_text(arr)
		return
	distance += small_bubble.velocity * delta
	if distance > 10_000 && text_counter == 3:
		distance = 0
		var data = DialogueScreen.TextDataV1.new()
		var arr: Array[DialogueScreen.TextDataV1]
		data.text = "Just pressing won't activate it, you must move your finger first."
		arr.push_back(data)
		data = DialogueScreen.TextDataV1.new()
		data.text = "You can move and ROTATE obstacles while using it, keep that in mind."
		data.delay_parameters = {0: 0.05, 17: 0.13, 23: 0.05}
		arr.push_back(data)
		dialogue.set_text([data])

# Add stage 3 (last) fail condition
func stage_4(delta: float):
	if delta < 0:
		print_rich("[hint=Stage1]Stage start[/hint]")
		# Logic
		lock_buttons = false
		#for button in camera_buttons:
			#button.visible = true
		big_boi.lock_movement = false
		big_boi.last_point_pos = PlayerLine1.last_pos.MIDDLE
		player_hit = false
		distance = 0
		# Text
		var data = DialogueScreen.TextDataV1.new()
		var arr: Array[DialogueScreen.TextDataV1]
		data.text = "Good job! Before the first real escape attempt happens, you must learn one more thing."
		data.delay_parameters = {0: 0.05, 8: 0.3, 9: 0.05}
		arr.push_back(data)
		data = DialogueScreen.TextDataV1.new()
		data.text = "Watch out for new obstacles. For example, fireballs rotate towards me and are impossible to dodge."
		arr.push_back(data)
		data = DialogueScreen.TextDataV1.new()
		data.text = "The only way to deal with them is to rotate them using magic. Tap and hold on one of their sides."
		arr.push_back(data)
		dialogue.set_text(arr)
		return
	if text_counter == 7:
		distance += delta
		if distance >= 2.0:
			GmM.change_scene(0)

# Signal functions
func on_dialogue_text_append_end():
	text_counter += 1
	if tutorial_stage == 3:
		if text_counter == 5:
			var object = spawner.spawn(0, bone.instantiate(), data_bone)
			object.tree_exited.connect(func():
				if !player_hit:
					var data = DialogueScreen.TextDataV1.new()
					var arr: Array[DialogueScreen.TextDataV1]
					data.text = "Good work! You are a quick learner."
					arr.push_back(data)
					data = DialogueScreen.TextDataV1.new()
					data.text = "Sadly, He found out about me faster than I thought."
					data.delay_parameters = {0: 0.05, 5: 0.5, 6: 0.05}
					arr.push_back(data)
					data = DialogueScreen.TextDataV1.new()
					data.text = "Try and deflect incoming obstacles!"
					arr.push_back(data)
					dialogue.set_text(arr))
		if text_counter == 9:
			lock_buttons = false
			#for button in camera_buttons:
				#button.visible = true
			big_boi.lock_movement = false
			spawner.force_active = true
			spawner.active = true
			for i in enemy_stages[0].spawn_points:
				spawner.start_timer_rand(i, 1)
			# player_hit used to write only one message
			player_hit = false
	if tutorial_stage == 4:
		if text_counter == 4:
			player_hit = false
			var object = spawner.spawn(0, ball.instantiate(), data_ball)
			object.tree_exited.connect(func():
				if !player_hit:
					var data = DialogueScreen.TextDataV1.new()
					var arr: Array[DialogueScreen.TextDataV1]
					data.text = "Good work! You are ready for the real deal now!"
					arr.push_back(data)
					data = DialogueScreen.TextDataV1.new()
					data.text = "Good luck and have fun! And of course, thanks for playing!"
					arr.push_back(data)
					dialogue.set_text(arr))

func on_line_position_changed(pos: PlayerLine1.last_pos):
	if tutorial_stage == 2 && text_counter == 3:
		if pos == PlayerLine1.last_pos.RIGHT || pos == PlayerLine1.last_pos.LEFT:
			pos_counter += 1

func on_player_hit(s, hp1):
	super.on_player_hit(s, hp1)
	if tutorial_stage == 3:
		if text_counter == 5:
			var data = DialogueScreen.TextDataV1.new()
			var arr: Array[DialogueScreen.TextDataV1]
			data.text = "Watch out! Luckily Master gave every servant a protection spell."
			data.delay_parameters = {0: 0.05, 9: 0.5, 10: 0.05}
			arr.push_back(data)
			data = DialogueScreen.TextDataV1.new()
			data.text = "Sadly, He found out about me faster than I thought."
			data.delay_parameters = {0: 0.05, 5: 0.5, 6: 0.05}
			arr.push_back(data)
			data = DialogueScreen.TextDataV1.new()
			data.text = "Try and deflect incoming obstacles!"
			arr.push_back(data)
			dialogue.set_text(arr)
			player_hit = true
			return
		if text_counter == 9:
			if !player_hit:
				spawner.force_active = false
				for ob in GameScene.instance.obstacles_array:
					ob.repulse(500)
				var data = DialogueScreen.TextDataV1.new()
				data.text = "Almost! Try to deflect or dodge all of them next time. Here they come! Protect me!"
				data.delay_parameters = {0: 0.05, 6: 0.3, 7: 0.05, 71: 0.3, 72: 0.05}
				dialogue.set_text([data])
				text_counter = 8
				pos_counter = 0
				player_hit = true
	if tutorial_stage == 4:
		if text_counter == 4:
			player_hit = true
			var data = DialogueScreen.TextDataV1.new()
			data.text = "You still need more training.\nFocus on only one side and follow it with magic."
			dialogue.set_text([data])
			text_counter = 3

func _spawner1_spawn():
	pos_counter += 1
	if pos_counter == 10:
		spawner.force_active = false
		print("Stage done")
		tutorial_stage = 4

# System functions
func on_paused(paused):
	super.on_paused(paused)
	dialogue.on_paused(paused)
	pause_panel.body_label.text = "[center]The game is paused!\nCurrent stage / out of:\n%s / %s" \
		% [tutorial_stage, 4]
