class_name ObstacleGravitySplitterChild extends ObstacleGravityBase

const SPLITTER_LEFT = preload("res://Images/Obstacles/Splitter/splitter_child_left.png")
const SPLITTER_RIGHT = preload("res://Images/Obstacles/Splitter/splitter_child_right.png")

func sprite_texture(side : int):
	var sprite = $Sprite2D as Sprite2D
	if side < 0:
		sprite.texture = SPLITTER_LEFT
	elif side > 0:
		sprite.texture = SPLITTER_RIGHT
