extends Control

class_name GameOverScreen

@onready var label: Label = $Label
@onready var anim_player: AnimationPlayer = $"AnimationPlayer"

# Would name the function "show", but that overrides a Godot method and errors
func display(message: String) -> void:
	show()
	label.text = "GAME OVER\n%s" % message
	anim_player.play("show")
