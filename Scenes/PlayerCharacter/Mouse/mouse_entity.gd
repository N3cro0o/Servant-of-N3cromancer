extends StaticBody2D
# Variables
@export var radius:float
var pos:Vector2
var touch_check := false
# Signals

# Methods
func _physics_process(delta):
	var mouse = pos
	position = position.lerp(mouse, 15 * delta)

func _draw():
	draw_circle(Vector2.ZERO,radius,Color.WHITE)

func _input(event):
	if event is InputEventScreenDrag:
		pos = event.position
	elif event is InputEventScreenTouch and event.is_pressed():
		pos = event.position
