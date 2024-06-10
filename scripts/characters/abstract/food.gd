extends CharacterBody2D

class_name Food

signal nutrition_increased(amount: int)

@export var NUTRITION: int = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var in_water: bool = true
var in_stash: bool = false
var dead: bool = false
var grabbed: bool = false
var stashed: bool = false
var default_collision_mask: int

func kill() -> void:
	dead = true

func grab() -> void:
	if stashed:
		return
	
	grabbed = true
	collision_mask = 0

func drop() -> void:
	if in_stash:
		stashed = true
		nutrition_increased.emit(NUTRITION)
	
	grabbed = false
	collision_mask = default_collision_mask

# Virtual method - will not run if overridden
func _ready() -> void:
	default_collision_mask = collision_mask

func _on_water_entered(_area: Area2D) -> void:
	in_water = true

func _on_water_exited(_area: Area2D) -> void:
	in_water = false

func _on_stash_entered(_area: Area2D) -> void:
	in_stash = true

func _on_stash_exited(_area: Area2D) -> void:
	in_stash = false
