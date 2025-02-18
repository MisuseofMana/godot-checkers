class_name GameState extends Node2D

@onready var light_readout = $CanvasLayer/Control/TurnReadout/Panel/MarginContainer/LightReadout
@onready var dark_readout = $CanvasLayer/Control/TurnReadout/Panel/MarginContainer/DarkReadout

@onready var lights_captures = $CanvasLayer/Control/LeftContainer/HBoxContainer/Panel2/MarginContainer/VBoxContainer/LightsCaptures
@onready var darks_captures = $CanvasLayer/Control/RightContainer/HBoxContainer/Panel2/MarginContainer/VBoxContainer/DarksCaptures

@onready var light_wins = $CanvasLayer/Control/LeftContainer/HBoxContainer/Panel2/MarginContainer/VBoxContainer/LightWins
@onready var dark_wins = $CanvasLayer/Control/RightContainer/HBoxContainer/Panel2/MarginContainer/VBoxContainer/DarkWins

@export var board : BoardState

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	light_readout.hide()

func handle_turn_changed(activePlayer):
	match activePlayer:
		board.WhosTurn.DARK:
			dark_readout.show()
			light_readout.hide()
		board.WhosTurn.LIGHT:
			light_readout.show()
			dark_readout.hide()

func add_piece_to_captured_readout(pieceTexture: Texture2D, whoCaptured):
	var textureNode = TextureRect.new()
	textureNode.texture = pieceTexture
	match whoCaptured:
		board.WhosTurn.DARK:
			darks_captures.add_child(textureNode)
		board.WhosTurn.LIGHT:
			lights_captures.add_child(textureNode)

func show_win_layer(whoWon: String):
	match whoWon:
		'light':
			light_wins.show()
			dark_wins.hide()
		'dark':
			light_wins.hide()
			dark_wins.show()
