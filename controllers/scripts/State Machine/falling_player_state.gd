class_name FallingPlayerState 

extends PlayerMovementState

@export var SPEED: float = 5.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25

func enter(previous_state) -> void:
	animation.pause()

func exit() -> void:
	pass

func update(delta: float) -> void:
	PLAYER.updateGravity(delta)
	PLAYER.updateVelocity()

	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
