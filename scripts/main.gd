extends Node2D

class_name Main

@onready var main_menu: MainMenu = $UserInterface/MainMenu as MainMenu
@onready var in_game_ui: Control = $UserInterface/InGame
@onready var hud: HUD = $UserInterface/InGame/HUD as HUD
@onready var game_over_screen: GameOverScreen = $UserInterface/InGame/GameOver as GameOverScreen

@export var level_folder_path: String = "res://scenes/levels"
@export var start_level: String = "level1"

var current_level: Level

func load_level(level_name: String) -> Level:
	var level_path: String = "%s/%s.tscn" % [level_folder_path, level_name]
	if not FileAccess.file_exists(level_path):
		return null
	
	var packed_scene: PackedScene = load(level_path) as PackedScene
	var world: Level = packed_scene.instantiate() as Level
	world.hud_data_changed.connect(hud.update)
	world.game_over.connect(game_over_screen.display)
	world.level_completed.connect(load_next_level)
	add_child(world)
	
	in_game_ui.show()
	
	return world

func load_next_level() -> void:
	var next_level: String = "level%s" % str(current_level.number + 1)
	current_level.queue_free()
	
	current_level = load_level(next_level)

func _on_play_button_pressed():
	current_level = load_level(start_level)

func _on_debug_level_submitted(level_name: String):
	current_level = load_level(level_name)
	
	if current_level:
		main_menu.hide()
	else:
		main_menu._on_level_not_found(level_name)
