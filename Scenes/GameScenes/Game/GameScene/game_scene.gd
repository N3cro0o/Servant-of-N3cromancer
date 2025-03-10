@icon("res://Images/meme/STOP.png")
class_name GameScene extends Node2D
static var instance : GameScene

# Stop PauseMenu when dead, force paused when dead, add grace period for skull

#region Enums

enum state {
	NORMAL = 2, # Normal state
	SHIELD_BROKEN = 0, # Player can take damage
	RECHARGE_HIT = -1, # Player takes half damage + its debuffs
	SHIELD_RECHARGE = 1, # Player buffer hit recharges
	BROKEN_HIT = -2, # Player takes full damage
	DED = -3 # Player took an L, massive skill issue
}

#endregion
#region Variables

@export var bg_sprites : Array[Sprite2D]
@export var enemy_stages : Array[StageEnemyData]
@export_category("Buttons")
@export_range(1.0, 2.0) var button_height_scale = 1.0
@onready var small_bubble :MouseEntity1 = $MouseEntity
@onready var big_boi :PlayerLine1 = $PlayerLine
@onready var spawner: SpawnerBasicV2 = $SpawnerV2
@onready var debug_label := $WindowBox/DebugLabel
@onready var hit_frame := $HitFrame
@onready var inventory = $WindowBox/ScrollsBox/InventoryLogic
@onready var pause_panel: PauseScreen = $WindowBox/PausePanel
@onready var camera_buttons : Array[TouchScreenButton] = [$Camera2D/ButtonL, $Camera2D/ButtonR]

# Player vars
var hit_color_zeroing = true
var p_state
## Current player hp
var hp
## Variable to store last player HP - calc difference
var hp_last = 0
## Start player hp
var hp_start

# Game vars
var obstacles_array :Array[ObstacleGravityBase]
var fps : float:
	set(f):
		fps = 1 / f
var fpsp : float:
	set(f):
		fpsp = 1 / f
var lock_logic := false
var bg_lock := false
var lock_diff = false
var stage = 0
var boss

# Button vars
var margin_side = 75
var margin_between = 20
var margin_bottom = 100

# Difficulty vars
var diff_trunc_val = 1
var difficulty := 0.0:
	set(d):
		if !lock_diff:
			difficulty = d
			# Max diff
			if difficulty >= enemy_stages[stage].difficulty_threshold:
				lock_diff = true
				difficulty = enemy_stages[stage].difficulty_threshold
				spawn_boss()
			# Speed increase
			if difficulty >= diff_trunc_val:
				diff_trunc_val += 1
				speed += accelerate
				speed_multi = speed / 5
				if speed > big_boi.return_max_speed():
					speed = big_boi.return_max_speed()
## speed in [m/s] because metric is far superior, no thing or no one will change this
var speed := 7.5
var max_speed := 10.0
var accelerate = 0.1
static var speed_multi := 1.0
static var actual_speed_multi := 1.0
#endregion
#region Signals

signal on_level_start
signal on_stage_advance
signal on_take_damage
signal on_failing_level

#endregion
# Basic Godot functions
func _init():
	#if instance != null:
		#instance.queue_free()
	instance = self

func _ready():
	GmM.curr_scene = self
	# Connect to GmM
	GmM.on_paused.connect(on_paused)
	debug_label.visible = GmM.debug_label_visible
	# Hp stuff
	hit_frame.self_modulate = Color(1,1,1,0)
	hp = big_boi.health_points
	hp_start = hp
	# Speed
	speed_multi = speed / 5
	#region Buttons
	var bttn_left :TouchScreenButton = $Camera2D/ButtonL
	var bttn_right :TouchScreenButton = $Camera2D/ButtonR
	var screen_size = Vector2(1080, 2400)
	# From left border to right --> margin_side px, margin_between px, margin_side px
	var screen_width = screen_size.x - (2 * margin_side + margin_between)
	var bttn_height = 128 * button_height_scale
	# Scale
	var bttn_size_scalar : float = (screen_width / 2)
	bttn_size_scalar /= 256
	bttn_left.scale = Vector2(bttn_size_scalar, button_height_scale)
	bttn_right.scale = Vector2(bttn_size_scalar, button_height_scale)
	# Position
	screen_width = screen_size.x / 2 - margin_side
	screen_size.y -= $Camera2D.position.y
	var bttn_position = Vector2(screen_width,screen_size.y - margin_bottom - bttn_height)
	bttn_left.position = Vector2(-bttn_position.x, bttn_position.y)
	bttn_right.position = Vector2(bttn_position.x, bttn_position.y + bttn_height)
	#endregion
	speed = big_boi.speed
	accelerate = big_boi.return_accelerate()
	max_speed = big_boi.return_max_speed()
	# Spawner
	spawner.set_obstacle_data(enemy_stages[stage])
	# Level setup completed
	pause_panel.visible = false
	on_level_start.emit()
	print_rich("Level ready!")

