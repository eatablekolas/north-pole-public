extends CharacterBody2D

class_name Spear

signal spear_thrown

@onready var wall_ray: RayCast2D = $WallRay

@export var SPEED: float = 300.0

var direction: Vector2
var thrown: bool = false

func throw(new_direction: Vector2) -> void:
	spear_thrown.emit()
	direction = new_direction
	thrown = true

func _physics_process(_delta: float) -> void:
	if not thrown:
		return
	
	if wall_ray.is_colliding():
		thrown = false
		return
	
	velocity.x = direction.x * SPEED
	velocity.y = direction.y * SPEED

	move_and_slide()
	
func _on_character_detected(body: Node2D) -> void:
	if not thrown or not body is Character:
		return
	
	var character: Character = body as Character
	call_deferred("reparent", character)
	character.kill("You got impaled with a spear.")
	
	thrown = false
