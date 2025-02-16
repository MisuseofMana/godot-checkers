class_name PieceController extends TileMapLayer

@export var board : TileMapLayer

var piece_dictionary : Dictionary = {}
var activeCells : Array[Vector2i]
var activePiece : GamePiece

#region Signal Connect/Disconnect
func _on_piece_entered_tree(piece : GamePiece):
	piece.piece_clicked.connect(handle_piece_click)
	
func _on_piece_exiting_tree(piece : GamePiece):
	piece.piece_clicked.disconnect(handle_piece_click)
	piece_dictionary.erase(piece.get_piece_coords())
#endregion

#region Click Handling
func handle_piece_click(whichPiece: GamePiece):
	var coords : Vector2i = whichPiece.get_piece_coords()
	var diagonals = get_valid_moves(coords, whichPiece)
	if whichPiece.isClicked:
		for cell in diagonals:
			board.set_cell(cell, 1, board.get_cell_atlas_coords(cell), 1)
		activeCells = diagonals
		activePiece = whichPiece
	if not whichPiece.isClicked:
		for cell in diagonals:
			board.set_cell(cell, 1, board.get_cell_atlas_coords(cell), 0)
		activeCells = []
		activePiece = null
#endregion

#region Piece Movement Logic
func get_valid_moves(coords: Vector2i, piece: GamePiece):
	var availableDiagonals: Array[Vector2i]
	for diagonal in get_possible_board_tiles(coords, piece):
		if board.get_cell_source_id(diagonal) > -1:
			availableDiagonals.append(diagonal)
	return availableDiagonals

func get_possible_board_tiles(coords : Vector2i, piece: GamePiece) -> Array[Vector2i]:
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
	
# check the basic move squares on the board for pieces
	for diagonal: Vector2i in all_arbitrary_moves:
		var relativeCoord : Vector2i = coords + diagonal
		var neighborPiece: GamePiece = piece_dictionary.get(relativeCoord)
		if neighborPiece:
			if neighborPiece.piece_type != piece.piece_type:
				var next_rel_diagonal: Vector2i = relativeCoord + diagonal
				var farPiece: GamePiece = piece_dictionary.get(next_rel_diagonal)
				if not farPiece:
					capture_moves.append(next_rel_diagonal)
		if not neighborPiece:
			non_capture_moves.append(relativeCoord)
	
	if not capture_moves.is_empty():
		return capture_moves
	else:
		return non_capture_moves
#endregion

func move_piece(which: Vector2i):
	for cell in activeCells:
		board.set_cell(cell, 1, board.get_cell_atlas_coords(cell), 0)
		piece_dictionary.erase(activePiece.get_piece_coords())
		activePiece.position = map_to_local(which)
		piece_dictionary.get_or_add(activePiece.get_piece_coords(), activePiece)
