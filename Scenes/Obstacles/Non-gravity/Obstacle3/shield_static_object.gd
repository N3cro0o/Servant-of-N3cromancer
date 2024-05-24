extends ObstacleNonverticalBase

# Variables
@onready var left = $Left
@onready var right = $Right
@onready var mid_array : Array[AnimatedSprite2D] = [$"Mid/1",$"Mid/2",$"Mid/3"]
var frame = 0

func _process(_delta):
	frame += 1
	if frame < 6:
		return
	var f1 = randi_range(0, 2)
	left.frame = f1
	f1 = randi_range(0, 2)
	right.frame = f1
	var f2
	for s in mid_array:
		f2 = randi_range(0, 3)
		s.frame = f2
	frame = 0

func on_player_body_hit(b: Area2D):
	if b.is_in_group("mainbody") and PlayerLine1.instance.inv == true:
		PlayerLine1.instance.shield_timer_reset_after_hit(2.5)
		PlayerLine1.instance.inv = false
		# Check if player is immune. It's safer this way, no double shield breaks
		print_rich(debug_string % [name, "Gravity shift hit body"])
