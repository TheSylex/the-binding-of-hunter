extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(null)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Start.pressed.connect(start_button)
	$Exit.pressed.connect(exit_button)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_button():
	get_tree().change_scene_to_file("res://main_game.tscn")

func exit_button():
	get_tree().quit()