func _physics_process(delta):
	fpsp = delta
	if !lock_logic:
		ScM.distance += speed * delta

func _process(delta):
	fps = delta
	# Hit panel hiding
	if hit_color_zeroing:
		var c : Color = hit_frame.self_modulate
		c = c.lerp(Color(1,1,1,(hp_start - hp) * .05), delta * 5)
		hit_frame.self_modulate = c
	# BG movement
	if !bg_lock:
		for x in bg_sprites:
			x.position.y += delta * 250 * actual_speed_multi * GmM.game_speed
			if x.position.y >= 3600:
				x.position.y -= 2400 * 3 - 1
	# Paused saving
	if !GmM.paused:
		actual_speed_multi = speed_multi
	# And lastly, hp diference
	hp_last = hp
	
	# Don't forget 'bout 'Debug label'
	debug_label.text = "FPS: %d\nFPSP: %d\nMouse_pos: x %d; y %d" \
		% [Engine.get_frames_per_second(), fpsp, small_bubble.position.x, small_bubble.position.y]

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		pause_game()

func _notification(what):
	# Quit game
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		pause_game()

# Stages functions
func advance_stage():
	boss.on_boss_kill.disconnect(advance_stage)
	if stage < enemy_stages.size() - 1:
		stage += 1
	lock_diff = false
	difficulty = 0
	diff_trunc_val = 2
	accelerate /= 2
	spawner.set_obstacle_data(enemy_stages[stage])
	on_stage_advance.emit()

func spawn_boss():
	boss = spawner.spawn_boss_logic()
	spawner.active = false
	boss.on_boss_kill.connect(advance_stage)

# Spawner functions
func _spawner1_spawn():
	ScM.score += 1

func _add_obstacle(object:ObstacleGravityBase):
	$Obstacles.add_child(object)
	obstacles_array.push_back(object)

func _add_pickup(object):
	$Pickups.add_child(object)

func activate_spawners(state_spawner : bool):
	spawner.active = state_spawner

func on_obstacle_remove(object):
	if !lock_logic:
		var ob = obstacles_array.find(object)
		if ob >= 0:
			obstacles_array.remove_at(ob)

# Player functions
func return_player_pos():
	return big_boi.return_body_position()

func return_inventory():
	return inventory

# Old name, please ignore. Too lazy to change
func on_player_hit(s, hp1):
	var t :Timer = hit_frame.get_child(0)
	p_state = s
	if (s == state.BROKEN_HIT or s == state.RECHARGE_HIT):
		# Stop hit timer and wait...
		t.stop()
		# Take damage check
		if hp1 != hp_last:
			hit_color_zeroing = false
			hit_frame.self_modulate = Color(1,1,1,.95)
			on_take_damage.emit()
			if s == state.BROKEN_HIT:
				GmM.start_slow_mo(1.5, 0.2)
			if hp_start * 0.33 >= hp1:
				damage_muffle()
	if s == state.SHIELD_RECHARGE:
		# ... for shield recharge
		t.start(2)
	hp = hp1

func on_hit_timer_timeout():
	hit_color_zeroing = true

func on_player_death():
	if lock_logic:
		return
	print_rich("[hint=GameScene]Game Over![/hint]")
	p_state = state.DED
	lock_logic = true
	bg_lock = true
	on_failing_level.emit()
	GmM.after_game_over_logic(0)
	# Stop spawning
	spawner.force_active = false
	# Stop-time
	for obs in obstacles_array:
		if obs == null:
			continue
		obs.stop_move()
	spawner.active = false
	for pickup in $Pickups.get_children() as Array[PickUpBase]:
		pickup.queue_free()
		$Pickups.remove_child(pickup)

func damage_muffle():
	var volume = SvM.data["volume_master"];
	Sfx.update_bus_volume("master", volume * 0.75)

# Changing scenes logic
func pause_game():
	GmM.paused = !GmM.paused

func reset_level_request():
	var volume = SvM.data["volume_master"];
	Sfx.update_bus_volume("master", volume)
	GmM.after_game_over_logic()
	get_tree().call_deferred("reload_current_scene")

func quit_level_request():
	var volume = SvM.data["volume_master"];
	Sfx.update_bus_volume("master", volume)
	GmM.change_scene(0)

func on_paused(paused):
	if paused:
		actual_speed_multi *= GmM.paused_slowdown
		pause_panel.visible = true
		pause_panel.body_label.text = "[center]The game is paused!\n\nScore: %sm." % round(ScM.distance)
	else:
		actual_speed_multi = speed_multi
		pause_panel.visible = false
	for bttn in camera_buttons:
		bttn.visible = !GmM.paused
