class_name TutorialEntry extends HBoxContainer

#region Variables

@export var inverted_layout = false:
	set(b):
		if b != inverted_layout:
			change_child_order()
		inverted_layout = b
@export_group("Label")
@export_multiline var text : String

@export_group("Icon")
@export var image : Texture2D

@onready var lbl_node = $Label
@onready var img_node = $Image

#endregion

# Basic Godot functions
func _ready():
	if text != null and image != null:
		img_node.texture = image
		lbl_node.text = text

# Child objects functions
func change_child_order():
	if !inverted_layout:
		move_child($Image, 0)
	else:
		move_child($Label, 0)
