class_name GameScene extends Node2D
static var instance : GameScene
# Variables
@onready var small_bubble := $MouseEntity
@onready var big_boi := $PlayerLine
@onready var spawners = $Spawners
@onready var obstacles := $Obstacles
@onready var debug_label := $DebugLabel
@onready var hit_frame := $HitFrame

var score = 0
var hit_color_zeroing = true

# Signals
signal on_take_damage

# Methods
func _init():
	instance = self

func _ready():
	hit_frame.self_modulate = Color(1,1,1,0)

func _process(delta):
	# Hit panel hiding
	if hit_color_zeroing:
		var c : Color = hit_frame.self_modulate
		c = c.lerp(Color(1,1,1,0), delta * 5)
		hit_frame.self_modulate = c
	# Quit game
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	# Debug text
	var d_text1 = "Solid obstacle checks:\n   Spawner 1: %s\n   Spawner 2: %s\n   Spawner 3 %s"
	debug_label.text = d_text1 % [spawners.get_child(0).can_spawn_static, spawners.get_child(1).can_spawn_static, spawners.get_child(2).can_spawn_static]

func _spawner1_spawn():
	score += 1
	print(score)

func return_player_pos():
	return big_boi.return_body_position()

func _add_obstacle(object):
	obstacles.add_child(object)

func on_player_hit():
	var t :Timer = hit_frame.get_child(0)
	t.start(2)
	hit_color_zeroing = false
	hit_frame.self_modulate = Color(1,1,1,.95)
	on_take_damage.emit()

func on_hit_timer_timeout():
	hit_color_zeroing = true
