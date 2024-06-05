extends PickUpLogicTemplate

func _do_action():
	ScM.add_coins(1)
	print_rich("[hint=%s]Coins: %d[/hint]" % ["Polski złoty", ScM.coins])
