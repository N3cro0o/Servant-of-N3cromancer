@tool
extends Button

#region Variables
@export var image : TextureRect
@export var action : StringName
var unpressed_image : Texture2D = preload("res://Images/UI/DirectionKey/1/arrow key1.png")
var pressed_image : Texture2D = preload("res://Images/UI/DirectionKey/1/arrow key2.png")
#endregion
#region Methods
func _process(_delta):
	image.pivot_offset = Vector2(size.x/2, size.y/2)
	image.size = size

func on_button_update():
	if button_pressed:
		image.texture = pressed_image
	else:
		image.texture = unpressed_image

func on_button_pressed():
	pass
#endregion
