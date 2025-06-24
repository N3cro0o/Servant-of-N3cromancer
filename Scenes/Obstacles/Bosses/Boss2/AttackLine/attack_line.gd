extends Sprite2D

@export var active = false
@export var time_to_end = 2.0
@export var size_line: CurveTexture
@onready var density: Sprite2D = $Density

var time_left = 0
var inverse_check = false
signal on_end_animation
signal on_inverse_request

# Basic Godot functions
func _ready() -> void:
	time_left = time_to_end

func _process(delta: float) -> void:
	if active && !GmM.paused: 
		if time_left <= 0:
			visible = false
			on_end_animation.emit()
			active = false
		if time_left/time_to_end <= 0.75 && !inverse_check:
			inverse_check = true
			on_inverse_request.emit()
		time_left -= delta
	density.scale.x = size_line.curve.sample(time_left/time_to_end)

func reset(time := 2.0):
	time_to_end = time
	time_left = time
	active = true
	visible = true
	inverse_check = false
