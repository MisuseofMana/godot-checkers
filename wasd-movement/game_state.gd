extends Node

signal coins_changed(changedTo: int)
signal coins_increased
signal health_changed(changedTo: int)
signal health_increased

var coins : int = 0:
	set(newValue):
		if newValue > coins:
			coins_increased.emit()
		coins = newValue
		coins_changed.emit(newValue)
		
var health : int = 0:
	set(newValue):
		if newValue > health:
			health_increased.emit()
		health = newValue
		health_changed.emit(newValue)

func _ready():
	coins = 1
	health = 3
