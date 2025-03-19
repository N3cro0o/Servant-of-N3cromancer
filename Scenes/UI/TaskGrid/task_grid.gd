class_name TaskGrid extends GridContainer

@export var base_color: Color = Color("e22cb70d")
@export var finish_color: Color = Color("ffff9b0d")

@onready var task_1: MarginContainer = $Task1
@onready var nine_1: NinePatchRect = $Task1/NinePatchRect
@onready var task1_labels: Array[Label] = [$Task1/Task1Container/Head, $Task1/Task1Container/Body]
@onready var task_2: MarginContainer = $Task2
@onready var nine_2: NinePatchRect = $Task2/NinePatchRect
@onready var task2_labels: Array[Label] = [$Task2/Task2Container/Head, $Task2/Task2Container/Body]
@onready var task_3: MarginContainer = $Task3
@onready var nine_3: NinePatchRect = $Task3/NinePatchRect
@onready var task3_labels: Array[Label] = [$Task3/Task3Container/Head, $Task3/Task3Container/Body]

func update_data():
	# Task 1
	if TsM.task_arr.size() >= 1:
		task1_labels[0].text = TsM.task_arr[0].task_name()
		task1_labels[1].text = TsM.task_arr[0].task_desc()
		if TsM.validate_task(0):
			nine_1.modulate = finish_color
		else:
			nine_1.modulate = base_color
		task_1.visible = true
	else:
		task_1.visible = false
	# Task 2
	if TsM.task_arr.size() >= 2:
		task2_labels[0].text = TsM.task_arr[1].task_name()
		task2_labels[1].text = TsM.task_arr[1].task_desc()
		if TsM.validate_task(1):
			nine_2.modulate = finish_color
		else:
			nine_2.modulate = base_color
		task_2.visible = true
	else:
		task_2.visible = false
	# Task 3
	if TsM.task_arr.size() >= 3:
		task3_labels[0].text = TsM.task_arr[2].task_name()
		task3_labels[1].text = TsM.task_arr[2].task_desc()
		if TsM.validate_task(2):
			nine_3.modulate = finish_color
		else:
			nine_3.modulate = base_color
		task_3.visible = true
	else:
		task_3.visible = false
