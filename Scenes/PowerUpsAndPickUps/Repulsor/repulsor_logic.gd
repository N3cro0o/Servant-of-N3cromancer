extends PickUpLogicTemplate
#region Methods
func _do_action():
	for ob in GameScene.instance.obstacles_array:
		ob.repulse(500)
#endregion
