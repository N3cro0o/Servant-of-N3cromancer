extends Area2D
# Variables

# Signals
signal on_hit
# Methods
func _on_body_entered(_body):
	on_hit.emit()
