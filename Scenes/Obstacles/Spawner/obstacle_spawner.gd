class_name SpawnerBasic extends Node2D

const PICKUP_PATH = "res://Scenes/PowerUpsAndPickUps/Base/pick_up_base.tscn"
const PICKUP_BASE = preload(PICKUP_PATH)

#region Variables
@export var active := true:
	set(b):
		active = b
		if b:
			randomize_spawn_delay()
@export_enum("Left", "Center", "Right") var spawn_position = "Center"
## Left or right sided spawner [br]
## False - left, True - right
@export var left_right = false
@export_range(0, 5) var spawn_delay
## Minimum weight needed for no-repeating
@export var weight_threshold = 3
@onready var timer = $SpawnTimer
@onready var static_timer = $StaticTimer

var spawner_position : ObstacleNonverticalTele.state
var spawned_things : Array[SpawnObstacleDataHolder]
var spawned_bosses : Array[SpawnObstacleDataHolder]
var spawned_pickups : Array[SpawnPickupDataHolder]
var packed_scenes_array : Array[PackedScene]
var gravity_scenes_array : Array[PackedScene]
var static_scenes_array : Array[PackedScene]
var homing_scenes_array : Array[PackedScene]
var other_scenes_array : Array[PackedScene]
var boss_scenes_array: Array[PackedScene]
var other_array_len = 0
var weight = 0
var pickup_weight = 0
var spawn_static_index := 0:
	set(i):
		spawn_static_index = i
		can_spawn_static = false
		if spawn_static_index >= 2:
			static_timer.start(3)
		else:
			static_timer.start(.5)
var can_spawn_static = true
var repeat_index = -1
var diff := 0.0
#endregion

#region Signals
signal on_spawned_entity
signal on_spawned_static_entity(w)
#endregion

#region Methods
func _init():
	# Set-up spawner
	if spawn_position == "Right":
		left_right = true
	else:
		left_right = false

func _ready():
	# Get spawn data
	advance_to_next_stage(active)
	# Check if no obstacles
	if spawned_things.is_empty():
		queue_free()
	else:
		randomize_spawn_delay()

func _process(_delta):
	if GameScene.instance != null:
		var rotation_vec = position - GameScene.instance.return_player_pos()
		var angle = atan2(rotation_vec.y, rotation_vec.x)
		rotation = angle - deg_to_rad(90)
		diff = GameScene.instance.difficulty

func setup_spawning_data():
	var scene
	for x in spawned_things:
		scene = load(x.scene_directory)
		match x.type:
			0: # Grav
				gravity_scenes_array.push_back(scene)
			1: # Static
				static_scenes_array.push_back(scene)
			2: # Homing
				homing_scenes_array.push_back(scene)
			3: # Other
				other_scenes_array.push_back(scene)
				other_array_len += 1
		packed_scenes_array.push_back(scene)
		weight += x.weight
	for y in spawned_pickups:
		pickup_weight += y.weight
	for z in spawned_bosses:
		scene = load(z.scene_directory)
		print(z.scene_directory)
		boss_scenes_array.push_back(scene)
	print_rich("[b]Weight: %d, Pickup Weight : %d[b]" % [weight, pickup_weight])

func advance_to_next_stage(active_bool : bool = true):
	# Reset data
	active = false
	weight = 0
	pickup_weight = 0
	other_array_len = 0
	spawned_things.resize(0)
	spawned_bosses.resize(0)
	spawned_pickups.resize(0)
	packed_scenes_array.resize(0)
	gravity_scenes_array.resize(0)
	static_scenes_array.resize(0)
	homing_scenes_array.resize(0)
	other_scenes_array.resize(0)
	boss_scenes_array.resize(0)
	# Get stage data
	var stage = GameScene.instance.stage
	print("Stage ",stage)
	match spawn_position:
		"Left":
			spawned_things = GameScene.instance.enemy_stages[stage].left
			spawner_position = ObstacleNonverticalTele.state.LEFT
		"Center":
			spawned_things = GameScene.instance.enemy_stages[stage].center
			spawner_position = ObstacleNonverticalTele.state.CENTER
		"Right":
			spawned_things = GameScene.instance.enemy_stages[stage].right
			spawner_position = ObstacleNonverticalTele.state.RIGHT
	spawned_pickups = GameScene.instance.enemy_stages[stage].pickups
	spawned_bosses = GameScene.instance.enemy_stages[stage].bosses
	setup_spawning_data()
	active = active_bool

func randomize_spawn_delay():
	randomize()
	var rand_f = randf_range(1.5, 2 + spawn_delay - (diff / 20)) + spawn_static_index / 2.0
	if active:
		timer.start(rand_f)

