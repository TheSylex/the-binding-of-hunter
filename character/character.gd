extends CharacterBody2D

@export var ACCELERATION = 0.0
@export var FRICTION = 0.0
@export var MAX_SPEED = 0.0

enum PowerMode {
	AREA,
	SELECTOR
}

var is_rolling = false
var is_displacing = false

var displacement_vector = Vector2.ZERO

var movement_vector = Vector2.ZERO

const power_charge_rate = 800.0
const min_power_charge = 600.0
const max_power_charge = 1400.0

var power_charge = min_power_charge

var selected_body = null

var power_mode = PowerMode.SELECTOR

func _process(delta):
	character_controller(delta)
	if Input.is_action_just_pressed("A"):
		if power_mode == PowerMode.AREA:
			power_mode = PowerMode.SELECTOR
		else:
			power_mode = PowerMode.AREA
		

func _physics_process(delta):
	pass

func character_controller(delta):
	update_selected_body()
	power_charge = clamp(power_charge, min_power_charge, max_power_charge)
	$ProgressBar.value = power_charge
	orientate_power_area()
	draw_power_selection_arrow()
	if $PowerCD.is_stopped():
		handle_character_powers(delta)
	else:
		$Area2D/Polygon2D.modulate = Color(1.0, 0.0, 0.0, 0.2)
	move_and_slide()

func handle_character_powers(delta):
	# FUNCTIONAL
	if Input.is_action_pressed("ATTRACT"):
		power_charge += power_charge_rate * delta
	elif Input.is_action_pressed("REPEL"):
		power_charge += power_charge_rate * delta
	
	var bodies = []
	match power_mode:
		PowerMode.AREA: bodies = $Area2D.get_overlapping_bodies()
		PowerMode.SELECTOR: if selected_body != null: bodies = [selected_body]
	
	if (Input.is_action_just_released("ATTRACT")
		|| ($ProgressBar.value >= $ProgressBar.max_value && Input.is_action_pressed("ATTRACT"))):
		attract(bodies, power_charge)
		power_charge = min_power_charge
	elif (Input.is_action_just_released("REPEL")
		|| ($ProgressBar.value >= $ProgressBar.max_value && Input.is_action_pressed("REPEL"))):
		repel(bodies, power_charge)
		power_charge = min_power_charge
	elif Input.is_action_pressed("ATTRACT") && Input.is_action_pressed("REPEL"):
		stop(bodies)
		$PowerCD.wait_time = 2.0
		$PowerCD.start()
		power_charge = min_power_charge
	
	# VISUAL
	var progress_bar_trasparency = (power_charge - min_power_charge) / (max_power_charge - min_power_charge) * 3.0
	if Input.is_action_pressed("ATTRACT"):
		$ProgressBar.fill_mode = ProgressBar.FILL_END_TO_BEGIN
		$ProgressBar.modulate = Color(Color.WHITE, progress_bar_trasparency)
		$Area2D/Polygon2D.modulate = Color(0.0, 1.0, 0.0, 0.2)
	elif Input.is_action_pressed("REPEL"):
		$ProgressBar.fill_mode = ProgressBar.FILL_BEGIN_TO_END
		$ProgressBar.modulate = Color(Color.WHITE, progress_bar_trasparency)
		$Area2D/Polygon2D.modulate = Color(0.0, 0.0, 1.0, 0.2)
	else:
		$ProgressBar.modulate = Color.TRANSPARENT
		$Area2D/Polygon2D.modulate = Color(0.0, 0.0, 0.0, 0.2)

func attract(bodies, force):
	for body in bodies:
		var force_vector = body.position.direction_to(position) * force
		if body is StaticBody2D && power_mode == PowerMode.SELECTOR:
			displacement_vector = position.direction_to(get_global_mouse_position()) * force
			is_displacing = false
#			character_state = CharacterState.DISPLACE
			var curr_state = owner.get_node("StateMachine").current_state
			curr_state.Transitioned.emit(curr_state, "displace")
		elif body is RigidBody2D:
			body.linear_velocity = Vector2.ZERO
			body.apply_central_impulse(force_vector)
#		TODO:
#		body.rotation = body.position.angle_to_point(position)
#		body.add_constant_torque(10000.0)

func repel(bodies, force):
	for body in bodies:
		var force_vector = position.direction_to(get_global_mouse_position()) * force
		if body is StaticBody2D && power_mode == PowerMode.SELECTOR:
			var unmodified_force = force_vector.normalized() + force_vector
			const max_distance = 150.0
			var additional_force = (1 - clamp((body.position - position).length(), 0.0, max_distance) / max_distance) * unmodified_force * 2.0
			
			is_displacing = false
			displacement_vector = -( 0.5 * unmodified_force) #+ additional_force)
#			character_state = CharacterState.DISPLACE
			var curr_state = owner.get_node("StateMachine").current_state
			curr_state.Transitioned.emit(curr_state, "displace")
		elif body is RigidBody2D:
			var body_force = abs(body.linear_velocity.length())
			var unmodified_force = force_vector.normalized() * body_force + force_vector
			const max_distance = 150.0
			var additional_force = (1 - clamp((body.position - position).length(), 0.0, max_distance) / max_distance) * unmodified_force * 2.0
			body.linear_velocity = Vector2.ZERO
			body.apply_central_impulse(unmodified_force + additional_force)

func stop(bodies):
	for body in bodies:
		if body is RigidBody2D:
			body.linear_velocity = Vector2.ZERO
			body.angular_velocity = 0.0

func update_selected_body():
	if $Area2D.get_overlapping_bodies().is_empty():
		selected_body = null
		return

	var min_distance = 9999999999999999999.9
	for body in $Area2D.get_overlapping_bodies():
		var relative_body_position = body.position - position
		var aim_vector_normalized = (get_global_mouse_position() - position).normalized()
		var point_in_aim_vector = aim_vector_normalized * relative_body_position.dot(aim_vector_normalized)
		var distance_to_body = abs((point_in_aim_vector - relative_body_position).length_squared())
		if distance_to_body < min_distance:
			min_distance = distance_to_body
			selected_body = body

func orientate_power_area():
	$Area2D.rotation = position.angle_to_point(get_global_mouse_position())

var dot_texture = load("res://dot.png")

func draw_power_selection_arrow():
	# remove dots
	for child in $SelectionLine.get_children():
		$SelectionLine.remove_child(child)
		child.queue_free()
	
	if selected_body != null && power_mode == PowerMode.SELECTOR:
		var dot_amount = (selected_body.position - position).length() / 30
		for n in dot_amount:
			n = dot_amount - n
			var dot = Sprite2D.new()
			dot.texture = dot_texture
			dot.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST
			dot.position = (selected_body.position - position) * n/dot_amount
			$SelectionLine.add_child(dot)
