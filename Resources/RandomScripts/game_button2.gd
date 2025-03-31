@tool
extends Button

#region Variables
@export var image : TextureRect
@export var click_image: TextureRect
@export var action : StringName
var tween: Tween
var tween_color: Tween
#endregion

# Base Godot functions
func _process(_delta):
	if image != null:
		image.pivot_offset = Vector2(size.x/2, size.y/2)
		image.size = size
	if click_image != null:
		click_image.pivot_offset = Vector2(size.x/2, size.y/2)
		click_image.size = size

# Signal functions
func on_button_update():
	pass

func on_button_pressed():
	if click_image != null:
		click_image.visible = true
		image.modulate = Color("cfdaec")
		click_image.modulate = Color("ffffff32")
		if tween != null:
			tween.kill()
		if tween_color != null:
			tween_color.kill()
		tween = get_tree().create_tween()
		tween.tween_property(click_image, "modulate:a", 0, 0.3)
		tween_color = get_tree().create_tween()
		tween_color.tween_property(image, "modulate", Color.WHITE, 0.2)
		await tween.finished
		click_image.visible = false
