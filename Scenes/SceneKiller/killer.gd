class_name Killer extends Area2D
# Variables
@export var xd = {
	"obstacle": false,
}
# Signals

# Methods
func something_entered(entity:Node2D):
	if(entity.is_in_group("obstacle")):
		entity.queue_free()
