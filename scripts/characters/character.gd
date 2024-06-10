extends CharacterBody2D

class_name Character

signal game_over(message: String)

@onready var fish_detector: Area2D = $FishDetector
@onready var drown_timer: Timer = $DrownTimer
@onready var drown_bar: ProgressBar = $DrownBar

@export var MOVE_SPEED: float = 300.0
@export var SWIM_SPEED: float = 200.0
@export var SLOWDOWN_SPEED: float = 30.0
@export var DESCENT_SPEED: float = 15.0
@export var JUMP_VELOCITY: float = -400.0
@export var JUMP_OUT_OF_WATER: float = 1.3
@export var GRABBED_FISH_OFFSET: Vector2 = Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var in_water: bool = false
var dead: bool = false
var grabbed_fish: Fish = null
var grabbed_fish_parent: Node = null

func kill(message: String = "") -> void:
	if dead:
		return
	
	dead = true
	drown_timer.stop()
	drown_bar.hide()
	game_over.emit(message)

func _ready() -> void:
	drown_bar.max_value = drown_timer.wait_time

func _physics_process(delta: float) -> void:
	if not in_water:
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
		
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor() and not dead:
			velocity.y = JUMP_VELOCITY
	else:
		var y_direction: float = Input.get_axis("move_up", "move_down")
		if y_direction and not dead:
			velocity.y = y_direction * SWIM_SPEED
		else:
			velocity.y = move_toward(velocity.y, DESCENT_SPEED, SLOWDOWN_SPEED)
	
	# Get the input direction and handle the movement/deceleration.
	var x_direction: float = Input.get_axis("move_left", "move_right")
	if x_direction and not dead:
		velocity.x = x_direction * (SWIM_SPEED if in_water else MOVE_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SLOWDOWN_SPEED)
		
	move_and_slide()

func _process(_delta: float) -> void:
	if in_water:
		drown_bar.value = drown_timer.time_left
	
	if Input.is_action_just_pressed("grab_fish"):
		if grabbed_fish:
			grabbed_fish.drop()
			grabbed_fish.reparent(grabbed_fish_parent)
			grabbed_fish = null
		else:
			for body: Node2D in fish_detector.get_overlapping_bodies():
				if not body is Fish:
					continue
				
				var fish: Fish = body as Fish
				if fish.stashed:
					continue
				
				grabbed_fish_parent = fish.get_parent()
				fish.grab()
				grabbed_fish = fish
				fish.reparent(self)
				fish.position = GRABBED_FISH_OFFSET
				break

func _on_water_entered(_area: Area2D) -> void:
	# print("Entered %s %s %s" % [_area, drown_timer.wait_time, drown_timer.time_left])
	if dead:
		return
	
	# print("You're starting to drown.")
	drown_timer.start()
	drown_bar.show()
	
	in_water = true

func _on_water_exited(_area: Area2D) -> void:
	# print("Exited %s %s %s" % [_area, drown_timer.wait_time, drown_timer.time_left])
	in_water = false
	
	if dead:
		return
	
	# Handle jumping out of water
	if ((Input.is_action_pressed("jump")) and (drown_timer.wait_time-drown_timer.time_left > 1.0)):
		velocity.y = JUMP_VELOCITY * JUMP_OUT_OF_WATER
	
	# print("You're not drowning anymore.")
	drown_timer.stop()
	drown_bar.hide()

func _on_fish_detected(fish: Node2D) -> void:
	# print("Detected %s" % fish)
	if not dead and fish is Fish:
		fish.kill()

func _on_drown_timer_timeout() -> void:
	# print("You drowned. Game over.")
	kill("You drowned.")
