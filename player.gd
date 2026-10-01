extends CharacterBody2D

# --- horizontal ---
const MAX_SPEED    := 300.0
const ACCEL        := 2200.0   # how fast you reach top speed on the ground
const FRICTION     := 2600.0   # how fast you stop on the ground
const AIR_ACCEL    := 1500.0   # less control in the air...
const AIR_FRICTION := 320.0    # ...and a gentler brake, not an absent one

# --- jump ---
const JUMP_VELOCITY := -520.0
const JUMP_CUT      := 0.40    # release early, keep 40% of the rise

# --- gravity ---
const GRAVITY_RISE      := 1500.0   # while going up
const GRAVITY_FALL      := 2900.0   # while coming down, almost twice as strong
const APEX_SPEED        := 110.0    # "near the top of the arc" threshold
const APEX_GRAVITY_MULT := 0.55     # gravity is weaker up there = hang time
const MAX_FALL          := 1200.0   # terminal velocity

# --- forgiveness ---
const COYOTE_TIME := 0.10   # you can still jump this long after leaving a ledge
const JUMP_BUFFER := 0.12   # a press this early still counts when you land

# --- deformation ---
const JUMP_STRETCH    := Vector2(0.75, 1.30)   # thin and tall on launch
const LAND_SQUASH_MAX := Vector2(1.35, 0.70)   # wide and flat on a hard landing
const LAND_SOFT       := 250.0    # impact speed below this: no squash
const LAND_HARD       := 900.0    # impact speed at or above this: full squash
const SQUASH_RECOVER  := 12.0     # how fast the box returns to square

# --- the world reacts (new in v6) ---
const CAM_LEAD     := 46.0    # pixels the camera looks ahead at full sprint
const CAM_LERP     := 8.0     # how fast the lead catches up
const DUST_MIN     := 400.0   # impact speed that kicks up dust
const HARD_LANDING := 900.0   # impact speed that shakes the screen
const SHAKE_MAX    := 6.0     # pixels of jitter on the heaviest landing
const SHAKE_DECAY  := 30.0    # pixels per second, decaying linearly

@onready var body: Node2D          = $Body
@onready var cam:  Camera2D        = $Camera2D
@onready var dust: CPUParticles2D  = $Dust

var _coyote   := 0.0
var _buffer   := 0.0
var _squash   := Vector2.ONE
var _cam_lead := 0.0
var _shake    := 0.0


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)

	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	var accel     := ACCEL if is_on_floor() else AIR_ACCEL
	var friction  := FRICTION if is_on_floor() else AIR_FRICTION

	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# Coyote time: refill on the ground, drain in the air
	if is_on_floor():
		_coyote = COYOTE_TIME
	else:
		_coyote = maxf(_coyote - delta, 0.0)

	# Jump buffer: refill on press, drain every other frame
	if Input.is_action_just_pressed("jump"):
		_buffer = JUMP_BUFFER
	else:
		_buffer = maxf(_buffer - delta, 0.0)

	if _buffer > 0.0 and _coyote > 0.0:
		_jump()

	# Variable height: let go early, rise less
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT

	# Read these BEFORE moving: move_and_slide() destroys both
	var was_on_floor := is_on_floor()
	var impact       := velocity.y

	move_and_slide()

	if is_on_floor() and not was_on_floor:
		_on_land(impact)

	# Ease the deformation back to square, every frame
	_squash = _squash.lerp(Vector2.ONE, 1.0 - exp(-SQUASH_RECOVER * delta))
	body.scale = _squash

	_update_camera(delta)


func _jump() -> void:
	velocity.y = JUMP_VELOCITY
	_coyote = 0.0
	_buffer = 0.0
	_squash = JUMP_STRETCH


func _on_land(impact: float) -> void:
	var t := clampf(inverse_lerp(LAND_SOFT, LAND_HARD, impact), 0.0, 1.0)
	_squash = Vector2.ONE.lerp(LAND_SQUASH_MAX, t)

	if impact >= DUST_MIN:
		dust.restart()

	if impact >= HARD_LANDING:
		var s := clampf(inverse_lerp(HARD_LANDING, MAX_FALL, impact), 0.0, 1.0)
		_shake = maxf(_shake, lerpf(SHAKE_MAX * 0.5, SHAKE_MAX, s))


func _update_camera(delta: float) -> void:
	# Look ahead in the direction of travel, proportional to speed
	var target := velocity.x / MAX_SPEED * CAM_LEAD
	_cam_lead = lerpf(_cam_lead, target, 1.0 - exp(-CAM_LERP * delta))

	# Linear decay, so it reaches exactly zero
	_shake = maxf(_shake - SHAKE_DECAY * delta, 0.0)
	var jitter := Vector2(randf_range(-_shake, _shake), randf_range(-_shake, _shake))

	cam.offset = Vector2(_cam_lead, 0.0) + jitter


func _apply_gravity(delta: float) -> void:
	var g := GRAVITY_RISE if velocity.y < 0.0 else GRAVITY_FALL

	# Near the apex, ease off. This is the hang time.
	if absf(velocity.y) < APEX_SPEED:
		g *= APEX_GRAVITY_MULT

	velocity.y = minf(velocity.y + g * delta, MAX_FALL)
