class_name MouseEntity1 extends StaticBody2D

static var instance : MouseEntity1

#region Variables

@export var radius:float # Collider and area radius
@export var push_strength := 100.0
@export var disabled_hitbox := false
@export var mouse_color := Color.GREEN
@onready var detect_area := $Area2D
@onready var hit_box := $CollisionShape2D
var pos:Vector2 # mouse pos
var last_position : Vector2 # last frame pos
var velocity_vec := Vector2.ZERO
var velocity = 0.0
var active := false:
	set(b):
		active = b
		if b:
			if !disabled_hitbox:
				hit_box.disabled = false
			else:
				hit_box.disabled = true
			detect_area.monitoring = true
		else:
			hit_box.disabled = true
			detect_area.monitoring = false
		queue_redraw()
var obstacles_hit : Array[PhysicsBody2D] = []
var frames = 0
var max_velocity := 0.0

#endregion

# Basic Godot methods
func _init():
	instance = self

func _ready():
	active = false
	pos = position
	last_position = position

func _physics_process(delta):
	# Frame counter
	if(frames > 666):
		frames = 0
		max_velocity = 0
	frames += 1
	velocity = velocity_vec.distance_to(Vector2.ZERO)
	if velocity > max_velocity:
		max_velocity = velocity
	# Mouse pos
	var mouse = pos
	position = position.lerp(mouse, 15 * delta)
	# Calc velocity
	velocity_vec = Vector2(position.x - last_position.x, position.y - last_position.y) / delta
	velocity_vec = velocity_vec.round()
	last_position = position;
	# Object hit logic
	if (frames % 5 == 0):
		for obj : PhysicsBody2D in obstacles_hit:
			var norm_vec = (obj.position - position).normalized()
			# Velocity
			norm_vec.x *= 5
			obj.linear_velocity += norm_vec * push_strength * (1 + obj.timer)
			# Rotation
			var direct_vec = 1
			if(norm_vec.x > 0):
				direct_vec = -1
			obj.rotate(delta * direct_vec * 5)
			# Timer
			obj.timer += delta

func _draw():
	if active:
		draw_circle(Vector2.ZERO,radius,mouse_color)

func _input(event):
	if event is InputEventScreenDrag:
		pos = event.position
		active = true
	elif event is InputEventScreenTouch and event.is_pressed():
		pos = event.position
	if event is InputEventScreenTouch and not event.is_pressed():
		active = false

# Interact with objects functions
func game_object_give_velocity(body:ObstacleGravityBase):
	if body.is_in_group("obstacle"):
		if velocity_vec.distance_to(Vector2.ZERO) >= 4000:
			body.linear_velocity.y = 0
		else:
			body.linear_velocity.y *= .75
		body.linear_velocity += velocity_vec / 2
		body.on_mouse_hit()
		obstacles_hit.push_back(body)
		body.timer = 0
		if body.can_lock_rotation:
			body.set_deferred("lock_rotation", true)

func game_object_give_velocity_on_exit(body:ObstacleGravityBase):
	if body.is_in_group("obstacle"):
		obstacles_hit.erase(body)
		body.timer = 0
		body.set_deferred("lock_rotation", false)
