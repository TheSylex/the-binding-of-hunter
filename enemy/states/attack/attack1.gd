extends State
class_name attack1

func enter():
	pass

func exit():
	Transitioned.emit(self, "atack2")

func process(delta: float):
	pass

func physics_process(delta: float):
	pass
