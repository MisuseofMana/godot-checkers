class_name GameController extends Node2D

@onready var board = $Board
var board_position: Vector2

const GAME_BOARD = preload("res://checkers/game-board.tscn")
const USER_INTERFACE = preload("res://checkers/user-interface.tscn")

@export var boardNode : BoardState
@export var uiNode: TurnReadout

func _ready():
	board_position = board.position

func connect_signals(node: Node):
	if node is TurnReadout:
		node.reset_game.connect(reset_game)
	if node is BoardState:
		node.turn_changed.connect(uiNode.handle_turn_change)
		node.piece_added_to_jail.connect(uiNode.add_piece_to_captured_readout)
		node.game_won.connect(uiNode.handle_win)
		

func reset_game():
	boardNode.queue_free()
	uiNode.queue_free()
	var uiInstance = USER_INTERFACE.instantiate()
	var boardInstance = GAME_BOARD.instantiate()
	boardInstance.position = board_position
	boardNode = boardInstance
	uiNode = uiInstance
	add_child(uiInstance)
	add_child(boardInstance)
	
	
func _input(event):
	if event.is_action_pressed("reset"):
		reset_game()
