class_name BoardController extends TileMapLayer

signal valid_move_clicked(where)

var active_cells: Array[Vector2i]

func _input(event):
	if event is InputEventMouse:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var clickedCell: Vector2i = local_to_map(to_local(event.position))
			var data = get_cell_tile_data(clickedCell)
			if data:
				if data.get_custom_data("validMove"):
					valid_move_clicked.emit(clickedCell)
					
func check_is_promotion_square(cell: Vector2i) -> bool:
	var tileData = get_cell_tile_data(cell)
	if tileData:
		return tileData.get_custom_data("promotionTile")
	else:
		return false
	
func show_available_moves(cells: Array[Vector2i]):
	active_cells = cells
	for cell in cells:
		if check_is_promotion_square(cell):
			set_cell(cell, 1, Vector2i(0,0), 2)
		else:
			set_cell(cell, 1, Vector2i(0,0), 1)

func hide_available_move_tiles():
	for cell in active_cells:
		if check_is_promotion_square(cell):
			set_cell(cell, 1, get_cell_atlas_coords(cell), 3)
		else:	
			set_cell(cell, 1, get_cell_atlas_coords(cell), 0)

func allow_or_deny_promotion(piece: GamePiece, cell: Vector2i):
	if check_is_promotion_square(cell):
		piece.promote_piece()
