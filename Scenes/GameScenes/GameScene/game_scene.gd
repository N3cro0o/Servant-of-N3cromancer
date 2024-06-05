class_name GameScene extends Node2D
static var instance : GameScene

enum state {
	NORMAL = 2, # Normal state
	SHIELD_BROKEN = 0, # Player can take damage
	RECHARGE_HIT = -1, # Player takes half damage + its debuffs
	SHIELD_RECHARGE = 1, # Player buffer hit recharges
	BROKEN_HIT = -2, # Player takes full damage
	DED = -3 # Player took an L, massive skill issue
}

# Variables
@export var bg_sprites : Array[Sprite2D]
@onready var small_bubble := $MouseEntity
@onready var big_boi := $PlayerLine
@onready var spawners = $Spawners
@onready var debug_label := $DebugLabel
@onready var hit_frame := $HitFrame

var obstacles_array :Array[ObstacleGravityBase]
var hit_color_zeroing = true
var p_state
## Current player hp
var hp
## Variable to store last player HP - calc difference
var hp_last = 0
## Start player hp
var hp_start
var fps : float:
	set(f):
		fps = 1 / f
var fpsp : float:
	set(f):
		fpsp = 1 / f
var lock_logic := false
# Signals
signal on_take_damage
signal on_failing_level

# Methods
func _init():
	instance = self

func _ready():
	hit_frame.self_modulate = Color(1,1,1,0)
	hp = big_boi.health_points
	hp_start = hp

func _physics_process(delta):
	fpsp = delta

func _process(delta):
	fps = delta
	# Hit panel hiding
	if hit_color_zeroing:
		var c : Color = hit_frame.self_modulate
		c = c.lerp(Color(1,1,1,(hp_start - hp) * .05), delta * 5)
		hit_frame.self_modulate = c
	# BG movement
	for x in bg_sprites:
		x.position.y += delta * 250
		if x.position.y >= 3600:
			x.position.y -= 2400 * 3 -1
	# Quit game
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	# Debug text
	var d_text1 = "Solid obstacle checks:\nSpawner 1: %s\nSpawner 2: %s\nSpawner 3: %s\n\n"
	debug_label.text = d_text1 % [spawners.get_child(0).can_spawn_static,
	 spawners.get_child(1).can_spawn_static, spawners.get_child(2).can_spawn_static]
	debug_label.text += "Player state: %s, %d\nMouse speed: %d\nMax mouse speed: %d" % [state.find_key\
	(big_boi.p_state), hp, $MouseEntity.velocity, $MouseEntity.max_velocity]
	#debug_label.text += "\nFPS1: %f, FPS2: %f" % [fps, fpsp]
	# And lastly, hp diference
	hp_last = hp

func _spawner1_spawn():
	ScM.score += 1
	print_rich("[hint=game_scene]Score = %d[/hint]" % ScM.score)

func return_player_pos():
	return big_boi.return_body_position()

func _add_obstacle(object:ObstacleGravityBase):
	$Obstacles.add_child(object)
	obstacles_array.push_back(object)

func _add_pickup(object):
	$Pickups.add_child(object)

func on_obstacle_remove(object):
	if !lock_logic:
		var ob = obstacles_array.find(object)
		if ob >= 0:
			obstacles_array.remove_at(ob)

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
	if s == state.SHIELD_RECHARGE:
		# ... for shield recharge
		t.start(2)
	hp = hp1

func on_hit_timer_timeout():
	hit_color_zeroing = true

func on_player_death():
	lock_logic = true
	on_failing_level.emit()
