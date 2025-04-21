class_name idlePlayerState

extends PlayerMovementState

@export var speed: float = 1.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25
@export var topAnimSpeed : float = 3

func enter(previousState) -> void:
	animation.pause()

func update(delta):
	PLAYER.updateGravity(delta)
	PLAYER.updateInput(speed, acceleration, deceleration)
	PLAYER.updateVelocity()
	
	weapon.sway_weapon(delta, true)
	
	if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	
	if Global.player.velocity.length() > 0.0 and Global.player.is_on_floor():
		transition.emit("WalkingPlayerState")

	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
	
	if PLAYER.velocity.y < -2.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
	
	if Input.is_action_just_pressed("shoot"):
		weapon.shoot()
