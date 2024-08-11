class_name Killer extends Area2D
# Variables

# Signals

# Methods
func something_entered(entity:Node2D):
	if(entity.is_in_group("obstacle")):
		if entity.is_in_group("delete_logic"):
			entity.lock_delete_logic = true
		entity.queue_free()
