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
	coins_game += coins
