class_name PickUpRepulsor extends PickUpLogicTemplate

#region Methods
func _do_action():
	if InventoryLogic.instance.repulse_add():
		return
	for ob in GameScene.instance.obstacles_array:
		ob.repulse(500)
#endregion
