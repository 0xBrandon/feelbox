extends CharacterBody2D

const MAX_SPEED    := 300.0
const ACCEL        := 2200.0   # how fast you reach top speed on the ground
const FRICTION     := 2600.0   # how fast you stop on the ground
const AIR_ACCEL    := 1500.0   # less control in the air...
const AIR_FRICTION := 320.0    # ...and a gentler brake, not an absent one

const JUMP_CUT := 0.40         # release early, keep 40% of the rise

const JUMP_VELOCITY     := -520.0
const GRAVITY_RISE      := 1500.0   # while going up
const GRAVITY_FALL      := 2900.0   # while coming down, almost twice as strong
const APEX_SPEED        := 110.0    # "near the top of the arc" threshold
const APEX_GRAVITY_MULT := 0.55     # gravity is weaker up there = hang time
const MAX_FALL          := 1200.0   # terminal velocity


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)

	var direction := Input.get_axis("move_left", "move_right")
	var accel     := ACCEL if is_on_floor() else AIR_ACCEL
	var friction  := FRICTION if is_on_floor() else AIR_FRICTION

	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT

	move_and_slide()


func _apply_gravity(delta: float) -> void:
	var g := GRAVITY_RISE if velocity.y < 0.0 else GRAVITY_FALL

	# Near the apex, ease off. This is the hang time.
	if absf(velocity.y) < APEX_SPEED:
		g *= APEX_GRAVITY_MULT

	velocity.y = minf(velocity.y + g * delta, MAX_FALL)
