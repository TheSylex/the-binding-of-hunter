extends State
class_name attack

var attack_state_machine: Node
var animatable_body_2d: AnimatableBody2D

func _ready():
	attack_state_machine = owner.get_node("AttackSM")
	animatable_body_2d = owner.get_node("AnimatableBody2D")

func enter():
	# Attack 1
	var sword_scene = preload("res://sword.tscn")
	var amount = 16
	var angle_step = TAU / amount
	
	for i in amount:
		var sword = sword_scene.instantiate()
		var launch_vector = Vector2.from_angle(i * angle_step)
		sword.position = animatable_body_2d.global_position + launch_vector * 50.0
		sword.rotation = angle_step * i
		sword.apply_central_impulse(launch_vector * 1000.0)
		print(animatable_body_2d.position)
		owner.get_parent().add_child(sword)

func process(delta: float):
	Transitioned.emit(self, "idle")

func physics_process(delta: float):
	pass
