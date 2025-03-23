class_name TaskHolder extends Resource

## Describes type of [code]TaskHolder[/code] resource.
enum quest_type
{
	Destroy, 
	SurviveTime,
	SurviveMeters,
	Score,
	GetPickups
}

## Current [b]resource[/b] type
@export var type: quest_type = quest_type.Score
@export var completed: bool = false
@export var rerolled: bool = false
# Task variables
##First variable:
##[br][code]quest_type.Destroy[/code]: Enemy ID
##[br][code]quest_type.SurviveTime[/code]: Time in seconds
##[br][code]quest_type.SurviveMeters[/code]: Distance in meters
##[br][code]quest_type.Score[/code]: Score to get
##[br][code]quest_type.GetPickups[/code]: Pickup ID
@export var x: int
@export var x_progress: int
##Second variable:[ul]
##[br][code]quest_type.Destroy[/code]: Number of [i]kills[/i]
##[br][code]quest_type.GetPickups[/code]: Number of [i]pick ups[/i]
@export var y: int
@export var y_progress: int

var id: int

func task_name() -> String:
	var name: String 
	match type:
		quest_type.Destroy:
			name = "Destroy obstacles"
		quest_type.SurviveTime:
			name = "Time survival"
		quest_type.SurviveMeters:
			name = "Travel distances"
		quest_type.Score:
			name = "Get score"
		quest_type.GetPickups:
			name = "Find pickups"
	return name

func task_desc() -> String:
	var desc: String 
	match type:
		quest_type.Destroy:
			var name: String
			for obs in GmM.obstacle_arr:
				if obs.obstacle_id == x:
					name = obs.name
			return "Destroy or avoid %s obstacle %d/%d times" % [name, y_progress, y]
		quest_type.SurviveTime:
			return "Survive during one run for more than %d seconds" % [x]
		quest_type.SurviveMeters:
			return "Travel for %d/%d meters over multiple runs" % [x_progress, x]
		quest_type.Score:
			return "Get score equal or better than %d" % [x]
		quest_type.GetPickups:
			var name: String
			for pick in GmM.pickup_arr:
				if pick.pickup_id == x:
					name = "%s %s" % [pick.name, PickUpBase.pickup_type_enum.find_key(pick.type)]
			return "Find and collect %s pickup %d/%d times" % [name, y_progress, y]
		_:
			return ""
