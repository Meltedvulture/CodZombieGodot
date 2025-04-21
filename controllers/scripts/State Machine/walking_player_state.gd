class_name WalkingPlayerState

extends PlayerMovementState

@export var speed: float = 4.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25
@export var topAnimSpeed : float = 2.2
@export var weaponBobSpeed : float = 7
@export var weaponBobH : float = 1.5
@export var weaponBobV : float = 1

func enter(previousState) -> void:
	animation.play("Walking", -1.0,1.0)
	
func exit() -> void:
	animation.speed_scale = 1.0

func update(delta):
	PLAYER.updateGravity(delta)
	PLAYER.updateInput(speed, acceleration, deceleration)
	PLAYER.updateVelocity()
	setAnimationSpeed(Global.player.velocity.length())
	
	weapon.sway_weapon(delta, false)
	weapon.weaponBob(delta, weaponBobSpeed, weaponBobH, weaponBobV)
	
	
	if PLAYER.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")

	if Input.is_action_pressed("sprint") and PLAYER.is_on_floor():
		transition.emit("SprintingPlayerState")

	if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
	
	if PLAYER.velocity.y < -2.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")

	if Input.is_action_just_pressed("shoot"):
		weapon.shoot()

func setAnimationSpeed(spd):
	var alpha = remap(spd, 0.0, speed, 0.0, 1.0)
	animation.speed_scale = lerp(0.0, topAnimSpeed, alpha)
