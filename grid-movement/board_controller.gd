extends TileMapLayer

signal valid_move_clicked(where)

func _input(event):
	if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var clickedCell: Vector2i = local_to_map(to_local(event.position))
		var data = get_cell_tile_data(clickedCell)
		if data:
			if data.get_custom_data("validMove"):
				valid_move_clicked.emit(clickedCell)
