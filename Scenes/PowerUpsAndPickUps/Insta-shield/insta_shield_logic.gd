class_name PickUpInstaShield extends PickUpLogicTemplate

#region Methods
func _do_action():
	if InventoryLogic.instance.shield_add():
		return
	var b = PlayerLine1.instance.body as PlayerBody
	b.return_shield_color()
	PlayerLine1.instance.p_state = PlayerLine1.instance.state.NORMAL
#endregion
