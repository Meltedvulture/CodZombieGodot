class_name PlayerMovementState

extends State

var PLAYER: Player
var animation: AnimationPlayer
var weapon: WeaponController
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	animation = PLAYER.ANIMATIONPLAYER
	weapon = PLAYER.weaponController
