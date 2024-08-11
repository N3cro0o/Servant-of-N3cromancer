class_name ObstacleNonverticalTele extends ObstacleNonverticalBase

enum state {
	LEFT = -1,
	CENTER = 0,
	RIGHT = 1
}

@export_range(0, 1) var teleportation_chance = 0.33

var telep_positions = [-300, 0, 300]
var curr_position : state = state.CENTER
var iteration = 1

func _ready():
	super._ready()
	teleportation_chance = (1 - teleportation_chance) * 100
	for i in 3:
		telep_positions[i] = 540 + telep_positions[i]

func _physics_process(delta):
	super._physics_process(delta)
	if position.y > 775 * iteration:
		var i = randi_range(0, 100)
		if i > teleportation_chance:
			teleport()
		iteration += 1

func start_position(st : state):
	curr_position = st

func teleport():
	# Find teleportation spot
	var i = randi_range(0, 100)
	var b = false
	if i > 50:
		b = true
	match curr_position:
		state.LEFT:
			if b:
				curr_position = state.CENTER
				i = 1
			else:
				curr_position = state.RIGHT
				i = 2
		state.CENTER:
			if b:
				curr_position = state.LEFT
				i = 0
			else:
				curr_position = state.RIGHT
				i = 2
		state.RIGHT:
			if b:
				curr_position = state.CENTER
				i = 1
			else:
				curr_position = state.LEFT
				i = 0
	# Teleportation
	position.x = telep_positions[i]
