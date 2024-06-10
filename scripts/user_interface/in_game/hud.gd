extends Control

class_name HUD

@export var PREFIXES: Dictionary = {
	nutrition = "Nutrition: ",
	time_left = ""
}
@export var SUFFIXES: Dictionary = {
	nutrition = " nu",
	time_left = "s left"
}

var labels: Dictionary

func update(type: String, value: Variant) -> void:
	labels[type].text = "%s%s%s" % [PREFIXES[type], value, SUFFIXES[type]]

func _ready() -> void:
	for label in get_children():
		if not label is Label:
			continue
		
		labels[label.name.to_snake_case()] = label
