extends CharacterBody2D

const SPEED         := 300.0
const JUMP_VELOCITY := -520.0
const GRAVITY       := 1400.0


func _physics_process(delta: float) -> void:
	# Gravity, every frame, always.
	velocity.y += GRAVITY * delta

	# Horizontal: instantly on, instantly off. This is the part that feels bad.
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	# Jump: one fixed impulse, only from the ground.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Applies velocity, handles collision. Godot does the hard part.
	move_and_slide()
