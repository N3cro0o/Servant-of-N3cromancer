class_name InventoryLogic extends Node
static var instance : InventoryLogic

#region Variables

@onready var repulsor_label = $"../RepulseButton/Vbox/NumberLabel"
@onready var shield_label = $"../ShieldButton/Vbox/NumberLabel"
var buttons_array : Array[TextureButton]
## Stores how many items player has
var max_items = 0
## Read how many active strolls buttons player can have
var active_scrolls = 0
var repulsions = 0:
	set(rep):
		repulsions = rep
		if repulsions > 0:
			show_button(0)
		else:
			hide_button(0)
var shields = 0:
	set(shl):
		shields = shl
		if shields > 0:
			show_button(1)
		else:
			hide_button(1)

#endregion

# Basic Godot functions
func _ready():
	instance = self
	print_rich("[hint=%s]Inventory space max = %d[/hint]" % [name, GmM.inventory_space])
	for i in range(1, get_parent().get_child_count()):
		buttons_array.push_back(get_parent().get_child(i))
		hide_button(i - 1)

func _process(_delta):
	repulsor_label.text = str(repulsions)
	shield_label.text = str(shields)

# UI buttons functions
func show_button(bttn_num : int):
	buttons_array[bttn_num].disabled = false
	buttons_array[bttn_num].get_child(0).visible = true
	var l = buttons_array[bttn_num].get_child(1).get_child(0) as RichTextLabel
	l.modulate = Color(Color.WHITE, 1)

func hide_button(bttn_num : int):
	buttons_array[bttn_num].disabled = true
	buttons_array[bttn_num].get_child(0).visible = false
	var l = buttons_array[bttn_num].get_child(1).get_child(0) as RichTextLabel
	l.modulate = Color(Color.WHITE, 0)

# Scroll buttons logic functions
func repulse_add():
	if scrolls_all() < GmM.inventory_space && repulsions < GmM.inventory_space_single:
		repulsions += 1
		show_button(0)
		return true
	return false

func repulse_use():
	if repulsions == 0:
		return
	repulsions -= 1
	for ob in GameScene.instance.obstacles_array:
		ob.repulse(500)

func shield_add():
	if scrolls_all() < GmM.inventory_space && shields < GmM.inventory_space_single:
		shields += 1
		show_button(1)
		return true
	return false

func shield_use():
	if shields == 0:
		return
	shields -= 1
	var b = PlayerLine1.instance.body as PlayerBody
	b.return_shield_color()
	PlayerLine1.instance.p_state = PlayerLine1.instance.state.NORMAL

func scrolls_all() -> int:
	return repulsions + shields
