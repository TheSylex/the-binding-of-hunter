extends State
class_name run

var character: CharacterBody2D
var rollCD: Timer

func _ready():
	character = owner.get_node("Character")
	rollCD = owner.get_node("Timers/RollCD")

func enter():
	pass

func process(delta: float):
	if Input.is_action_just_pressed("B") && rollCD.is_stopped():
		Transitioned.emit(self, "roll")
	
	character.velocity -= character.velocity * (1.0 / (1.0 - character.FRICTION)) * delta # Apply friction
	
	if not (Input.is_action_pressed("LEFT")
		|| Input.is_action_pressed("RIGHT")
		|| Input.is_action_pressed("UP")
		|| Input.is_action_pressed("DOWN")
	): return # If no action is pressed don't process the inputs at all

	var direction_angle = Vector2(Input.get_axis("LEFT", "RIGHT"), Input.get_axis("UP", "DOWN")).angle()
	var direction_vector = Vector2(cos(direction_angle), sin(direction_angle))
	
	character.velocity += direction_vector * character.ACCELERATION * delta
