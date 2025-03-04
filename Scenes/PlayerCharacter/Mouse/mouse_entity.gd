class_name MouseEntity1 extends StaticBody2D

static var instance : MouseEntity1

#region Variables

@export var radius:float # Collider and area radius
@export var push_strength := 100.0
@export var disabled_hitbox := false
@export var mouse_color := Color.GREEN
@onready var detect_area := $Area2D
@onready var hit_box := $CollisionShape2D
@onready var particles: GPUParticles2D = $GPUParticles2D
var actual_mouse_color := mouse_color
var pos:Vector2: # mouse pos
	set(vec):
		pos = Vector2(vec.x - GmM.window_fix, vec.y)
var last_position : Vector2 # last frame pos
var velocity_vec := Vector2.ZERO
var velocity = 0.0
var active := false:
	set(b):
		if !force_disactive:
			active = b
		else:
			active = false
		
		if b:
			if !disabled_hitbox:
				hit_box.disabled = false
			else:
				hit_box.disabled = true
			detect_area.monitoring = true
		else:
			hit_box.disabled = true
			detect_area.monitoring = false
		toggle_particles()
		queue_redraw()
var force_disactive = false:
	set(b):
		force_disactive = b
		if b:
			active = false
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
	actual_mouse_color = mouse_color
	GmM.on_paused.connect(on_paused)
	particles.amount_ratio = SvM.return_particle_amount()

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
	# Particle speed factor
	particles.speed_scale = GmM.game_speed

func _draw():
	if active && GmM.web_development:
		draw_circle(Vector2.ZERO,radius,actual_mouse_color)

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
	if body.is_in_group("obstacle") and !GmM.paused:
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
	if body.is_in_group("obstacle") and !GmM.paused:
		obstacles_hit.erase(body)
		body.timer = 0
		body.set_deferred("lock_rotation", false)

# Paused functions
func on_paused(paused):
	if paused:
		set_collision_layer_value(1,false)
		set_collision_mask_value(2,false)
		actual_mouse_color = Color.TRANSPARENT
		obstacles_hit.clear()
	else:
		set_collision_layer_value(1,true)
		set_collision_mask_value(2,true)
		actual_mouse_color = mouse_color

# Particles functions
func toggle_particles():
	await Engine.get_main_loop().process_frame
	if !GmM.web_development:
		particles.emitting = active
	else:
		particles.emitting = false
