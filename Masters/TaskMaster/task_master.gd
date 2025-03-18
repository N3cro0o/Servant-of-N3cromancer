class_name TaskMaser extends Node

@export_range(0, 10) var max_tasks = 3
@export_group("Arrays")
@export var task_arr: Array[TaskHolder]:
	set(arr):
		if task_arr.size() < max_tasks:
			task_arr = arr
			for i in task_arr.size():
				SvM.save_task(task_arr[i], i)
# Basic Godot functions

# Save/Load functions
func setup():
	for i in max_tasks:
		if SvM.check_task(i):
			task_arr.push_back(SvM.load_task(i))
	
	while task_arr.size() < max_tasks:
		generate_new_task()
	
	save_tasks()

func save_tasks():
	for i in task_arr.size():
		SvM.save_task(task_arr[i], i)

# Tasks functions
func validate_tasks():
	for task in task_arr:
		match task.type:
			task.quest_type.Destroy:
				pass
			task.quest_type.SurviveTime:
				pass
			task.quest_type.SurviveMeters:
				pass
			task.quest_type.Score:
				pass
			task.quest_type.GetPickups:
				pass

func generate_new_task():
	var new_task = TaskHolder.new()
	new_task.type = randi_range(0, new_task.quest_type.size())
	match new_task.type:
		new_task.quest_type.Destroy:
			var data: SpawnObstacleDataHolder = GmM.obstacle_arr.pick_random()
			while data.type == 4:
				data = GmM.obstacle_arr.pick_random()
			new_task.x = data.obstacle_id
			new_task.y = randi_range(20, 100)
		new_task.quest_type.SurviveTime:
			new_task.x = randi_range(0, 12) * 10 + 60
		new_task.quest_type.SurviveMeters:
			new_task.x = randi_range(0, 11) * 200 + 800
		new_task.quest_type.Score:
			new_task.x = randi_range(0, 10) * 20 + 100
		new_task.quest_type.GetPickups:
			var data: SpawnPickupDataHolder = GmM.pickup_arr.pick_random()
			new_task.x = data.pickup_id
			new_task.y = randi_range(10, 30)
	task_arr.push_back(new_task)

func obstacle_listener(id: int):
	for task in task_arr:
		if !task.type == task.quest_type.Destroy:
			continue
		if task.x == id:
			task.y_progress += 1

func pickup_listener(id: int):
	for task in task_arr:
		if !task.type == task.quest_type.GetPickups:
			continue
		if task.x == id:
			task.y_progress += 1
