extends StaticBody2D

class_name Eskimo

@onready var spear: Spear = $Spear
@onready var default_spear_position: Vector2 = spear.position
@onready var default_spear_rotation: float = spear.rotation
@onready var spear_scene: PackedScene = preload("res://scenes/spear.tscn")
@onready var attack_timer: Timer = $AttackTimer
@onready var reload_timer: Timer = $ReloadTimer

@export var ROTATE_SPEED: float = 10.0

var character: Character
var last_position: Vector2 = Vector2.DOWN

func _process(delta: float) -> void:
	if spear.thrown:
		return
	
	if character:
		var target_rotation: float = spear.global_transform.looking_at(character.global_position).get_rotation()
		spear.rotation = rotate_toward(spear.global_rotation, target_rotation, ROTATE_SPEED * delta)
	else:
		spear.rotation = rotate_toward(spear.rotation, default_spear_rotation, ROTATE_SPEED * delta)

func _on_spear_range_entered(body: Node2D) -> void:
	if not body is Character:
		return
	
	character = body as Character
	
	if reload_timer.is_stopped():
		attack_timer.start()

func _on_spear_range_exited(body: Node2D) -> void:
	if not body == character:
		return
	
	character = null
	attack_timer.stop()

func _on_attack_timeout() -> void:
	var direction: Vector2 = (character.global_position - spear.global_position).normalized()
	spear.throw(direction)
	
	spear = spear_scene.instantiate() as Spear
	reload_timer.start()

func _on_reload_timeout() -> void:
	add_child(spear)
	spear.position = default_spear_position
	
	if character:
		attack_timer.start()
