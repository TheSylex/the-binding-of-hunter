extends State
class_name idle

var idling_timer: Timer
var animatable_body_2d: AnimatableBody2D


var direction_vector: Vector2
var rng = RandomNumberGenerator.new()

func _ready():
	animatable_body_2d = owner.get_node("AnimatableBody2D")
	idling_timer = owner.get_node("IdlingTimer")

func enter():
	idling_timer.wait_time = rng.randf_range(3.0, 7.0)
	idling_timer.one_shot = true
	idling_timer.start()
	direction_vector = Vector2(
		rng.randf_range(-1.0, 1.0),
		rng.randf_range(-1.0, 1.0)
	).normalized()
	pass

func physics_process(delta: float):
	if idling_timer.is_stopped():
		Transitioned.emit(self, "attack")
#	elif abs(animatable_body_2d.position.x) > 550.0 || abs(animatable_body_2d.position.y) > 300.0:
#		enter()
	else:
#		animatable_body_2d.position += direction_vector * 60.0 * delta
		pass

