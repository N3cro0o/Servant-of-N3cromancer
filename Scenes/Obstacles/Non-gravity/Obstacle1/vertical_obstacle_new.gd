extends ObstacleNonverticalBase

@onready var rocks = [$BodyR, $BodyL, $BodyM]
@onready var bum_timer: Timer = $BumTimer
@onready var modulate_timer: Timer = $Modulate_timer

var modulate_check
var game_speed = GmM.game_speed

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if !body_hit:
		rocks[0].position = Vector2(-55, 16)
		rocks[1].position = Vector2(57, 15)
		rocks[2].position = Vector2(4, -30)
	else:
		for rock in rocks:
			rock.gravity_scale = GmM.game_speed
			if !modulate_check:
				rock.modulate = Color(rock.modulate, rock.modulate.a - delta * GmM.game_speed)
	game_speed = GmM.game_speed

func on_body_hit(b):
	super.on_body_hit(b)
	set_collision_layer_value(3, false)
	for rock:RigidBody2D in rocks:
		rock.gravity_scale = GmM.game_speed
		# Get random vec
		var push_vec: Vector2 = Vector2.UP
		push_vec = push_vec.rotated(randf_range(-PI, PI))
		rock.apply_impulse(push_vec * 500 * randf_range(0.7, 1.2), rock.global_position)
	actual_speed = 0
	speed = 0
	bum_timer.start(5)
	modulate_timer.start(3)
	$SpriteShadow.visible = false
	set_collision_layer_value(3, false)

func _on_bum_timer_timeout() -> void:
	queue_free()

func _on_modulate_timer_timeout() -> void:
	pass
	#modulate_check = true

func on_paused(b):
	super.on_paused(b)
	bum_timer.paused = !bum_timer.paused

func stop_move():
	super.stop_move()
	for rock in rocks:
		rock.set_deferred("freeze", true)
	bum_timer.stop()
	modulate_check = true
