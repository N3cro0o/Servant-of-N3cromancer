class_name DialogueScreen extends Control

#region Variables
@export_multiline var text_to_be_filled: String:
	set(text):
		text_to_be_filled = text
		update_params(text)
@export var delay_per_character: float = 0.1
@onready var label: Label = $Margin/Center/Margin/MarginInner/Label
@onready var timer_node: Timer = $UpdatePage

class TextDataV1:
	var text: String = ""
	var delay_parameters: Dictionary = {0: 0.05}

var text_data_array: Array[TextDataV1]
var data_counter = 0
var counter = 0
var text_index = 0
var timer = 0
var delay_parameters: Dictionary
var start_color

signal on_character_append
## Signal emited when node prints whole TextDataV1 text string.[br]
## Due to some characteristics and reading next pages,
## it is also emitted when new data is loaded
signal on_text_append_end
#endregion

# Basic Godot functions
func _ready() -> void:
	label.text = ""
	start_color = $Margin/Center/Margin/Rect.self_modulate
	if text_to_be_filled != null || text_to_be_filled != "":
		update_params(text_to_be_filled)

func _process(delta: float) -> void:
	if text_index < counter && timer <= 0:
		label.text += text_to_be_filled[text_index]
		# Start space check
		if label.text.length() == 1 && text_to_be_filled[text_index] == ' ':
			$Margin/Center/Margin/Rect.self_modulate = Color(1, 1, 1, 0)
		else:
			if label.text.length() == 2:
				$Margin/Center/Margin/Rect.self_modulate = start_color
		# Update string char index
		text_index += 1
		# Delay
		timer = delay_per_character
		update_delay()
		# Signals
		on_character_append.emit()
		if text_index == counter:
			update_text()
	else:
		if !GmM.paused:
			timer -= delta

# Update functions
func update_delay():
	for key in delay_parameters.keys():
		if key == text_index:
			delay_per_character = delay_parameters[key]
			break

func update_text():
	timer_node.start(1.5)
	data_counter += 1
	process_mode = PROCESS_MODE_DISABLED
	text_index = 0

func update_params(text: String):
	timer = 0
	text_index = 0
	counter = text.length()

# Set functions
#func set_text(text: String, delay_params: Dictionary = {0: 0.1}):
func set_text(data_arr: Array[TextDataV1]):
	text_data_array = data_arr
	data_counter = 0
	set_next_page()

func set_next_page():
	on_text_append_end.emit()
	label.text = ""
	$Margin/Center/Margin/Rect.self_modulate = Color(1, 1, 1, 0)
	timer_node.stop()
	if data_counter < text_data_array.size():
		$Margin/Center/Margin/Rect.self_modulate = start_color
		process_mode = PROCESS_MODE_INHERIT
		text_to_be_filled = text_data_array[data_counter].text
		delay_per_character = text_data_array[data_counter].delay_parameters[0]
		delay_parameters = text_data_array[data_counter].delay_parameters

# System/Controll functions
func on_paused(paused):
	timer_node.paused = paused
