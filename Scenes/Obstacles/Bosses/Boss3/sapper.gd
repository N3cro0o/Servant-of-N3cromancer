class_name ObstacleStaticBoss2 extends ObstacleNonverticalBase

#region Variables
@export_range(0.0, 10.0) var attack_threshold = 6.0
@export_range(0.0, 60.0) var attack_time = 40.0
@export var eyes: Array[PackedScene]
@export var obstacle_data: StageEnemyData
@export var move_x:Curve
@export var move_y:Curve
@onready var sprite_offset: Node2D = $TargetsSprites
@onready var sprites_arr: Array[Sprite2D] = [$TargetsSprites/Target1, $TargetsSprites/Target2,\
	$TargetsSprites/Target3]
@onready var attack_sprite: Sprite2D = $TargetsSprites/BossBody/AttackSprite

var eye_arr: Array[SapperEye]
var player_cur_pos: PlayerLine1.last_pos
var line_times := [0.0, 0.0, 0.0]
var attack_sprite_move_lock = false
var line_inter = 0
var lock_timers = false
signal on_boss_kill

#endregion

# Basic Godot functions
func _ready() -> void:
	sprite_offset.modulate.a = 0.0
	super._ready()
	# Eyes
	var eyesockets: Array[Node2D] = [$TargetsSprites/BossBody/Eye1Pos, $TargetsSprites/BossBody/Eye2Pos,
			$TargetsSprites/BossBody/Eye3Pos]
	for socket in eyesockets:
		var scene: SapperEye = eyes.pick_random().instantiate()
		socket.add_child(scene)
		eye_arr.push_back(scene)
		socket.scale *= 2
	# Connect with the rest of the GameScene
	if GameScene.instance != null:
		GameScene.instance.spawner.set_obstacle_data(obstacle_data)
	if PlayerLine1.instance != null:
		PlayerLine1.instance.on_position_change.connect(on_player_move)
		player_cur_pos = PlayerLine1.instance.last_point_pos
		on_player_move(player_cur_pos)
		await get_tree().process_frame
		sprite_offset.global_position.y = PlayerLine1.instance.return_body_global_position().y
	get_tree().create_tween().tween_property(sprite_offset, "modulate:a", 1, 0.5)

func _process(delta):
	for i in 3:
		if !lock_timers:
			if i == player_cur_pos + 1:
				line_times[i] += delta * GmM.game_speed 
			else:
				line_times[i] -= delta / 2 * GmM.game_speed
			if line_times[i] < 0:
				line_times[i] = 0
				# Spiiiiiin
				sprites_arr[i].rotation += delta * 0.25
		# Check for attack
		if line_times[i] >= attack_threshold:
			do_attack()
			line_times[i] = 0
		# Sprite modulation
		sprites_arr[i].modulate.a = line_times[i] / attack_threshold
		# Shadow
		var new_inter = line_inter + i * 0.3
		if new_inter >= 1: new_inter -= 1
		var shadow: Sprite2D = sprites_arr[i].get_child(0)
		var move_vec = Vector2(move_x.sample(new_inter), move_y.sample(new_inter))
		shadow.position = move_vec * 10 * line_times[i] / attack_threshold
	# Attack time left
	if !lock_timers:
		attack_time -= delta * GmM.game_speed
	if attack_time <= 0:
		on_boss_kill.emit()
		kill_da_hoe()
	# Move attack sprite
	if PlayerLine1.instance != null && !attack_sprite_move_lock:
		attack_sprite.position.x = PlayerLine1.instance.return_body_position().x
		attack_sprite.position.x -= position.x
	# Interpolation
	line_inter += delta / 3 * GmM.game_speed
	if line_inter >= 1:
		line_inter = 0
	# Eye move
	for eye in eye_arr:
		if PlayerLine1.instance != null:
			eye.look_at_object(PlayerLine1.instance.body)

# Attack functions
func do_attack():
	lock_timers = true
	# Bufor for unpause
	while GmM.paused:
		await get_tree().process_frame
	# Continue
	lock_timers = false
	var start_pos = attack_sprite.position
	attack_sprite.visible = true
	attack_sprite_move_lock = true
	# Faze in tween
	var tween = get_tree().create_tween()
	tween.tween_property(attack_sprite,"position:y", start_pos.y - 425, 0.2).\
		set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	# Damagium
	if PlayerLine1.instance != null:
		PlayerLine1.instance.body.last_obstacle_hit = self
		PlayerLine1.instance.body.last_obstacle_offset = global_position -\
				PlayerLine1.instance.return_body_global_position() 
		PlayerLine1.instance.body.do_damage(damage)
		if PlayerLine1.instance.health_points <= 0: return;
	# Small cooldown
	await get_tree().create_timer(1.0).timeout
	# Faze out tween
	tween = get_tree().create_tween()
	tween.tween_property(attack_sprite,"position:y", start_pos.y, 2.0).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	attack_sprite_move_lock = false
	attack_sprite.visible = false

# DIE function
func kill_da_hoe():
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	get_tree().create_tween().tween_property(self, "modulate:a", 0, 1.0).\
		set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	queue_free()

# Signal functions
func on_player_move(pos: PlayerLine1.last_pos):
	player_cur_pos = pos
	# Update eye
	for s in eye_arr:
		s.visible = false
	eye_arr[pos + 1].visible = true

# Overrides
func set_modulate_new(new_color: Color):
	$TargetsSprites/BossBody.self_modulate = new_color
