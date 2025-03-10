class_name SpawnerBasicV2 extends Node2D

const PICKUP_PATH = "res://Scenes/PowerUpsAndPickUps/Base/pick_up_base.tscn"
const PICKUP_BASE = preload(PICKUP_PATH)

#region Variables
@export var active = false:
	set(b):
		if !force_active:
			active = false
			return
		if obstacle_data != null:
			active = b
			for timer in spawn_timer_arr:
				timer.paused = false
		if !b:
			active = false
			for timer in spawn_timer_arr:
				timer.paused = true
## Enables checking for repeating obstacles and changing for random one.
@export var repeat_check = true
@export_range(0, 5) var spawn_delay = 3.0
## Minimum weight needed for no-repeating
@export var weight_threshold = 3
@export_range(0.0, 0.6) var pickup_chance := 0.1
@export_group("Spawn Points")
@export_range(1, 5) var spawn_points: int = 1:
	set(points):
		spawn_points = points
		if is_node_ready():
			update_spawners()
@export var distance_between: float = 0:
	set(dist):
		distance_between = dist
		if is_node_ready():
			update_spawners()
@export var spawner_offset := Vector2.ZERO:
	set(vec):
		spawner_offset = vec
		if is_node_ready():
			update_spawners()

@onready var spawn_points_arr: Array[Node2D] = [
	$"Spawners/1", $"Spawners/2", $"Spawners/3", $"Spawners/4", $"Spawners/5"]
@onready var spawn_timer_arr: Array[Timer] = [$"1", $"2", $"3", $"4", $"5"]

## Variable used to *force* spawner to be disabled. True is normal value
var force_active := true:
	set(active_bool):
		force_active = active_bool
		if !active_bool:
			active = active_bool
var spawn_weight: Array[int] = [0,0,0,0,0]
var spawn_static_check: Array[int] = [0,0,0,0,0]
var spawn_repeat_check: Array[String] = ["","","","",""]
var obstacle_data: StageEnemyData
var pickup_weight = 0
var pickup_spawn_check: Array[bool] = [true, true, true, true, true]
# Scenes vars
var packed_scenes_array: Array[PackedScene]
var other_scenes_array: Array[PackedScene]
var boss_scenes_array: Array[PackedScene]
#endregion
#region Signals

signal on_spawned_entity

#endregion
# Basic Godot functions
func _ready():
	if GameScene.instance != null:
		# Wait for level inicialization
		await GameScene.instance.on_level_start
	GmM.on_paused.connect(on_paused)
	GmM.on_slow_mo.connect(on_game_slow_mo)
	update_spawners()

func _physics_process(_delta: float):
	if GameScene.instance != null:
		for point in spawn_points_arr:
			var rotation_vec = point.position - GameScene.instance.return_player_pos()
			var angle = atan2(rotation_vec.y, rotation_vec.x)
			point.rotation = angle - deg_to_rad(90)

# Spawn point functions
func set_obstacle_data(data: StageEnemyData):
	obstacle_data = data
	spawn_points = data.spawn_points
	active = true
	update_packed_scenes()
	for i in spawn_points:
		start_timer_rand(i, 1.5)

func update_spawners():
	for i in 5:
		if i < spawn_points:
			spawn_points_arr[i].visible = true
		else:
			spawn_points_arr[i].visible = false
	update_position()

func update_position():
	var offset = 0
	if spawn_points % 2 == 0:
		var half_offset = distance_between / 2
		offset = half_offset
		for i in 5:
			spawn_points_arr[i].position = position + spawner_offset + Vector2(offset, 0)
			if offset > 0:
				offset = -offset
			else:
				offset = half_offset + distance_between * (i / 2 + 1)
	else:
		offset = 0
		for i in 5:
			spawn_points_arr[i].position = position + spawner_offset + Vector2(offset, 0)
			if offset > 0:
				offset = -offset
			else:
				offset = distance_between * (i / 2 + 1)

