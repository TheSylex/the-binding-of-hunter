extends State
class_name roll

var character: CharacterBody2D
var rollCD: Timer
var rollDuration: Timer
var collisionShape2D: CollisionShape2D

func _ready():
	character = owner.get_node("Character")
	rollCD = owner.get_node("Timers/RollCD")
	rollDuration = owner.get_node("Timers/RollDuration")
	collisionShape2D = owner.get_node("Character/CollisionShape2D")

func enter():
	pass

func process(delta: float):
	#	apply_central_impulse(Vector2(200.0, 200.0))
	if rollDuration.is_stopped() && !character.is_rolling:
		var direction_angle = Vector2(character.velocity).angle()
		character.velocity = Vector2.ZERO
		var direction_vector = Vector2(cos(direction_angle), sin(direction_angle))
		character.velocity += direction_vector * 400.0
		rollDuration.wait_time = 0.4
		rollDuration.start()
		character.is_rolling = true
		collisionShape2D.modulate = Color(collisionShape2D.modulate, 0.2)
	elif !rollDuration.is_stopped():
#		velocity -= velocity * (1.0 / (1.0 - 0.75)) * delta
		pass
	else:
		collisionShape2D.modulate = Color(collisionShape2D.modulate, 1.0)
		character.is_rolling = false
		Transitioned.emit(self, "run")

func exit():
	rollCD.start()
