@tool
class_name PauseItem extends CenterContainer

#region Variables

@export var image_texture: Texture2D:
	set(t):
		image_texture = t
		if image != null:
			image.texture = t
@export var body_text: String:
	set(s):
		body_text = s
		if text != null:
			text.text = s

@onready var image: TextureRect = $Box/Image
@onready var text: RichTextLabel = $Box/Text
@onready var value: RichTextLabel = $Box/Value

#endregion

# Basic Godot functions
func _ready() -> void:
	text.text = body_text
	image.texture = image_texture

# Value functions
func set_value(_value: String):
	value.text = _value
