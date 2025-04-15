extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var attack_sfx = $AttackSFX
@onready var jump_sfx = $JumpSFX
@onready var pickup_particles = $PickupParticles

@export var SPEED : float = 100.0
@export var JUMP_VELOCITY : float = -130.0
@export var DBL_JUMP_VELOCITY : float = JUMP_VELOCITY * .75

@onready var left_attack = $Attacks/LeftAttack
@onready var right_attack = $Attacks/RightAttack

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const PLAYER_HEAL = preload("res://wasd-movement/assets/particles/player_heal.tres")
const LANDING_EFFECT = preload("res://wasd-movement/characters/landing_effect.tscn")
const PLAYER_COIN_PICKUP = preload("res://wasd-movement/assets/particles/player_coin_pickup.tres")

var can_double_jump := false
var animation_locked := false
var direction : Vector2 = Vector2.ZERO
var was_in_air := false

func _ready():
	GameState.health_increased.connect(heal)
	GameState.coins_increased.connect(coin_pickup)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		was_in_air = true
	else: 
		can_double_jump = true
		if was_in_air == true:
			land()
			var landingFX = LANDING_EFFECT.instantiate()
			landingFX.position = global_position + Vector2(0, -8)
			get_tree().get_root().add_child(landingFX)
		was_in_air = false
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		elif can_double_jump:
			dbl_jump()
			can_double_jump = false
	
	if Input.is_action_just_pressed("attack"):
		attack()
	
	if Input.is_action_just_pressed('interact'):
		if not GameState.interactables.is_empty():
			GameState.interactables[0].interact()

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
	jump_sfx.play()
	sprite.play('land')
	animation_locked = true
	
func attack():
	sprite.play('attack')
	animation_locked = true
	attack_sfx.play()
	
func heal():
	pickup_particles.process_material = PLAYER_HEAL
	pickup_particles.emitting = true
	
func coin_pickup():
	pickup_particles.process_material = PLAYER_COIN_PICKUP
	pickup_particles.emitting = true

func falling():
	sprite.play('fall')
	animation_locked = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if ['sheath'].has(sprite.animation):
		left_attack.disabled = true
		right_attack.disabled = true
		animation_locked = false
	if ['attack'].has(sprite.animation):
		if sprite.flip_h == true:
			left_attack.disabled = false
		else:
			right_attack.disabled = false
		sprite.play('sheath')
	if ['jump'].has(sprite.animation):
		falling()
	if ['land'].has(sprite.animation):
		animation_locked = false


func _on_interaction_area_entered(area):
	GameState.add_to_interactables(area)

func _on_interaction_area_exited(area):
	GameState.remove_from_interactables(area)
