extends Sprite2D

@onready var heal = $Heal
@onready var collision = $Area2D/CollisionShape2D

func _on_area_2d_area_entered(_area):
	heal.play()
	GameState.health += 1
	hide()

func _on_pickup_finished():
	queue_free()
