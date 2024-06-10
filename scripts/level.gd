extends Node2D

class_name Level

signal hud_data_changed(type: String, value: Variant)
signal game_over
signal level_completed

@onready var level_timer: Timer = $LevelTimer

@export var number: int = 1

var nutrition: int = 0
var time_left: int

func _ready() -> void:
	time_left = int(level_timer.time_left)
	
	for node: Node in get_tree().get_nodes_in_group("spears"):
		if not node is Spear:
			continue
		
		var spear: Spear = node as Spear
		spear.spear_thrown.connect(_on_spear_thrown.bind(spear))

func _enter_tree() -> void:
	hud_data_changed.emit("nutrition", nutrition)
	hud_data_changed.emit("time_left", time_left)

func _process(_delta) -> void:
	time_left = int(level_timer.time_left)
	hud_data_changed.emit("time_left", time_left)

func _on_nutrition_increased(amount) -> void:
	nutrition += amount
	hud_data_changed.emit("nutrition", nutrition)

func _on_game_over(message: String) -> void:
	game_over.emit(message)

func _on_level_timeout() -> void:
	level_completed.emit()

func _on_spear_thrown(spear: Spear) -> void:
	spear.reparent(self)
