extends State
class_name displace

var character: CharacterBody2D
var rollCD: Timer

func _ready():
	character = owner.get_node("Character")
	rollCD = owner.get_node("Timers/RollCD")

func enter():
	pass

func process(delta: float):
	if !character.is_displacing:
		character.is_displacing = true
		character.velocity += character.displacement_vector
		character.displacement_vector = Vector2.ZERO
	else:
		var friction = 0.0
		if character.is_on_wall():
			friction = 0.95
		character.velocity -= character.velocity * (1.0 / (1.0 - friction)) * delta
		
		if character.velocity.length() <= 150.0:
			character.is_displacing = false
			Transitioned.emit(self, "run")
		elif Input.is_action_just_pressed("B") && rollCD.is_stopped():
			var direction_angle = Vector2(Input.get_axis("LEFT", "RIGHT"), Input.get_axis("UP", "DOWN")).angle()
			character.velocity = Vector2(cos(direction_angle), sin(direction_angle))
			character.is_displacing = false
			Transitioned.emit(self, "roll")
