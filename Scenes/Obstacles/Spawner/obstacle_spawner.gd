extends Node2D

const PICKUP_PATH = "res://Scenes/PowerUpsAndPickUps/Base/pick_up_base.tscn"
const PICKUP_BASE = preload(PICKUP_PATH)

#region Variables
@export var active := true
## Left or right sided spawner [br]
## False - left, True - right
@export var left_right = false
@export var spawned_things : Array[SpawnObstacleDataHolder]
@export var spawned_pickups : Array[SpawnPickupDataHolder]
@export_range(0, 5) var spawn_delay
@onready var timer = $SpawnTimer
@onready var static_timer = $StaticTimer

var packed_scenes_array : Array[PackedScene]
var gravity_scenes_array : Array[PackedScene]
var static_scenes_array : Array[PackedScene]
var homing_scenes_array : Array[PackedScene]
var other_scenes_array : Array[PackedScene]
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
#endregion

#region Signals
signal on_spawned_entity
signal on_spawned_static_entity(w)
#endregion

#region Methods
func _ready():
	if spawned_things.is_empty():
		queue_free()
	else:
		randomize_spawn_delay()
		for x in spawned_things:
			var scene = load(x.scene_directory)
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
	print_rich("[b]Weight: %d[b]" % weight)

func _process(_delta):
	if GameScene.instance != null:
		var rotation_vec = position - GameScene.instance.return_player_pos()
		var angle = atan2(rotation_vec.y, rotation_vec.x)
		rotation = angle - deg_to_rad(90)

func randomize_spawn_delay():
	randomize()
	var rand_f = randf_range(1.5, 1.8 + spawn_delay) + spawn_static_index / 2.0
	if active:
		timer.start(rand_f)

func spawn_thing(id):
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
			var i = randi_range(0, 0)
			spawn_object = other_scenes_array[i].instantiate()
		if(GameScene.instance != null):
			GameScene.instance._add_obstacle(spawn_object)
		# Setting properties
		spawn_object.position = position
		spawn_object.add_start_velocity(Vector2(0,-20), rotation)
		spawn_object.player_body = PlayerLine1.instance
		spawn_static_index = 0
		on_spawned_entity.emit()
		if spawned_things[id_scene].type == 1:
			spawn_static_index += 2
			on_spawned_static_entity.emit(spawn_object.weight)
		# Tags
		# Flip
		if spawned_things[id_scene].flip:
			if left_right:
				spawn_object.scale.x = -1
		# Rotation
		spawn_object.can_lock_rotation = spawned_things[id_scene].can_lock_rotation
		# Other stuff like spawning pickups
		spawn_pickup(id_last)

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
		id = id % pickup_weight
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
		GameScene.instance._add_obstacle(scene_pickup)
		scene_pickup.position = position
		# Set pickup props
		scene_pickup.spawn_data = spawned_pickups[id_pickup]


func _spawn_logic():
	timer.stop() # stop to change the delay, I hope it should work
	# logic
	var spawn_index = randi_range(0, 1000)
	var spawn_id = spawn_index % weight
	spawn_thing(spawn_id)
	randomize_spawn_delay()

func lock_static_spawn(w):
	spawn_static_index += w

func on_static_timer_timeout():
	can_spawn_static = true
#endregion
