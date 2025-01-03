extends Control

#region Variables
@onready var logic = $LogicNode

# Outputs
@onready var text_name = $Margin/Box/Up/Box/TextName
@onready var texture = $Margin/Box/Up/Box/Texture
@onready var text_desc = $Margin/Box/Down/BoxOuter/TextDesc
@onready var text_coins = $Margin/Box/Down/BoxOuter/CoinsBox/TextCoins
# Inputs
@onready var buy = $Margin/Box/Down/BoxOuter/Box/Buy
@onready var left = $Margin/Box/Down/BoxOuter/Box/Control/Buttons/Left
@onready var right = $Margin/Box/Down/BoxOuter/Box/Control/Buttons/Right

var items_array : Array[ItemShopData]
var current_item_index = 0
var item : ItemShopData
var cost = 0
var buy_button_start_pos : Vector2
var shake_check = false
#endregion

#region Methods
func _ready():
	items_array = GmM.items
	if items_array.size() == 0 or items_array[0] == null:
		GmM.change_scene(0)
		return
	change_current_item(0)

func _process(_delta):
	text_coins.text = "%d" % ScM.coins_game

func cycle_items(num : int):
	var arr_size = items_array.size()
	current_item_index += num
	if current_item_index < 0:
		current_item_index = arr_size - 1
	elif current_item_index >= arr_size:
		current_item_index = 0
	change_current_item(current_item_index)
	Sfx.play_sound_ui_number(0)

func on_buy():
	if !shake_check and !item.bought:
		if ScM.coins_game >= cost:
			ScM.coins_game -= cost
			print_rich(ItemShopData.debug_text % [item.name, Time.get_time_dict_from_system()])
			item.on_buy()
			GmM.items[current_item_index].bought = true
			items_array[current_item_index].bought = true
			SvM.update_upgrade_shop_bought(current_item_index)
			change_current_item(current_item_index)
		else:
			print_rich(ItemShopData.debug_text1 % [item.name, Time.get_time_dict_from_system()])
			shake_buy_button()
	Sfx.play_sound_ui_number(0)

func shake_buy_button():
	shake_check = true
	if buy_button_start_pos == Vector2.ZERO:
		buy_button_start_pos = buy.position
	else:
		buy.position = buy_button_start_pos
	for i in 5:
		buy.position.x += 10
		await Engine.get_main_loop().process_frame
	for i in 10:
		buy.position.x -= 10
		await Engine.get_main_loop().process_frame
	while abs(buy.position.x - buy_button_start_pos.x) > 5:
		buy.position = lerp(buy.position, buy_button_start_pos, 0.05)
		await Engine.get_main_loop().process_frame
	buy.position = buy_button_start_pos
	shake_check = false

func return_button_pressed():
	GmM.change_scene(0)
	Sfx.play_sound_ui_number(0)

func change_current_item(num : int):
	current_item_index = num
	item = items_array[num]
	cost = item.cost
	text_name.text = "[center]%s[/center]" % [item.name]
	text_desc.text = "[center]%s[/center]" % item.desc
	texture.texture = item.image
	if item.bought:
		texture.self_modulate = Color(1, 0.498, 0.494, 0.9)
		buy.text = "Bought"
	else:
		texture.self_modulate = Color(1, 1, 1, 1)
		buy.text = "Cost: %d" % cost
	logic.set_script(item.resource_script)

func _notification(what):
	# Return to Main Menu
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		return_button_pressed()
#endregion
