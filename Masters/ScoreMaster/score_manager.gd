class_name ScoreManager extends Node

# Variables
var score : int
var highscore : int
var coins : int
var distance : float
## Sounds stupid, but not game collected coins but GAME collected coins. Get it?
var coins_game : int

signal on_new_highscore

# Methods
func reset_score():
	score = 0
	coins = 0
	distance = 0

func finalize_level_score():
	var s : int = 0
	s = int(distance / 50)
	highscore += s
	coins_game += coins
	if highscore < score:
		highscore = score
		on_new_highscore.emit()
	SvM.update_score(coins_game, highscore)
	score = 0
	coins = 0

func add_coins(num : int):
	coins += num
