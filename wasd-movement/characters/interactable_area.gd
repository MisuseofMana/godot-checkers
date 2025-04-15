class_name Interactable extends Area2D

signal interacted_with

var interaction_locked : bool = false

func interact():
	interaction_locked = true
	interacted_with.emit()
	
func unlock_interaction():
	interaction_locked = false
