class_name ItemShopData extends Resource

const debug_text = "[hint=ItemShopData]Item %s bought at %s[/hint]"
const debug_text1 = "[hint=ItemShopData]Item %s bought failed at %s[/hint]"

enum category_shop {
	SKUL = 2,
	INVENTORY = 1,
	RANDOM = 90,
	ENDLESS = 0
}

@export_group("Basic")
@export var name : String = ""
@export var cost : int = 0
@export var image : Texture2D
@export_multiline var desc : String = ""
@export var category : category_shop = category_shop.RANDOM
@export_group("Script")
@export_enum("king_nothing", "endless_unlock", "light_skul_unlock",\
	"scroll_storag_upgrade", "custom_line") var resource_script = "king_nothing"
@export var variable1 = 0.0
@export var variable2 = 0.0
var bought = false

func on_buy():
	call(resource_script)
	bought = true

# But the castle's crumbled and you're left with just the name
func king_nothing():
	print("Where's your crown, King Nothing?")

func endless_unlock():
	GmM.endless_unlock = true

func light_skul_unlock():
	GmM.body_holder_array[variable1].body_unlocked = true

func scroll_storag_upgrade():
	GmM.inventory_space += int(variable1)
	GmM.inventory_space_single += int(variable2)
func custom_line():
	GmM.line_customization_unlock = true
