class_name PlayerLine1 extends Line2D
static var instance : PlayerLine1

enum last_pos {
	LEFT = -1,
	MIDDLE = 0,
	RIGHT = 1
}
enum state {
	NORMAL = 2, # Normal state
	SHIELD_BROKEN = 0, # Player can take damage
	RECHARGE_HIT = -1, # Player takes half damage + its debuffs
	SHIELD_RECHARGE = 1, # Player buffer hit recharges
	BROKEN_HIT = -2, # Player takes full damage
	DED = -3 # Player took an L, massive skill issue
}

# Variables
@export var last_point_pos := last_pos.MIDDLE:
	set(x):
		last_point_pos = x
		if x == last_pos.MIDDLE:
			left_line_pos = last_pos.LEFT
			right_line_pos = last_pos.RIGHT
		elif x == last_pos.LEFT:
			right_line_pos = last_pos.MIDDLE
		else:
			left_line_pos = last_pos.MIDDLE
		_change_last_point_pos(self, last_point_pos)
@export var health_points := 5
## Used to calculate distance score
@export var speed : float = 5.0
@export_group("Audio")
@export var streams : Array[SoundHolder] = [preload("res://SFX/moving.tres"), preload("res://SFX/slap.tres"),\
	preload("res://SFX/skul_crack.tres")]
@onready var line2 := $AdditionalLine
@onready var line_r = $HelpLines/LineR
@onready var line_l = $HelpLines/LineL
@onready var line_add = $AdditionalLine
@onready var timer = $ShieldTimer1
@onready var timer_charge = $ShieldTimer2
@onready var player_repeat = $PlayerRepeat
@onready var player_hit = $PlayerHit
@onready var player_hit_super = $PlayerHitSuper

var body : PlayerBody
var skul_dir = 0:
	set(f):
		var dir = 1
		if f <= 0:
			dir = -1
		if abs(f) >= .3:
			dir *= 2
		if abs(f) < .1:
			dir = 0
		skul_dir = dir
		body.skul_dir = dir
var line_points_number = 125
var distance_points = 5.5
## Remember to ALWAYS change heath before update p_state var
var p_state : state = state.NORMAL:
	set(s):
		p_state = s
		on_player_status_change.emit(s, health_points)
		if(health_points <= 0):
			p_state = state.DED
			on_game_over()
			on_player_death.emit()
var count : int
var left_line_pos := last_pos.LEFT
var right_line_pos := last_pos.RIGHT
var inv := false
var mega_inv = false
var target_pos : Vector2
var offset := 0.0
var velocity := 0.0
var inv_check = false
var lock_movement = false
var greater_line_number = true

# Signals
signal on_player_status_change(s:state, hp:int)
signal on_player_death

# Methods
static func simulate_key_press(s:String): # Input just pressed simulation doesn't work for code
	if s == "key_left":
		instance.pos_changer(last_pos.LEFT)
	elif s == "key_right":
		instance.pos_changer(last_pos.RIGHT)

func _init():
	instance = self

func _ready():
	# Spawn player body
	body = GmM.body_array[GmM.current_body].instantiate()
	add_child(body)
	body.on_hit.connect(on_body_hit)
	# Sounds setup
	player_hit.stream = streams[1].stream
	player_hit.volume_db = streams[1].volume
	player_hit_super.stream = streams[2].stream
	player_hit_super.volume_db = streams[2].volume
	# Update line colors
	var color = GmM.line_color_array[GmM.line_color]
	default_color = color
	line_r.default_color = Color(color, line_r.default_color.a)
	line_l.default_color = Color(color, line_l.default_color.a)
	line_add.default_color = color
	# Line logic
	line_points_number = body.line_points_number
	distance_points = body.distance_points
	if line_points_number < points.size():
		greater_line_number = false
	var difference = 124
	while line_points_number != points.size():
		if !greater_line_number:
			remove_point(difference)
			line_r.remove_point(difference)
			line_l.remove_point(difference)
			difference -= 1
		else:
			add_point(Vector2.ZERO)
			line_r.add_point(Vector2.ZERO)
			line_l.add_point(Vector2.ZERO)
	count = get_point_count() - 1
	print(count)
	var _i :=  PI / 2
	for x in count + 1:
		set_point_position(x, Vector2(0, -x * distance_points))
		line_r.set_point_position(x, Vector2(500, -x * distance_points))
		line_l.set_point_position(x, Vector2(-500, -x * distance_points))
		_i += 2 * PI / count

