extends Area2D
# Variables
@onready var skul_sprites = $SpriteSkul
@onready var shield_sprite = $Shield
@onready var shield_color = shield_sprite.modulate
var modulate_shield_color_check = true
var skul_dir = 0
# Signals
signal on_hit(damage)

# Methods
func _on_body_entered(body):
	if body is ObstacleGravityBase:
		var d = body.damage
		on_hit.emit(d)
	elif body is PickUpBase:
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
