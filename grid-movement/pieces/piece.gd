class_name GamePiece extends Node2D

#region Variable/Signal/Export Setup
@export var piece_type : StringName

@onready var area_2d = $PieceSprite/Area2D
@onready var anims = $PieceSprite/AnimationPlayer
@onready var piece_sprite = $PieceSprite
@onready var collider = $PieceSprite/Area2D/CollisionShape2D
@onready var capture_sound = $CaptureSound
@onready var piece_sounds = $PieceSounds
@onready var promotion_sound = $PromotionSounds

const DARK_KING = preload("res://grid-movement/art/dark-king.png")
const LIGHT_KING = preload("res://grid-movement/art/light-king.png")

signal piece_clicked(whichPiece: GamePiece)

var pieceParent : PieceController
var isClicked : bool = false
var isPromoted : bool = false
#endregion

func _ready():
	if get_parent() is PieceController:
		pieceParent = get_parent()
		pieceParent.piece_dictionary.get_or_add(get_piece_coords(), self)

#region Click Handling
func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if isClicked:
			unselect_piece()
		else:
			select_piece()
	if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
		promote_piece()

func select_piece():
	isClicked = true
	piece_clicked.emit(self)
	anims.play('raise')

func unselect_piece():
	isClicked = false
	piece_clicked.emit(self)
	anims.play_backwards('raise')
#endregion

# allows us to interface with the board by matchin piece coords to board coords
func get_piece_coords() -> Vector2i:
#	if piece does not have a tilemap parent return null
	if not pieceParent:
#		Vector2i(-1,-1) is the Vector2i equivalent to null
		return Vector2i(-1,-1)
	return pieceParent.local_to_map(position)
	
func promote_piece():
	if not isPromoted:
		isPromoted = true
		anims.play('promotion')
		match piece_type:
			'light':
				piece_sprite.texture = LIGHT_KING
			'dark':
				piece_sprite.texture = DARK_KING

func disable_collision():
	collider.disabled = true

func enable_collision():
	collider.disabled = false
