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

var interactables : Array[Area2D]:
	set(newValue):
		interactables = newValue
		

func add_to_interactables(area: Area2D):
	var newInteractables = interactables.duplicate()
	newInteractables.push_front(area)
	interactables = newInteractables
	
func remove_from_interactables(area: Area2D):
	var newInteractables = interactables.duplicate()
	newInteractables.erase(area)
	interactables = newInteractables

func _ready():
	coins = 1
	health = 3
