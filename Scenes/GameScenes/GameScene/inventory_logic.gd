class_name InventoryLogic extends Node

static var instance : InventoryLogic

@onready var repulsor_label = $"../RepulseButton/Vbox/NumberLabel"
@onready var shield_label = $"../ShieldButton/Vbox/NumberLabel"

var buttons_array : Array[TextureButton]
var max_items = 0
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

func _ready():
	instance = self
	max_items = GmM.inventory_space
	print_rich("[hint=%s]Inventory space max = %d[/hint]" % [name, max_items])
	for i in range(1, get_parent().get_child_count()):
		buttons_array.push_back(get_parent().get_child(i))
		hide_button(i - 1)

func _process(_delta):
	repulsor_label.text = str(repulsions)
	shield_label.text = str(shields)

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

#region Scroll Buttons

func repulse_add():
	if repulsions < max_items:
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
	if shields < max_items:
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

#endregion
