class_name SapperEye extends Node2D

func look_at_object(node: Node2D):
	rotation = (node.global_position - global_position).angle() + PI/2
