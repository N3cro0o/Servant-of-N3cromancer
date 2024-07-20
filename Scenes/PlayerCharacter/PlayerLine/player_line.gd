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
@export var distance_points := 0.0
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
@onready var body := $PlayerCharacter
@onready var line2 := $AdditionalLine
@onready var line_r = $HelpLines/LineR
@onready var line_l = $HelpLines/LineL
@onready var timer = $ShieldTimer1
@onready var timer_charge = $ShieldTimer2
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

## Remember to ALWAYS change heath before update p_state var
var p_state : state = state.NORMAL:
	set(s):
		p_state = s
		on_player_status_change.emit(s, health_points)
		if(health_points <= 0):
			on_player_death.emit()
var count : int
var left_line_pos := last_pos.LEFT
var right_line_pos := last_pos.RIGHT
var inv := false
var target_pos : Vector2
var offset := 0.0
var velocity := 0.0

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
	count = get_point_count() - 1
	var _i :=  PI / 2
	for x in count + 1:
		set_point_position(x, Vector2(0, -x * distance_points))
		line_r.set_point_position(x, Vector2(500, -x * distance_points))
		line_l.set_point_position(x, Vector2(-500, -x * distance_points))
		_i += 2 * PI / count

func _process(_delta):
	# Heath logic
	if p_state == state.RECHARGE_HIT:
		p_state = state.SHIELD_BROKEN
	elif p_state == state.BROKEN_HIT:
		p_state = state.SHIELD_BROKEN
	# Angle calcs
	var vec : Vector2 = get_point_position(count) - body.position
	var a = vec.angle() + PI/2
	skul_dir = a
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
	line_r.set_point_position(125, Vector2(point_vec.x, point_vec.y - 2000))
	point_vec = line_l.get_point_position(get_point_count() - 2)
	line_l.set_point_position(125, Vector2(point_vec.x, point_vec.y - 2000))
	# Pushing down position
	_push_position_down_array(self)
	_push_position_down_array(line_l)
	_push_position_down_array(line_r)
	# Body and changing line curve
	target_pos = get_point_position(20) # 21th point cuz there's some buffer space while dtaping one dir
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

func return_body_position():
	return body.position + position

func on_body_hit(d):
	# Add 0 damage logic, it doesn't work properly
	if !inv:
		match p_state:
			state.NORMAL:
				p_state = state.SHIELD_BROKEN
				shield_timer_reset_after_hit(2.5)
			state.SHIELD_RECHARGE:
				health_points -= d
				p_state = state.RECHARGE_HIT
				shield_timer_reset_after_hit(1.5)
			state.SHIELD_BROKEN:
				health_points -= d * 2
				p_state = state.BROKEN_HIT
				if d != 0:
					inv = true
			state.RECHARGE_HIT:
				return
			state.BROKEN_HIT:
				return
	else:
		print_rich("[hint=%s]Hit during invicibility[/hint]" % name)

func on_shield_recharge_end():
	print_rich("[hint=PlayerLine]Shield recharged[/hint]")
	p_state = state.NORMAL
	inv = false

func on_shield_recharge_start():
	print_rich("[hint=PlayerLine]Update timer[/hint]")
	p_state = state.SHIELD_RECHARGE
	timer_charge.start(3.5)
	body.return_shield_color()

func shield_timer_reset_after_hit(time:float):
	timer_charge.stop()
	timer.start(time)
	body.reset_shield_color()
