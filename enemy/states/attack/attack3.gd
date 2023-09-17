extends State
class_name attack3

func enter():
	pass

func exit():
	Transitioned.emit(self, "atack1")

func process(delta: float):
	pass

func physics_process(delta: float):
	pass
