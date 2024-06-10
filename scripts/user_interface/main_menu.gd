extends Control

class_name MainMenu

signal play_button_pressed
signal debug_level_submitted(level_name: String)

@onready var main: Control = $Main
@onready var debug: Control = $Debug
@onready var not_found_label: Label = $Debug/NotFoundLabel
@onready var not_found_timer: Timer = $Debug/NotFoundLabel/Timer

func _on_play_button_pressed():
	play_button_pressed.emit()
	hide()

func _on_debug_button_pressed():
	main.hide()
	debug.show()

func _on_level_input_text_submitted(level_name: String):
	debug_level_submitted.emit(level_name)

func _on_level_not_found(level_name: String):
	not_found_label.text = "Nie znaleziono '%s'!" % level_name
	not_found_label.show()
	
	not_found_timer.start()

func _on_not_found_label_timeout():
	not_found_label.hide()

func _on_back_button_pressed():
	debug.hide()
	main.show()
