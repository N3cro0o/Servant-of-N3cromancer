class_name ObstacleStaticBoss1 extends ObstacleNonverticalBase

const BOSS_2_PRZYDUPAS = preload("res://Scenes/Obstacles/Non-gravity/Obstacle5/boss2_przydupas.tscn")
const PRZYDUPAS_DATA = preload("res://Scenes/Obstacles/Non-gravity/Obstacle5/przydupas.tres")

@export var strikes: int = 20
@export var strikes_moveset: Array[LineAttackData]

@onready var timer_left: Timer = $StrikeTimerLeft
@onready var timer_middle: Timer = $StrikeTimerMiddle
@onready var timer_right: Timer = $StrikeTimerRight
@onready var attack_lines = [$Lines/Left, $Lines/Middle, $Lines/Right]

var point_spawn_array = [2, 0, 1]
var point_inver_array = [1, 0, 2]
var inverse_arr = [false, false, false]
var strikes_count = 0:
	set(x):
		strikes_count = x
		if x == strikes: 
			on_boss_kill.emit()
			queue_free()
var current_strike: LineAttackData
var attacks_in_strike = 0
var attacks_count = 0:
	set(x):
		attacks_count = x
		if x >= attacks_in_strike:
			strikes_count += 1
			pick_strike()

signal on_boss_kill

# Basic Godot functions
func _ready() -> void:
	super._ready()
	position.y += -500
	if GameScene.instance != null:
		GameScene.instance.activate_spawners(false, true)
	pick_strike()

func pick_strike():
	current_strike = strikes_moveset.pick_random() as LineAttackData
	attacks_in_strike = 0
	if current_strike.line_left:
		timer_left.start(current_strike.start_offset + current_strike.line_left_offset)
		attacks_in_strike += 1
	if current_strike.line_middle:
		timer_middle.start(current_strike.start_offset + current_strike.line_middle_offset)
		attacks_in_strike += 1
	if current_strike.line_right:
		timer_right.start(current_strike.start_offset + current_strike.line_right_offset)
		attacks_in_strike += 1
	attacks_count = 0

func strike_timeout(what: int):
	# Paused check
	while GmM.paused:
		await get_tree().process_frame
	var attack_position = 300 * what
	attack_lines[what + 1].position.x = attack_position
	attack_lines[what + 1].reset(current_strike.anim_time)

func spawn_bolt(what: int):
	if GameScene.instance != null:
		var spawner: SpawnerBasicV2 = GameScene.instance.spawner
		var point
		if inverse_arr[what]: point = point_inver_array[what]
		else: point = point_spawn_array[what]
		spawner.spawn(point, BOSS_2_PRZYDUPAS.instantiate(), PRZYDUPAS_DATA)
	attacks_count += 1
	inverse_arr[what] = false

func inverse_line(what: int):
	if current_strike.inverse_chance >= randf():
		inverse_arr[what] = true
		var tween := get_tree().create_tween()
		tween.tween_property(attack_lines[what],"position:x", -attack_lines[what].position.x,\
			current_strike.anim_time * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