# Spawning functions
func update_packed_scenes():
	# Can live without it, just resize other arrays
	packed_scenes_array.resize(0)
	other_scenes_array.resize(0)
	boss_scenes_array.resize(0)
	spawn_weight = [0,0,0,0,0]
	var scene_holder: Array[String] = []
	var other_holder: Array[String] = []
	var result := []
	result = _add_packed_scenes(0, obstacle_data.data_1, scene_holder, other_holder)
	scene_holder = result[0]; other_holder = result[1]
	result = _add_packed_scenes(1, obstacle_data.data_2, scene_holder, other_holder)
	scene_holder = result[0]; other_holder = result[1]
	result = _add_packed_scenes(2, obstacle_data.data_3, scene_holder, other_holder)
	scene_holder = result[0]; other_holder = result[1]
	result = _add_packed_scenes(3, obstacle_data.data_4, scene_holder, other_holder)
	scene_holder = result[0]; other_holder = result[1]
	result = _add_packed_scenes(4, obstacle_data.data_5, scene_holder, other_holder)
	scene_holder = result[0]; other_holder = result[1]
	print_rich("[hint=%s]Packed count = %d[/hint]" % [name, packed_scenes_array.size()])
	# Boss
	for boss in obstacle_data.bosses:
		boss.spawner_index = boss_scenes_array.size()
		var scene = load(boss.scene_directory)
		boss_scenes_array.push_back(scene)
	# Pickup
	for pickup in obstacle_data.pickups:
		pickup_weight += pickup.weight

func _add_packed_scenes(num: int, data_arr, scene_holder, other_holder):
	for i: SpawnObstacleDataHolder in data_arr:
		var index
		if i.type == 3:
			index = other_holder.find(i.resource_path)
			if index == -1:
				other_holder.push_back(i.resource_path)
				var scene = load(i.scene_directory)
				i.spawner_index = other_scenes_array.size()
				other_scenes_array.push_back(scene)
			else:
				i.spawner_index = index
		else:
			index = scene_holder.find(i.resource_path)
			if index == -1:
				scene_holder.push_back(i.resource_path)
				var scene = load(i.scene_directory)
				i.spawner_index = packed_scenes_array.size()
				packed_scenes_array.push_back(scene)
			else:
				i.spawner_index = index
		spawn_weight[num] += i.weight
	return [scene_holder, other_holder]

func start_timer_rand(num: int, extra_delay: float):
	var diff_delay = 0
	if GameScene.instance != null:
		diff_delay = GameScene.instance.difficulty / 20
	var f = randf_range(-spawn_delay * 0.1_2137, spawn_delay * 0.1_2137)
	spawn_timer_arr[num].start((spawn_delay + f) * extra_delay - diff_delay)

func spawn_from(num: int):
	# Check if active
	if !active:
		return
	# Connecting to the game
	match num:
		0:
			spawn_logic(num, obstacle_data.data_1)
		1:
			spawn_logic(num, obstacle_data.data_2)
		2:
			spawn_logic(num, obstacle_data.data_3)
		3:
			spawn_logic(num, obstacle_data.data_4)
		4:
			spawn_logic(num, obstacle_data.data_5)
	spawn_pickup(num)
	# Restart pickups
	if pickup_spawn_check.count(false) >= 3:
		for p in pickup_spawn_check:
			p = true
	start_timer_rand(num, 1)
	# Add small delay to others
	for timer_index in obstacle_data.spawn_points:
		var timer = spawn_timer_arr[timer_index]
		if timer.time_left < 0.33:
			var t = timer.time_left
			timer.start(0.2)
	pass

