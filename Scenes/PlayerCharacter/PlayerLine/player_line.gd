extends Line2D
class_name PlayerLine1
enum last_pos {
	LEFT = -1,
	MIDDLE = 0,
	RIGHT = 1
}
# Variables
@export var distance_points := 0.0
@export var last_point_pos := last_pos.MIDDLE:
	set(x):
		last_point_pos = x
		_change_last_point_pos()
@onready var body := $PlayerCharacter
@onready var line2 := $AdditionalLine
var count : int

# Signals
signal on_player_hit

# Methods
func _ready():
	count = get_point_count() - 1
	var _i :=  PI / 2
	for x in count + 1:
		set_point_position(x, Vector2(0, -x * distance_points))
		_i += 2 * PI / count

func _process(_delta):
	var point_vec = get_point_position(get_point_count() - 1)
	line2.set_point_position(0, point_vec)
	line2.set_point_position(1, Vector2(point_vec.x, point_vec.y - 2000))
	_push_position_down_array()
	body.position.x = get_point_position(0).x
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

func _push_position_down_array():
	for x in range(0, count):
		var pos = get_point_position(x)
		set_point_position(x,Vector2(get_point_position(x + 1).x, pos.y))

func _change_last_point_pos():
	var index = count
	set_point_position(index, Vector2(300 * last_point_pos, get_point_position(index).y))
	var pos := get_point_position(index)
	var i := PI / 2
	var mid = (pos.x - body.position.x) / 2
	for x in count:
		set_point_position(x, Vector2(sin(i) * -mid + pos.x - mid,-x * distance_points))
		i += PI / count

func return_body_position():
	return body.position + position

func on_body_hit():
	on_player_hit.emit()
