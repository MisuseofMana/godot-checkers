extends Node2D

@onready var damage_crate_sfx = $DamageCrateSFX
@onready var destroy_crate_sfx = $DestroyCrateSFX
@onready var particles = $Particles
@onready var crate = $Crate
@onready var damage_collider = $Crate/Area2D/CollisionShape2D
@onready var invulnerable_timer = $InvulnerableTimer
@onready var crate_sprite = $Crate/CrateSprite

var spawnPoint : Vector2
var hitsToBreak : int = 3
var timesHit : int = 0
var invulerable : bool = false

const HEART = preload("res://wasd-movement/props/heart.tscn")

func _on_area_2d_area_entered(_area):
	if not invulerable:
		timesHit += 1
		if timesHit < hitsToBreak:
			damage_crate()
		else:
			destroy()

func toggle_invulnerable():
	invulerable = true
	invulnerable_timer.start()

func damage_crate():
	crate_sprite.frame += 1
	toggle_invulnerable()
	particles.amount = timesHit * 10
	particles.emitting = true
	damage_crate_sfx.play()
	
func destroy():
	spawnPoint = crate.global_position
	crate.queue_free()
	destroy_crate_sfx.play()
	particles.emitting = true
	spawn_heart.call_deferred()
	
func spawn_heart():
	var heart = HEART.instantiate()
	heart.position = spawnPoint
	get_tree().get_root().add_child(heart)
	
func _on_destroy_crate_finished():
	queue_free()

func _on_invulnerable_timer_timeout():
	invulerable = false
