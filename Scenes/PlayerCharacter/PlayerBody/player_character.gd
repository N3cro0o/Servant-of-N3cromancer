class_name PlayerBody extends Area2D
# Variables
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
var modulate_shield_color_check = true
var target_point = 0
var skul_dir = 0

# Signals
signal on_hit(damage)

# Methods
func _ready():
	target_point = int(line_points_number * .16)
	print_rich("[hint=%s]Target point = [/hint]" % name, target_point)
	MouseEntity1.instance.disabled_hitbox = no_mouse_object_hitbox
	MouseEntity1.instance.push_strength = mouse_push_strength

func _on_hitbox_activation(body):
	if body is ObstacleGravityBase:
		var d = body.damage
		body.body_hit = true
		on_hit.emit(d)

func on_pickbox_activation(body):
	if body is PickUpBase:
		body.on_hit_activate()

func reset_shield_color():
	modulate_shield_color_check = false
	shield_sprite.modulate = Color(shield_color, 0)

func return_shield_color():
	modulate_shield_color_check = true

func _process(delta):
	if modulate_shield_color_check:
		var c : Color = shield_sprite.modulate
		c = c.lerp(shield_color, delta)
		shield_sprite.modulate = c
	skul_sprites.frame = abs(skul_dir)
	shield_sprite.frame = skul_sprites.frame
	if(skul_dir > 0):
		skul_sprites.scale.x = -2
		shield_sprite.scale.x = -2.05
	else:
		skul_sprites.scale.x = 2
		shield_sprite.scale.x = 2.05

func on_game_over():
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	$PickBox.set_deferred("monitoring", false)
	$PickBox.set_deferred("monitorable", false)