func spawn_logic(num, data_arr):
	var cur_weight = 0
	var target_weight = randi_range(0,spawn_weight[num])
	var scene_data: SpawnObstacleDataHolder
	var scene_to_spawn: PackedScene
	var found := false
	var other_arr:Array[SpawnObstacleDataHolder] = []
	for data: SpawnObstacleDataHolder in data_arr:
		if !found:
			if data.weight + cur_weight >= target_weight:
				scene_data = data
				found = true
			cur_weight += data.weight
		if data.type == 3:
			other_arr.push_back(data)
	
	assert(scene_data != null)
	
	# Repeat check
	if scene_data.resource_path == spawn_repeat_check[num] && repeat_check:
		if randf() >= 0.5:
			scene_data = get_other_non_other(data_arr, scene_data.resource_path)
	
	# Check static
	if scene_data.type == 1:
		match spawn_static_check[num]:
			0:
				for i in spawn_static_check.size():
					if spawn_static_check[i] < 2 and i < spawn_points:
						spawn_static_check[i] += 1
						if scene_data.spawner_is_empty:
							spawn_static_check[i] += 1
					
			1: # Check if not too chonkers
				if scene_data.spawner_is_empty:
					scene_data = get_other_non_static(data_arr)
					for i in spawn_static_check.size():
						if i < spawn_points:
							spawn_static_check[i] = 2
				else:
					for i in spawn_static_check.size():
						if i < spawn_points:
							spawn_static_check[i] = 2
					if randf() > 0.65:
						scene_data = get_other_non_static(data_arr)
			_:
				scene_data = get_other_non_static(data_arr)
	else:
		# Decrease static check by one IF not static was found!!!
		spawn_static_check[num] = 0
		
	# Check weight and in case when it's too chonky, save it for later
	if scene_data.weight >= weight_threshold:
		spawn_repeat_check[num] = scene_data.resource_path
	# Instantiate
	if scene_data.type == 3: # Other
		scene_data = other_arr.pick_random()
		scene_to_spawn = other_scenes_array[scene_data.spawner_index]
	else:
		scene_to_spawn = packed_scenes_array[scene_data.spawner_index]
	# Increase difficulty
	GameScene.instance.difficulty += float(scene_data.weight) / 80
	spawn(num, scene_to_spawn.instantiate(), scene_data)

func spawn_boss_logic():
	var boss_data = obstacle_data.bosses.pick_random()
	return spawn(0,  boss_scenes_array[boss_data.spawner_index].instantiate(), boss_data)

func spawn(num, object: ObstacleGravityBase, data: SpawnObstacleDataHolder):
	if(GameScene.instance != null):
		GameScene.instance._add_obstacle(object)
	else:
		$Obstacles.add_child(object)
	# Basic stuff
	object.position = spawn_points_arr[num].position
	object.add_start_velocity(Vector2(0,-20) * GmM.game_speed, spawn_points_arr[num].rotation)
	object.player_body = PlayerLine1.instance
	on_spawned_entity.emit()
	# Tags
		# Flips
	if num % 2 == 1 and data.flip:
		object.scale.x = -object.scale.x
		# Rotation
	object.can_lock_rotation = data.can_lock_rotation
		# ObstacleNonverticalTele
	if data.tele_state:
		object = object as ObstacleNonverticalTele
		object.position = position + spawner_offset
		object.curr_position = 0
	# Return pointer to instance
	return object

func get_other_non_static(data_arr) -> SpawnObstacleDataHolder:
	# Set up non static, non other array of scenes
	var non_static_arr := []
	for data in data_arr:
		if data.type != 1 and data.type != 3:
			non_static_arr.push_back(data)
	# Get random one
	var scene = non_static_arr.pick_random()
	return scene

func get_other_non_other(data_arr: Array[SpawnObstacleDataHolder], path) -> SpawnObstacleDataHolder:
	var copy := data_arr.duplicate()
	var id
	# Find and remove used data
	for i in data_arr.size():
		if data_arr[i].resource_path == path:
			id = i
			break
	copy.remove_at(id)
	# Get random one, ignore weight. Add later
	var scene = copy.pick_random()
	return scene

# Pickup spawning functions
func spawn_pickup(num):
	if randf() > pickup_chance:
		return
	# Set 
	var pickup_data: SpawnPickupDataHolder
	var current_weight = 0
	var target_weight = randi_range(0, pickup_weight)
	# Get random pickup
	for pick in obstacle_data.pickups:
		if pick.weight + current_weight >= target_weight:
			pickup_data = pick
			break
		current_weight += pick.weight
	# Instantiate
	var scene_pickup = PICKUP_BASE.instantiate() as PickUpBase
	if GameScene.instance != null:
		GameScene.instance._add_pickup(scene_pickup)
	else:
		$Obstacles.add_child(scene_pickup)
	scene_pickup.position = spawn_points_arr[num].position
	# Set pickup props
	scene_pickup.spawn_data = pickup_data

# Paused functions
func on_paused(paused):
	active = !paused

func on_game_slow_mo(b: bool):
	if b:
		for ind in obstacle_data.spawn_points:
			spawn_timer_arr[ind].start(1.5)
