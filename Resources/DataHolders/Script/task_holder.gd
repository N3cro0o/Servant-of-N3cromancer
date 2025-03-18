class_name TaskHolder extends Resource

## Describes type of [code]TaskHolder[/code] resource.
enum quest_type{
	Destroy, 
	SurviveTime,
	SurviveMeters,
	Score,
	GetPickups
	}

## Current [b]resource[/b] type
@export var type: quest_type = quest_type.Score
# Task variables
##First variable:
##[br][code]quest_type.Destroy[/code]: Enemy ID
##[br][code]quest_type.SurviveTime[/code]: Time in seconds
##[br][code]quest_type.SurviveMeters[/code]: Distance in meters
##[br][code]quest_type.Score[/code]: Score to get
##[br][code]quest_type.Plays[/code]: Pickup ID
@export var x: int
@export var x_progress: int
##Second variable:[ul]
##[br][code]quest_type.Destroy[/code]: Number of [i]kills[/i]
##[br][code]quest_type.Plays[/code]: Number of [i]pick ups[/i]
@export var y: int
@export var y_progress: int
