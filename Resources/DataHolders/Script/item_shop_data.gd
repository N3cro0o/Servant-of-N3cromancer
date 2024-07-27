class_name ItemShopData extends Resource

const debug_text = "[hint=ItemShopData]Item %s bought at %s[/hint]"
const debug_text1 = "[hint=ItemShopData]Item %s bought failed at %s[/hint]"

@export_group("Basic")
@export var name : String = ""
@export var cost : int = 0
@export var image : Texture2D
@export_multiline var desc : String = ""
@export_group("Script")
@export_enum("king_nothing", "endless_unlock", "light_skul_unlock",\
	"scroll_storag_upgrade") var resource_script = "king_nothing"
var bought = false

func on_buy():
	call(resource_script)
	bought = true

func king_nothing():
	print("Where's your crown, King Nothing?")

func endless_unlock():
	GmM.endless_unlock = true

func light_skul_unlock():
	pass
