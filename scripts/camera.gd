extends Camera2D

@onready var smooth_timer: Timer = $SmoothTimer

@export var left_barrier: CollisionShape2D
@export var right_barrier: CollisionShape2D
@export var top_barrier: CollisionShape2D
@export var bottom_barrier: CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if left_barrier:
		var shape_size: Vector2 = left_barrier.shape.get_rect().size
		limit_left = int(left_barrier.global_position.x - shape_size.x / 2)
	
	if right_barrier:
		var shape_size: Vector2 = right_barrier.shape.get_rect().size
		limit_right = int(right_barrier.global_position.x + shape_size.x / 2)
	
	if top_barrier:
		var shape_size: Vector2 = top_barrier.shape.get_rect().size
		limit_top = int(top_barrier.global_position.y - shape_size.y / 2)
	
	if bottom_barrier:
		var shape_size: Vector2 = bottom_barrier.shape.get_rect().size
		limit_bottom = int(bottom_barrier.global_position.y + shape_size.y / 2)

# Enables camera limit smoothing without starting from out of bounds
func _on_smooth_timer_timeout() -> void:
	limit_smoothed = true
	reset_smoothing()
