extends Node2D

#region Variables
@onready var lines: Node2D = $Lines
@onready var collision_polygon: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
@onready var point_counter: Label = $DebugInterface/PointCount/Counter
@onready var point_slider: HSlider = $DebugInterface/PointCount/Slider
@onready var zoom_counter: Label = $DebugInterface/Frequency/Counter
@onready var zoom_slider: HSlider = $DebugInterface/Frequency/Slider
@onready var y_counter: Label = $DebugInterface/YMultiplier/Counter
@onready var y_slider: HSlider = $DebugInterface/YMultiplier/Slider
@onready var accuracy_counter: Label = $DebugInterface/Accuracy/Counter
@onready var accuracy_slider: HSlider = $DebugInterface/Accuracy/Slider
@onready var segment_button: CheckBox = $DebugInterface/SegmentButton
@onready var segment_counter: Label = $DebugInterface/Segments/Counter
@onready var segment_slider: HSlider = $DebugInterface/Segments/Slider

@onready var land_line_scene: PackedScene = preload("res://scenes/proc_gen/land_line.tscn") as PackedScene

@export var generator: FastNoiseLite ## The noise generator that is used for procedural generation of the terrain.
@export var line_length: float = 1920 ## The length of the terrain line, measured in pixels.
@export var start_position_x: float = 10 ## The length of the starter flat line, measured in pixels.

@export_group("Line Colors")
@export var land_color: Color = Color.WHITE
@export var water_color: Color = Color.BLUE

var point_count: int = 200
var y_multiplier: int = 100
var accuracy: float = 1
var segmented_mode: bool = false
var segment_count: int = 1
var segments: PackedFloat32Array = PackedFloat32Array([-1, 0, 1])

@onready var point_distance: float = line_length / point_count
#endregion

func find_zero_point(x: float, prev_y: float) -> float:
	for sub_x in range((x - point_distance) * accuracy, x * accuracy, 1):
		var sub_y: float = generator.get_noise_1d(sub_x / accuracy) * y_multiplier
		
		if prev_y * sub_y < 0:
			return sub_x / accuracy
		
		prev_y = sub_y
	
	# If the difference is so small, might as well return x
	return x

func get_point(x: float, y: float) -> Vector2:
	var point: Vector2 = Vector2(x, y)
	
	if not segmented_mode:
		return point
	
	var segment_difference: float = 1 / float(segment_count + 1)
	var y_scaled: float = y / y_multiplier
	
	for segment: float in segments:
		if abs(y_scaled - segment) < segment_difference:
			return Vector2(x, segment * y_multiplier)
	
	return point

func generate_line() -> void:
	for line: Node in lines.get_children():
		line.queue_free()
	
	var polygon: PackedVector2Array = PackedVector2Array()
	polygon.append(Vector2(0, 0))
	polygon.append(Vector2(start_position_x, 0))
	
	var start_line: Line2D = land_line_scene.instantiate() as Line2D
	start_line.add_point(Vector2(0, 0))
	start_line.add_point(Vector2(start_position_x, 0))
	lines.add_child(start_line)
	
	var prev_y: float = 0
	var prev_line: Line2D = start_line
	
	for x in range(start_position_x + point_distance, line_length, point_distance):
		var y: float = generator.get_noise_1d(x) * y_multiplier
		polygon.append(get_point(x, y))
		
		if not segmented_mode and prev_y * y < 0:
			var x0: float = find_zero_point(x, prev_y)
			var y0: float = generator.get_noise_1d(x0) * y_multiplier
			prev_line.add_point(Vector2(x0, y0))
			
			var new_line: Line2D = land_line_scene.instantiate() as Line2D
			new_line.default_color = land_color if y < 0 else water_color
			new_line.add_point(Vector2(x0, y0))
			new_line.add_point(get_point(x, y))
			
			prev_line = new_line
			lines.add_child(new_line)
		else:
			prev_line.add_point(get_point(x, y))
		
		prev_y = y
	
	polygon.append(Vector2(line_length, y_multiplier))
	polygon.append(Vector2(0, y_multiplier))
	collision_polygon.polygon = polygon

func _ready() -> void:
	point_counter.text = str(point_count)
	point_slider.value = point_count
	zoom_counter.text = str(generator.frequency)
	zoom_slider.value = generator.frequency
	y_counter.text = str(y_multiplier)
	y_slider.value = y_multiplier
	accuracy_counter.text = str(accuracy)
	accuracy_slider.value = accuracy
	segment_button.button_pressed = segmented_mode
	segment_counter.text = str(segment_count)
	segment_slider.value = segment_count
	
	generate_line()

#region Signal Connection
func _on_count_slider_value_changed(value: float) -> void:
	point_count = int(value)
	point_distance = line_length / point_count
	point_counter.text = str(value)
	generate_line()

func _on_frequency_slider_value_changed(value: float) -> void:
	generator.frequency = value
	zoom_counter.text = str(value)
	generate_line()

func _on_y_slider_value_changed(value: float) -> void:
	y_multiplier = int(value)
	y_counter.text = str(value)
	generate_line()
	
func _on_accuracy_slider_value_changed(value: float) -> void:
	accuracy = value
	accuracy_counter.text = str(value)
	generate_line()

func _on_segment_slider_value_changed(value: float) -> void:
	segment_count = int(value)
	segment_counter.text = str(value)
	
	segments.clear()
	segments.append(-1)
	for segment in range(-segment_count + 1, segment_count, 1):
		segments.append(float(segment) / segment_count)
	segments.append(1)
	
	if segmented_mode:
		generate_line()

func _on_seed_button_pressed() -> void:
	generator.seed = randi()
	generate_line()

func _on_segment_button_toggled(toggled_on: bool) -> void:
	segmented_mode = toggled_on
	generate_line()
#endregion
