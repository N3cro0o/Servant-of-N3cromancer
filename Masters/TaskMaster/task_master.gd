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
			var t = SvM.load_task(i)
			if !t.completed:
				task_arr.push_back(t)
	if task_arr.size() < max_tasks:
		generate_new_task()
	index_tasks()
	save_tasks()

func save_tasks():
	for i in task_arr.size():
		SvM.save_task(task_arr[i], i)

# Tasks functions
func index_tasks():
	for i in task_arr.size():
		task_arr[i].id = i

func validate_tasks():
	for task in task_arr:
		match task.type:
			task.quest_type.Destroy:
				if task.y <= task.y_progress:
					complete_task(task)
			task.quest_type.SurviveTime:
				if task.x <= task.x_progress:
					complete_task(task)
			task.quest_type.SurviveMeters:
				if task.x <= task.x_progress:
					complete_task(task)
			task.quest_type.Score:
				if task.x <= task.x_progress:
					complete_task(task)
			task.quest_type.GetPickups:
				if task.y <= task.y_progress:
					complete_task(task)
	save_tasks()

func validate_task(id: int) -> bool:
	if id >= task_arr.size() && id < 0:
		return false
	match task_arr[id].type:
			TaskHolder.quest_type.Destroy:
				if task_arr[id].y <= task_arr[id].y_progress:
					return true
			TaskHolder.quest_type.SurviveTime:
				if task_arr[id].x <= task_arr[id].x_progress:
					return true
			TaskHolder.quest_type.SurviveMeters:
				if task_arr[id].x <= task_arr[id].x_progress:
					return true
			TaskHolder.quest_type.Score:
				if task_arr[id].x <= task_arr[id].x_progress:
					return true
			TaskHolder.quest_type.GetPickups:
				if task_arr[id].y <= task_arr[id].y_progress:
					return true
	return false

func complete_task(task: TaskHolder):
	task.completed = true
	SvM.save_task(task, task.id)
	task_arr.erase(task)
	ScM.coins_game += randi_range(10,20)
	SvM.update_tasks_completed(SvM.return_tasks_completed() + 1)

func fill():
	while task_arr.size() < max_tasks:
		generate_new_task()
	index_tasks()

func generate_new_task():
	var new_task = TaskHolder.new()
	new_task.type = randi_range(0, new_task.quest_type.size() - 1) # -1 because it's inclusive
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

func time_listener(time: int):
	for task in task_arr:
		if !task.type == task.quest_type.SurviveTime:
			continue
		task.x_progress = max(task.x_progress, time)

func distance_listener(dist: int):
	for task in task_arr:
		if !task.type == task.quest_type.SurviveMeters:
			continue
		task.x_progress += dist

func score_listener(score: int):
	for task in task_arr:
		if !task.type == task.quest_type.Score:
			continue
		task.x_progress = max(score, task.x_progress)

func after_level_listener(score = 0, dist = 0):
	distance_listener(dist)
	score_listener(score)
