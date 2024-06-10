extends Food

class_name Fish

@export var SWIM_SPEED: float = 200.0
@export var SLOWDOWN_SPEED: float = 30.0
@export var DESCENT_SPEED: float = 15.0
@export var X_RANGE: float = 500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position: Vector2
var x_direction: int = 1

# Overrides the _ready() function in superclass Food
func _ready() -> void:
	start_position = position
	default_collision_mask = collision_mask

func _physics_process(delta: float) -> void:
	if not in_water and not grabbed:
		velocity.x = move_toward(velocity.x, 0, SLOWDOWN_SPEED)
		velocity.y += gravity * delta
	elif not dead:
		if x_direction == 1 and position.x - start_position.x > X_RANGE:
			x_direction = -1
		elif x_direction == -1 and position.x < start_position.x:
			x_direction = 1
		
		velocity.x = x_direction * SWIM_SPEED
		position.y = start_position.y + sin(position.x / 20) * 10
	elif not grabbed:
		velocity.x = move_toward(velocity.x, 0, SLOWDOWN_SPEED)
		velocity.y = move_toward(velocity.y, DESCENT_SPEED, SLOWDOWN_SPEED)
	else:
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()