func spawn_something(spawn_object : ObstacleGravityBase, object_data : SpawnObstacleDataHolder):
	if(GameScene.instance != null):
		GameScene.instance._add_obstacle(spawn_object)
	# Static check
	if object_data.type == 1:
		spawn_static_index += 2
		on_spawned_static_entity.emit(spawn_object.weight)
	# Setting properties
	spawn_object.position = position
	spawn_object.add_start_velocity(Vector2(0,-20), rotation)
	spawn_object.player_body = PlayerLine1.instance
	spawn_static_index = 0
	on_spawned_entity.emit()
	# Tags
		# Flip
	if object_data.flip:
		if left_right:
			spawn_object.scale.x = -1
		# Rotation
	spawn_object.can_lock_rotation = object_data.can_lock_rotation
		# ObstacleNonverticalTele
	if object_data.tele_state:
		spawn_object = spawn_object as ObstacleNonverticalTele
		spawn_object.curr_position = spawner_position
	# Return pointer to instance
	return spawn_object

func spawn_obstacle(id):
	var id_last = id
	if active:
		var id_scene = 0
		var other_check = false
		var _static_check = false
		# Chose obj to spawn
		for x in spawned_things:
			if (id - x.weight) < 0:
				# Static spawn chance correction
				if spawn_static_index != 0 and x.type == 1:
					var f = randf()
					if f > .5:
						spawn_static_index += 2
				# Other obstacle check
				if spawned_things[id_scene].type == 3:
					other_check = true
				break
			else:
				id -= x.weight
				id_scene += 1
		# Repeat check
		if id_scene == repeat_index:
			var rand_index = randi_range(0, spawned_things.size())
			var loop_i = 0
			while rand_index != repeat_index:
				rand_index = randi_range(0, spawned_things.size())
				loop_i += 1
				if loop_i > 3:
					rand_index = 0
					break
			if spawned_things[rand_index].weight >= weight_threshold:
				# If genererated object weight is larger or equal to WT, pick new repeat_index
				repeat_index = rand_index
			# Replace id_scene with generated index
			id_scene = rand_index
		# Static check - add static check and spawn other stuff
		if spawned_things[id_scene].type == 1 and spawn_static_index >= 2:
			id_scene = change_id(id_scene, 1)
		elif spawned_things[id_scene].spawner_is_empty and spawn_static_index != 0:
			id_scene = change_id(id_scene, 1)
		# Spawn
		var spawn_object : ObstacleGravityBase
		# Other obstacle
		if !other_check:
			spawn_object = packed_scenes_array[id_scene].instantiate()
		else:
			var i = randi_range(0, other_array_len-1)
			spawn_object = other_scenes_array[i].instantiate()
		# Spawn
		spawn_something(spawn_object, spawned_things[id_scene])
		# Other logic
		spawn_pickup(id_last)
		GameScene.instance.difficulty += float(spawned_things[id_scene].weight) / 80

func spawn_boss(id_scene):
	# Spawn
	var spawn_object : ObstacleGravityBase
	spawn_object = boss_scenes_array[id_scene].instantiate()
	var boss = spawn_something(spawn_object, spawned_bosses[id_scene])
	return boss

func change_id(id, type):
	var rand_var = randf()
	var dir = 1
	if rand_var < .5:
		dir = -1
	while spawned_things[id].type == type:
		id += dir
		if id >= spawned_things.size():
			id = 0
		elif id < 0:
			id = spawned_things.size() - 1
	return id

func spawn_pickup(id):
	# Check if spawn cond is true
	var gm = get_node("/root/GmM") as GM
	if id % gm.pickup_spawn_period == 0:
		var id_pickup = 0
		id = randi_range(0, pickup_weight - 1)
		print(id)
		for x in spawned_pickups:
			if (id - x.weight) < 0:
				# Found the border value, END!
				break
			else:
				# Else pop current data weight and continue
				id -= x.weight
				id_pickup += 1
		# Spawn pickup
		var scene_pickup = PICKUP_BASE.instantiate() as PickUpBase
		# Set basic props
		GameScene.instance._add_pickup(scene_pickup)
		scene_pickup.position = position
		# Set pickup props
		scene_pickup.spawn_data = spawned_pickups[id_pickup]

func _spawn_logic():
	timer.stop() # stop to change the delay, I hope it should work
	# logic
	var spawn_index = randi_range(0, 1000)
	var spawn_id = spawn_index % weight
	spawn_obstacle(spawn_id)
	randomize_spawn_delay()

func lock_spawn():
	active = false

func lock_static_spawn(w):
	spawn_static_index += w

func on_static_timer_timeout():
	can_spawn_static = true
#endregion
