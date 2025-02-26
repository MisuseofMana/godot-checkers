extends Node2D

@onready var shatter = $Shatter
@onready var particles = $Particles
@onready var pot = $Pot
@onready var pot_sprite = $Pot/PotSprite
@onready var collider = $Pot/CollisionShape2D

var spawnPoint : Vector2

const COIN = preload("res://wasd-movement/props/coin.tscn")

func _on_area_2d_area_entered(_area):
	destroy()

func destroy():
	spawnPoint = pot.global_position
	pot.queue_free()
	shatter.play()
	particles.emitting = true
	spawn_coin.call_deferred()
	
func spawn_coin():
	var coin = COIN.instantiate()
	coin.position = spawnPoint
	get_tree().get_root().add_child(coin)
	
func _on_shatter_finished():
	queue_free()
