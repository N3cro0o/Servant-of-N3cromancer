class_name ObstacleNonverticalBoss1 extends ObstacleNonverticalBase

@export var hp = 5
var death_timer = 30
var damage_timer = 0

signal on_boss_kill

func _ready():
	super._ready()
	GameScene.instance.activate_spawners(false)

func check_for_da_bone(body):
	if body.is_in_group("boned"):
		var body1 = body as ObstacleGravityBase
		if body1.mouse_hit and damage_timer == 0:
			take_damage()

func _physics_process(delta):
	super._physics_process(delta)
	if damage_timer > 0:
		damage_timer -= delta
	else:
		damage_timer = 0
	death_timer -= delta
	if death_timer <= 0:
		speed = 1000

func take_damage():
	hp -= 1
	damage_timer = 1.02137
	if hp <= 0:
		kill_boss()

func kill_boss():
	on_boss_kill.emit()
	queue_free()
