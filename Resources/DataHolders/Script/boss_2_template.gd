class_name LineAttackData extends Resource

# Properties
@export_range(1, 5) var start_offset = 1.0
@export_range(0.5, 3) var anim_time = 2.0
@export_range(0, 1) var inverse_chance = 0.0

@export_group("Left")
@export var line_left: bool
@export_range(0, 1) var line_left_offset: float
@export_group("Middle")
@export var line_middle: bool
@export_range(0, 1) var line_middle_offset: float
@export_group("Right")
@export var line_right: bool
@export_range(0, 1) var line_right_offset: float
