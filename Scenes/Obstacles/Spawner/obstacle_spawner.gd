extends Node2D

# Variables
@export var spawned_things : Array[SpawnObstacleDataHolder]
@export_range(0, 5) var spawn_delay
@onready var timer = $SpawnTimer

var packed_scenes_array : Array[PackedScene]
var gravity_scenes_array : Array[PackedScene]
var static_scenes_array : Array[PackedScene]
var weight = 0
var can_spawn_static := true
# Signals
signal on_spawned_entity
signal on_spawned_static_entity
# Methods
func _ready():
	if spawned_things.is_empty():
		queue_free()
	else:
		randomize_spawn_delay()
		for x in spawned_things:
			var scene = load(x.scene_directory)
			if x.type == 0:
				gravity_scenes_array.push_back(scene)
			elif x.type == 1:
				static_scenes_array.push_back(scene)
			packed_scenes_array.push_back(scene)
			weight += x.weight
	print_rich("[b]Weight: %d[b]" % weight)

func _process(_delta):
	if GameScene.instance != null:
		var rotation_vec = position - GameScene.instance.return_player_pos()
		var angle = atan2(rotation_vec.y, rotation_vec.x)
		rotation = angle - deg_to_rad(90)

func randomize_spawn_delay():
	randomize()
	var rand_f = randf_range(1, 1 + spawn_delay)
	timer.start(rand_f)

func spawn_thing(id):
	var id_scene = 0
	for x in spawned_things:
		if (id - x.weight) <= 0:
			break
		else:
			id -= x.weight
			id_scene += 1
	print("ID: %d" % id_scene)
	if spawned_things[id_scene].type == 1 and can_spawn_static == false:
		id_scene = change_id(id_scene)

	# Spawn
	var spawn_object : PhysicsBody2D = packed_scenes_array[id_scene].instantiate()
	if(GameScene.instance != null):
		GameScene.instance._add_obstacle(spawn_object)
	spawn_object.position = position
	spawn_object.add_start_velocity(Vector2(0,-10), rotation)
	can_spawn_static = true
	on_spawned_entity.emit()
	if spawned_things[id_scene].type == 1:
		on_spawned_static_entity.emit()

func change_id(id):
	var rand_var = randf()
	if rand_var > .5 and id != 0:
		id -= 1
	elif rand_var > .5 and id == 0:
		id = spawned_things.size() - 1
	elif rand_var < .5 and id != spawned_things.size() - 1:
		id += 1
	else:
		id = 0
	return id

func _spawn_logic():
	timer.stop() # stop to change the delay, I hope it should work
	# logic
	var spawn_index = randi_range(0, 1000)
	print(spawn_index % weight)
	spawn_thing(spawn_index % weight)
	randomize_spawn_delay()

func lock_static_spawn():
	can_spawn_static = false
