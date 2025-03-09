class_name PlayerBody extends Area2D
#region Variables

## Max speed
@export var max_speed := 7.5
## Used to accelerate during game
@export var speed_multi := 0.15
@export_group("Line")
@export var line_points_number = 125
@export var distance_points := 5.5
@export_group("Mouse Entity")
@export var no_mouse_object_hitbox = false
@export var mouse_push_strength = 100
@onready var skul_sprites = $SpriteSkul
@onready var shield_sprite = $Shield
@onready var shield_color = shield_sprite.modulate
@onready var shield_broke_gen: GPUParticles2D = $Particles/ParticleShieldBroke
@onready var shield_recharge_gen: GPUParticles2D = $Particles/ParticleShieldRecharge

var modulate_shield_color_check = true
var target_point = 0
var skul_dir = 0

#endregion
#region Signals

signal on_hit(damage)

#endregion
# Basic Godot functions
func _ready():
	target_point = int(line_points_number * .16)
	print_rich("[hint=%s]Target point = [/hint]" % name, target_point)
	MouseEntity1.instance.disabled_hitbox = no_mouse_object_hitbox
	MouseEntity1.instance.push_strength = mouse_push_strength
	shield_broke_gen.amount_ratio = SvM.return_particle_amount()
	shield_recharge_gen.amount_ratio = SvM.return_particle_amount()
	shield_recharge_gen.modulate = Color(shield_recharge_gen.modulate,0)
	shield_recharge_gen.emitting = true

func _process(delta):
	if modulate_shield_color_check:
		var c : Color = shield_sprite.modulate
		c = c.lerp(shield_color, delta * GmM.game_speed)
		shield_sprite.modulate = c
	skul_sprites.frame = abs(skul_dir)
	shield_sprite.frame = skul_sprites.frame
	if(skul_dir > 0):
		skul_sprites.scale.x = -2
		shield_sprite.scale.x = -2.05
	else:
		skul_sprites.scale.x = 2
		shield_sprite.scale.x = 2.05
	# Projectile recharge speed
	shield_recharge_gen.speed_scale = GmM.game_speed

# Hitbox functions
func _on_hitbox_activation(body):
	if body is ObstacleGravityBase:
		if body.damage >= 0:
			var d = body.damage
			body.body_hit = true
			var dir_vec: Vector2 = body.global_position - global_position
			if shield_sprite.modulate.a > 0.0 && body.damage > 0:
				emit_particle_shield_broke(dir_vec.angle())
			on_hit.emit(d)

func on_pickbox_activation(body):
	if body is PickUpBase:
		body.on_hit_activate()

# Shield functions
func reset_shield_color():
	modulate_shield_color_check = false
	shield_sprite.modulate = Color(shield_color, 0)

func return_shield_color():
	modulate_shield_color_check = true

# Particle functions
func emit_particle_shield_broke(angle: float):
	if GmM.web_development:
		return
	shield_broke_gen.rotation = angle
	shield_broke_gen.modulate = Color(1,1,1, shield_sprite.modulate.a / shield_color.a)
	await Engine.get_main_loop().process_frame
	shield_broke_gen.emitting = true

# Others
func on_game_over():
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	$PickBox.set_deferred("monitoring", false)
	$PickBox.set_deferred("monitorable", false)
