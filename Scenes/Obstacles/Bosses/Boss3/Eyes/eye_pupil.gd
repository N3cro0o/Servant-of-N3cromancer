class_name SapperEyePupil extends SapperEye

func look_at_object(node: Node2D):
	var p = (node.global_position - global_position).normalized()
	$Pupil.position = p * 8
