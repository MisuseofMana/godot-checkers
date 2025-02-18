class_name BoardState extends Node2D

signal player_turn_changed

enum Moves {
	CAPTURE,
	MOVE,
	NONE = -1
}

enum WhosTurn {
	DARK,
	LIGHT,
}
var active_player := WhosTurn.DARK :
	set(value):
		active_player = value
		player_turn_changed.emit()
		
var prepared_move : Moves = Moves.NONE

func _ready():
	turn_setup.call_deferred()

func turn_setup():
	match active_player:
		WhosTurn.DARK:
			get_tree().call_group('light_piece', 'disable_collision')
			get_tree().call_group('dark_piece', 'enable_collision')
		WhosTurn.LIGHT:
			get_tree().call_group('light_piece', 'enable_collision')
			get_tree().call_group('dark_piece', 'disable_collision')
			
func change_turn():
	active_player = (active_player + 1) % WhosTurn.size()
	turn_setup()

func set_move_type(moveName: StringName):
	match moveName:
		'capture':
			prepared_move = Moves.CAPTURE
		'move':
			prepared_move = Moves.MOVE

func clear_prepared_move():
	prepared_move = Moves.NONE
