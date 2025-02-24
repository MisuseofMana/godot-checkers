extends CharacterBody2D
@onready var anims = $AnimatedSprite2D


const SPEED = 70.0
const JUMP_VELOCITY = -150.0

enum PState {
	FALLING,
	JUMPING,
	DOUBLE_JUMPING,
	CANCEL_JUMP,
	IDLE,
	WALKING,
	ATTACKING,
	HURT
}

var state : PState = PState.IDLE

func _physics_process(delta):
	if velocity.y > 0.0 and not is_on_floor():
		state = PState.FALLING
	if Input.is_action_just_pressed('jump') and is_on_floor():
		state = PState.JUMPING
	if Input.is_action_just_pressed('jump') and state == PState.FALLING:
		state = PState.DOUBLE_JUMPING
	if Input.is_action_just_released('jump') and velocity.y < 0.0:
		state = PState.CANCEL_JUMP
	if is_on_floor() and is_zero_approx(velocity.x):
		state = PState.IDLE
	if is_on_floor() and not is_zero_approx(velocity.x):
		state = PState.ATTACKING
	if velocity == Vector2.ZERO:
		anims.play('idle')
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		anims.play('jump')
		velocity.y = JUMP_VELOCITY
		
	var direction = Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * SPEED
		anims.play('walk')
		if velocity.x < 0:
			anims.flip_h = true
		else:
			anims.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
		
