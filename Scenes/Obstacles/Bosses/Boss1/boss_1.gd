class_name ObstacleNonverticalBoss1 extends ObstacleNonverticalBase

const DA_BONE = preload("res://Scenes/Obstacles/Gravity/Obstacle1/gravity_obstacle_1.tscn")
const DA_BONE_DATA = preload("res://Scenes/Obstacles/Gravity/Obstacle1/gravity_obstacle_1.tres")

#region Variable

@export var hp = 5
@onready var spawners = $Spawners
var death_timer = 35.0
var death_timer_trunc = 34.0
var damage_timer = 0
var kill_check = false

#endregion
#region Singnals

signal on_boss_kill

#endregion

# Basic Godot functions
func _ready():
	super._ready()
	GameScene.instance.activate_spawners(false, true)

func _physics_process(delta):
	super._physics_process(delta)
	var x = -300
	for i in 3:
		var spwnr = spawners.get_child(i)
		spwnr.position = Vector2(position.x + x, position.y - 200)
		x += 300
	# Damage inv
	if damage_timer > 0:
		damage_timer -= delta
	else:
		damage_timer = 0
	# If paused, timer is slowed down and cannot spawn anything
	# Death timer
	death_timer -= delta * GmM.game_speed
	if death_timer <= 0:
		kill_boss()
	if death_timer < death_timer_trunc and !kill_check and !GmM.paused:
		death_timer_trunc -= 1.5
		var rand_spwnr_num = randi_range(0, 2)
		var boner = DA_BONE.instantiate()
		var c = spawners.get_child(rand_spwnr_num).spawn_something(boner, DA_BONE_DATA) as ObstacleGravityBase
		c.z_index = -1

# Death functions
func kill_boss():
	if !kill_check:
		on_boss_kill.emit()
		speed = 1000
		actual_speed = 1000
		kill_check = true
	modulate = Color(modulate, modulate.a - 0.015)
