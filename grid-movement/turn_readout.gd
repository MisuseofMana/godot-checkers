class_name TurnReadout extends CanvasLayer

@onready var whos_turn = $Control/TurnReadout/WhosTurn
@onready var who_won = $Control/TurnReadout/WhoWon

@onready var turn_icon = $Control/TurnReadout/WhosTurn/MarginContainer/Readout/Icon
@onready var turn_text = $Control/TurnReadout/WhosTurn/MarginContainer/Readout/Text
@onready var won_icon = $Control/TurnReadout/WhoWon/Margin/HBox/Icon
@onready var won_text = $Control/TurnReadout/WhoWon/Margin/HBox/Text
@onready var darks_captures = $Control/RightContainer/HBoxContainer/Panel2/MarginContainer/VBoxContainer/DarksCaptures
@onready var lights_captures = $Control/LeftContainer/HBoxContainer/Panel2/MarginContainer/VBoxContainer/LightsCaptures

const DARK_PIECE = preload("res://grid-movement/art/dark_piece.png")
const LIGHT_PIECE = preload("res://grid-movement/art/light_piece.png")
const DARK_KING = preload("res://grid-movement/art/dark-king.png")
const LIGHT_KING = preload("res://grid-movement/art/light-king.png")

signal reset_game

# Called when the node enters the scene tree for the first time.
func _ready():
	handle_turn_change('dark')
	who_won.hide()
	whos_turn.show()

func handle_turn_change(whosTurn: ):
	match whosTurn:
		'light':
			turn_text.text = "LIGHT'S TURN TO PLAY"
			turn_icon.texture = LIGHT_PIECE
		'dark':
			turn_text.text = "DARK'S TURN TO PLAY"
			turn_icon.texture = DARK_PIECE
	who_won.hide()
	whos_turn.show()

func handle_win(whosTurn: String):
	match whosTurn:
		'light':
			won_text.text = "LIGHT WINS"
			won_icon.texture = LIGHT_KING
		'dark':
			won_text.text = "DARK WINS"
			won_icon.texture = DARK_KING
	who_won.show()
	whos_turn.hide()

func add_piece_to_captured_readout(pieceTexture: Texture2D, whoCaptured: String):
	var textureNode = TextureRect.new()
	textureNode.texture = pieceTexture
	match whoCaptured:
		'light':
			darks_captures.add_child(textureNode)
		'dark':
			lights_captures.add_child(textureNode)
			
func play_again():
	reset_game.emit()
