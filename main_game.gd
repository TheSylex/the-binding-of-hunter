extends Node2D

const MAX_CAMERA_DISTANCE = 400.0
const MOUSE_INFLUENCE_FACTOR = 0.3

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(load("res://crosshair.png"), 0, Vector2(22.5,22.5))
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	var rng = RandomNumberGenerator.new()
#	var sword_scene = preload("res://sword.tscn")
#	for i in 15:
#		var sword = sword_scene.instantiate()
#		sword.position = Vector2(rng.randf_range(0.0, 1300.0), rng.randf_range(0.0, 500.0))
#		add_child(sword)
#
#	var rock_scene = preload("res://rock.tscn")
#	for i in 5:
#		var rock = rock_scene.instantiate()
#		rock.position = Vector2(rng.randf_range(0.0, 1300.0), rng.randf_range(0.0, 500.0))
#		add_child(rock)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_camera_position()
	
func set_camera_position():
	var aspect_ratio = DisplayServer.window_get_size(0).aspect()
	var camera_position_unlimited = (get_global_mouse_position() - $Character/Character.position) * MOUSE_INFLUENCE_FACTOR
	
	var camera_position_clamped = Vector2(
		clamp(camera_position_unlimited.x, -MAX_CAMERA_DISTANCE, MAX_CAMERA_DISTANCE),
		clamp(camera_position_unlimited.y, -MAX_CAMERA_DISTANCE * aspect_ratio, MAX_CAMERA_DISTANCE * aspect_ratio)
	)
	
	$Camera2D.position = $Character/Character.position + camera_position_clamped
