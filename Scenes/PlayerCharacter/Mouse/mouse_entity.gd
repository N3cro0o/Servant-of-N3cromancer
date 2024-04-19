extends StaticBody2D
# Variables
@export var radius:float # Collider and area radius
@export var mouse_color := Color.GREEN
@onready var detect_area := $Area2D
@onready var hit_box := $CollisionShape2D
var pos:Vector2 # mouse pos
var last_position : Vector2 # last frame pos
var velocity := Vector2.ZERO
var active := false:
	set(b):
		active = b
		if b:
			hit_box.disabled = false
			detect_area.monitoring = true
		else:
			hit_box.disabled = true
			detect_area.monitoring = false
		queue_redraw()

# Signals

# Methods
func _ready():
	pos = position
	last_position = position

func _physics_process(delta):
	var mouse = pos
	position = position.lerp(mouse, 15 * delta)
	velocity = Vector2(position.x - last_position.x, position.y - last_position.y) / delta
	velocity = velocity.round()
	last_position = position;

func _draw():
	if active:
		draw_circle(Vector2.ZERO,radius,mouse_color)

func _input(event):
	if event is InputEventScreenDrag:
		pos = event.position
	elif event is InputEventScreenTouch and event.is_pressed():
		pos = event.position
		active = true

func game_object_give_velocity(body):
	if body.is_in_group("obstacle"):
		body.linear_velocity.y = 0
		body.linear_velocity += velocity / 2
		body.on_mouse_hit()
