class_name PieceController extends TileMapLayer

@export var board : TileMapLayer
@export var gameState : BoardState

var piece_dictionary : Dictionary = {}
var activePiece : GamePiece
var capture_paths : Dictionary = {}

signal piece_captured(pieceImage: Texture2D)
signal move_prepared(moveName: StringName)
signal reveal_available_moves(cells: Array[Vector2i])
signal interaction_locked_to_piece(whichPiece: GamePiece)
signal piece_interaction_unlocked
signal player_turn_changed
signal hide_avaliable_moves
signal requested_promotion(whichPiece: GamePiece, whichCell: Vector2i)
signal turn_continued

#region Signal Connect/Disconnect
func _on_piece_entered_tree(piece : GamePiece):
	piece.piece_clicked.connect(handle_piece_click)
	
func _on_piece_exiting_tree(piece : GamePiece):
	piece.piece_clicked.disconnect(handle_piece_click)
	piece_dictionary.erase(piece.get_piece_coords())
#endregion

#region Click Handling
func handle_piece_click(whichPiece: GamePiece):
	var diagonals = get_valid_moves(whichPiece)
	whichPiece.piece_sounds.play()
	if whichPiece.isClicked:
		reveal_available_moves.emit(diagonals)
		activePiece = whichPiece
		interaction_locked_to_piece.emit(whichPiece)
	if not whichPiece.isClicked:
		hide_avaliable_moves.emit()
		piece_interaction_unlocked.emit()
		gameState.clear_prepared_move()
		activePiece = null
#endregion

#region Piece Movement Logic
func get_valid_moves(piece: GamePiece):
	var availableDiagonals: Array[Vector2i]
	for diagonal in get_possible_board_tiles(piece):
		if board.get_cell_source_id(diagonal) > -1:
			availableDiagonals.append(diagonal)
	return availableDiagonals

func get_possible_board_tiles(piece: GamePiece) -> Array[Vector2i]:
	var coords : Vector2i = piece.get_piece_coords()
	var neighbor_diagonals : Array[Vector2i] = [
		Vector2i(-1,-1), #NW
		Vector2i(1,-1), #NE
		Vector2i(1,1), #SE
		Vector2i(-1,1), #SW
	]
	
#	determine moves for dark and light pieces
	var arbitrary_dark_moves: Array[Vector2i] = [neighbor_diagonals[0], neighbor_diagonals[1]]
	var arbitrary_light_moves: Array[Vector2i] = [neighbor_diagonals[2], neighbor_diagonals[3]]
	
	var all_arbitrary_moves: Array[Vector2i]
	
	match piece.piece_type:
		'dark':
			all_arbitrary_moves = arbitrary_dark_moves
		'light':
			all_arbitrary_moves = arbitrary_light_moves	
		
#	if the piece is promoted to king it can move forward and backwards
#	so color isn't relevant for defining movement
	if piece.isPromoted:
		all_arbitrary_moves = neighbor_diagonals
	
	var non_capture_moves: Array[Vector2i]
	var capture_moves: Array[Vector2i]
	
	capture_paths = {}
	
# check the basic move squares on the board for pieces
	for diagonal: Vector2i in all_arbitrary_moves:
		var relativeCoord : Vector2i = coords + diagonal
		var neighborPiece: GamePiece = piece_dictionary.get(relativeCoord)
		if neighborPiece:
			if neighborPiece.piece_type != piece.piece_type:
				var next_rel_diagonal: Vector2i = relativeCoord + diagonal
				if board.get_cell_atlas_coords(next_rel_diagonal) != Vector2i(-1, -1):
					var farPiece: GamePiece = piece_dictionary.get(next_rel_diagonal)
					if not farPiece:
						capture_paths.get_or_add(next_rel_diagonal, [relativeCoord, next_rel_diagonal])
						capture_moves.append(next_rel_diagonal)
		if not neighborPiece:
			non_capture_moves.append(relativeCoord)
	
	if capture_moves.size() > 0:
		move_prepared.emit('capture')
		return capture_moves
	else:
		move_prepared.emit('move')
		return non_capture_moves
#endregion

func filter_duplicates(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

func move_piece(which: Vector2i):
	hide_avaliable_moves.emit()

	activePiece.z_index = 100
	piece_dictionary.erase(activePiece.get_piece_coords())
	
	if gameState.prepared_move == gameState.Moves.CAPTURE:
#		run capture animations and logic
		var moves = capture_paths[which]
		await create_tween().tween_property(activePiece, 'position', map_to_local(moves[0]), 0.1).finished
		var capturedPiece : GamePiece = piece_dictionary[moves[0]]
		activePiece.anims.play('slam')
		await activePiece.anims.animation_finished
		piece_captured.emit(capturedPiece.piece_sprite.texture)
		capturedPiece.anims.play("captured")
		piece_dictionary.erase(moves[0])
		await create_tween().tween_property(activePiece, 'position', map_to_local(moves[1]), 0.1).finished
		var newMoves = get_valid_moves(activePiece)
		if gameState.prepared_move == gameState.Moves.CAPTURE:
			reveal_available_moves.emit(newMoves)
			turn_continued.emit()
			return
			
	if gameState.prepared_move == gameState.Moves.MOVE:
		await create_tween().tween_property(activePiece, 'position', map_to_local(which), 0.1).finished
		activePiece.anims.play_backwards('raise')
		await activePiece.anims.animation_finished
	
	piece_dictionary.get_or_add(activePiece.get_piece_coords(), activePiece)
	requested_promotion.emit(activePiece, activePiece.get_piece_coords())
	
	activePiece.isClicked = false
	activePiece.z_index = 1
	activePiece = null
	player_turn_changed.emit()
