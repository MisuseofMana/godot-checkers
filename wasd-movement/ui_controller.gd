extends CanvasLayer

@onready var health = $Control/MarginContainer/HBoxContainer/TextureRect/Health
@onready var coins = $Control/MarginContainer/HBoxContainer2/TextureRect4/Coins

func _ready():
	GameState.coins_changed.connect(update_coins)
	GameState.health_changed.connect(update_health)
	GameState.health = 3
	GameState.coins = 0

func update_health(to: int):
	print('health')
	health.text = str(to)
	
func update_coins(to: int):
	print('coins')
	coins.text = str(to)
