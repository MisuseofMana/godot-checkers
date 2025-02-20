class_name BoardState extends Node2D

signal piece_added_to_jail(pieceToAdd: Texture2D, whoCaptured: String)
signal game_won(winText: String)
signal turn_changed(whosTurn: String)

enum Moves {
	CAPTURE,
	MOVE,
	NONE = -1
}

enum WhosTurn {
	DARK,
	LIGHT,
}

var turnStrings := ['dark', 'light']
		
var active_player := WhosTurn.DARK :
	set(value):
		active_player = value
		turn_changed.emit(turnStrings[active_player])
		
var prepared_move : Moves = Moves.NONE

func add_piece_to_jail(pieceTexture: Texture2D):
	
	piece_added_to_jail.emit(pieceTexture, turnStrings[active_player])

func _ready():
	turn_setup.call_deferred()

func check_for_win():
	var pieceCount : Array = []
	match active_player:
		WhosTurn.DARK:
			pieceCount = get_tree().get_nodes_in_group('dark_piece')
			if pieceCount.is_empty():
				game_won.emit('light')
		WhosTurn.LIGHT:
			pieceCount = get_tree().get_nodes_in_group('light_piece')
			if pieceCount.is_empty():
				game_won.emit('dark')
	
func turn_setup():
	match active_player:
		WhosTurn.DARK:
			get_tree().call_group('light_piece', 'disable_collision')
			get_tree().call_group('dark_piece', 'enable_collision')
		WhosTurn.LIGHT:
			get_tree().call_group('light_piece', 'enable_collision')
			get_tree().call_group('dark_piece', 'disable_collision')
	turn_changed.emit(turnStrings[active_player])
	check_for_win()

func change_turn():
	active_player = (int(active_player) + 1) % WhosTurn.size()
	turn_setup()

func lock_interaction_to_active_piece(whichPiece: GamePiece):
	match active_player:
		WhosTurn.DARK:
			get_tree().call_group('dark_piece', 'disable_collision')
		WhosTurn.LIGHT:
			get_tree().call_group('light_piece', 'disable_collision')
	whichPiece.enable_collision()

func unlock_active_pieces():
	match active_player:
		WhosTurn.DARK:
			get_tree().call_group('dark_piece', 'enable_collision')
		WhosTurn.LIGHT:
			get_tree().call_group('light_piece', 'enable_collision')

func lock_all_pieces():
	get_tree().call_group('dark_piece', 'disable_collision')
	get_tree().call_group('light_piece', 'disable_collision')

func set_move_type(moveName: StringName):
	match moveName:
		'capture':
			prepared_move = Moves.CAPTURE
		'move':
			prepared_move = Moves.MOVE

func clear_prepared_move():
	prepared_move = Moves.NONE