func _process(_delta):
	# Debug inv
	if mega_inv:
		inv = true
	# Heath logic
	if p_state == state.RECHARGE_HIT:
		p_state = state.SHIELD_BROKEN
	elif p_state == state.BROKEN_HIT:
		p_state = state.SHIELD_BROKEN
		# Blinking health
	if inv:
		if body.skul_sprites.self_modulate.r < 0.1 and !inv_check:
			inv_check = true
		elif body.skul_sprites.self_modulate.r > 0.9 and inv_check:
			inv_check = false
		var i = 1
		if inv_check:
			i = -1
		body.skul_sprites.self_modulate.r -= 0.025 * i
	else:
		body.skul_sprites.self_modulate.r = lerpf(body.skul_sprites.self_modulate.r, \
		1, _delta * 20)
	if !lock_movement:
		# Angle calcs
		var vec : Vector2 = get_point_position(count) - body.position
		var a = vec.angle() + PI/2
		skul_dir = a
		#if skul_dir != 0:
			#play_autoplay(streams[0], true)
		#else:
			#play_autoplay(streams[0], false)
		# Rail Lines position
		line_r.position = position
		line_l.position = position
		_change_last_point_pos(line_r, right_line_pos)
		_change_last_point_pos(line_l, left_line_pos)
		# Extra long line stuff
		var point_vec = get_point_position(get_point_count() - 1)
		line2.set_point_position(0, point_vec)
		line2.set_point_position(1, Vector2(point_vec.x, point_vec.y - 2000))
		point_vec = line_r.get_point_position(get_point_count() - 2)
		line_r.set_point_position(count + 1, Vector2(point_vec.x, point_vec.y - 2000))
		point_vec = line_l.get_point_position(get_point_count() - 2)
		line_l.set_point_position(count + 1, Vector2(point_vec.x, point_vec.y - 2000))
		# Pushing down position
		_push_position_down_array(self)
		_push_position_down_array(line_l)
		_push_position_down_array(line_r)
		# Body and changing line curve
		target_pos = get_point_position(body.target_point) # 21th point cuz there's some buffer space 
			#while dtaping one dir
		offset = target_pos.x - body.position.x
		velocity = lerp(velocity, offset / _delta, _delta)
		body.position.x += velocity * _delta # delta cuz its smooooooooth now!
		velocity *= 0.85 # damping
		if(Input.is_action_just_pressed("key_left")):
			pos_changer(last_pos.LEFT)
		elif(Input.is_action_just_pressed("key_right")):
			pos_changer(last_pos.RIGHT)

func pos_changer(move:last_pos):
	if last_point_pos == last_pos.LEFT and move == last_pos.LEFT:
		return
	elif last_point_pos == last_pos.RIGHT and move == last_pos.RIGHT:
		return
	@warning_ignore("int_as_enum_without_cast")
	last_point_pos += move

func _push_position_down_array(l:Line2D):
	for x in range(0, count):
		var pos = l.get_point_position(x)
		l.set_point_position(x,Vector2(l.get_point_position(x + 1).x, pos.y))

func _change_last_point_pos(l:Line2D, line_pos:last_pos):
	var index = count
	l.set_point_position(index, Vector2(300 * line_pos, l.get_point_position(index).y))
	var pos := l.get_point_position(index)
	var i := PI / 2
	var mid = (pos.x - body.position.x) / 2
	for x in count:
		l.set_point_position(x, Vector2(sin(i) * -mid + pos.x - mid,-x * distance_points))
		i += PI / count

func play_autoplay(stream : SoundHolder, play : bool):
	if play:
		if !player_repeat.playing:
			player_repeat.stream = stream.stream
			player_repeat.volume_db = stream.volume
			player_repeat.play()
	else:
		if player_repeat.playing:
			player_repeat.stop()

func repeat_autoplay():
	player_repeat.play()

func return_body_position():
	return body.position + position

func return_accelerate():
	return body.speed_multi

func return_max_speed():
	return body.max_speed

func on_body_hit(d):
	var d1 = d - 1
	if !inv:
		match p_state:
			state.NORMAL:
				p_state = state.SHIELD_BROKEN
				shield_timer_reset_after_hit(3 + d1)
			state.SHIELD_RECHARGE:
				p_state = state.RECHARGE_HIT
				timer.stop()
				shield_timer_reset_after_hit(5 + d1 * 2)
				health_points -= d
				player_hit.play()
			state.SHIELD_BROKEN:
				p_state = state.BROKEN_HIT
				if d != 0:
					inv = true
					shield_timer_reset_after_hit(3.5)
				health_points -= d * 2
				player_hit_super.play()
			state.RECHARGE_HIT:
				return
			state.BROKEN_HIT:
				return
	else:
		print_rich("[hint=%s]Hit during invicibility[/hint]" % name)

func on_shield_recharge_end():
	print_rich("[hint=PlayerLine]Shield recharged[/hint]")
	p_state = state.NORMAL

func on_shield_recharge_start():
	print_rich("[hint=PlayerLine]Update timer[/hint]")
	inv = false
	p_state = state.SHIELD_RECHARGE
	timer_charge.start(3.5)
	body.return_shield_color()

func shield_timer_reset_after_hit(time:float):
	timer_charge.stop()
	timer.start(time)
	body.reset_shield_color()

func on_game_over():
	timer.stop()
	timer_charge.stop()
	lock_movement = true
	body.on_game_over()
