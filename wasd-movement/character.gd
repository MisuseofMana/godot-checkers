extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

@export var SPEED : float = 100.0
@export var JUMP_VELOCITY : float = -130.0
@export var DBL_JUMP_VELOCITY : float = JUMP_VELOCITY * .75

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var can_double_jump := false
var animation_locked := false
var direction : Vector2 = Vector2.ZERO
var was_in_air := false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		was_in_air = true
	else: 
		can_double_jump = true
		if was_in_air == true:
			land()
		was_in_air = false
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		elif can_double_jump:
			dbl_jump()
			can_double_jump = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "jump", "crouch")
	if direction.x != 0 and sprite.animation != 'land':
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animation()
	update_sprite_direction()

func update_animation():
	if not animation_locked:
		if direction.x != 0:
			sprite.play('walk')
		else:
			sprite.play('idle')
			
func update_sprite_direction():
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true
		
func jump():
	sprite.play('jump')
	velocity.y = JUMP_VELOCITY
	animation_locked = true

func dbl_jump():
	sprite.play('jump')
	velocity.y = DBL_JUMP_VELOCITY
	animation_locked = true

func land():
	sprite.play('land')
	animation_locked = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == 'land':
		animation_locked = false
		
