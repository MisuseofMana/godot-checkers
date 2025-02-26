extends Sprite2D

@onready var pickup = $Pickup
@onready var collision = $Area2D/CollisionShape2D

func _on_area_2d_area_entered(_area):
	pickup.play()
	GameState.coins += 1
	hide()

func _on_pickup_finished():
	queue_free()
