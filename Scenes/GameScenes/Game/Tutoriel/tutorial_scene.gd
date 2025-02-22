@icon("res://Images/meme/kapix.jpg")
class_name TutorialScene extends GameScene

#region Variables

var tutorial_stage = 0:
	set(toriel):
		if toriel < 0:
			return
		tutorial_stage = toriel

#endregion

func _ready() -> void:
	super._ready()
	spawner.force_active = false

func _process(delta: float) -> void:
	super._process(delta)

func stage_1():
	pass
