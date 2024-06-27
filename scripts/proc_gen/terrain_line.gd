extends Line2D

@onready var point_counter: Label = $DebugInterface/PointCount/Counter
@onready var zoom_counter: Label = $DebugInterface/Frequency/Counter
@onready var y_counter: Label = $DebugInterface/YMultiplier/Counter

@export var generator: FastNoiseLite
@export var line_length: float = 1920
@export var start_position_x: float = 10
@export var point_count: int = 200
@export var y_multiplier: int = 100

func clear_gradient() -> void:
	gradient.offsets.clear()
	gradient.colors.clear()

func generate_line() -> void:
	clear_points()
	clear_gradient()
	
	add_point(Vector2(0, 0))
	add_point(Vector2(start_position_x, 0))
	
	var point_distance: float = line_length / point_count
	var prev_y: float = 0
	
	for x in range(start_position_x + point_distance, line_length, point_distance):
		var y: float = generator.get_noise_1d(x) * y_multiplier
		add_point(Vector2(x, y))
		
		if y * prev_y < 0:
			var point_color: Color = (Color.WHITE if y < 0 else Color.BLUE)
			gradient.add_point(x / line_length, point_color)
		
		prev_y = y

func _ready() -> void:
	generate_line()

func _on_count_slider_value_changed(value):
	point_count = value
	point_counter.text = str(value)
	generate_line()

func _on_frequency_slider_value_changed(value):
	generator.frequency = value
	zoom_counter.text = str(value)
	generate_line()

func _on_y_slider_value_changed(value):
	y_multiplier = value
	y_counter.text = str(value)
	generate_line()

func _on_seed_button_pressed():
	generator.seed = randi()
	generate_line()
