class_name ScoreManager extends Node

# Variables
var score : int
var coins : int
## Sounds stupid, but not game collected coins but GAME collected coins. Get it?
var coins_game : int

# Methods
func reset_score():
	score = 0
	coins = 0
	coins_game = 0

func finalize_level_score():
	score = 0
	coins = 0
	coins_game += coins

func add_coins(num : int):
	coins += num
