extends Control

#region Variables

# Outputs
@onready var text_name = $Margin/Box/Up/Box/TextName
@onready var texture = $Margin/Box/Up/Box/Texture
@onready var text_desc = $Margin/Box/Down/BoxOuter/TextDesc
# Inputs
@onready var buy = $Margin/Box/Down/BoxOuter/Box/Control/Buy
@onready var left = $Margin/Box/Down/BoxOuter/Box/Control/Buttons/Left
@onready var right = $Margin/Box/Down/BoxOuter/Box/Control/Buttons/Right

var items_array : Array[ItemShopData]
var texture_array : Array[Texture2D]
var current_item_index = 0
#endregion
#region Methods
func _ready():
	items_array = GmM.items
	if items_array.size() == 0 or items_array[0] == null:
		GmM.change_scene(0)
		return
	var item = items_array[0]
	text_name.text = "[center]%s[/center]" % item.name
	text_desc.text = "[center]%s[/center]" % item.desc
	texture.texture = item.image

func return_button_pressed():
	GmM.change_scene(0)

func _notification(what):
	# Return to Main Menu
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		GmM.change_scene(0)
#endregion
