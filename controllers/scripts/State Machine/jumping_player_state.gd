class_name JumpingPlayerState

extends PlayerMovementState

@export var speed: float = 6.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25
@export var jumpVelocity : float = 5
@export var weaponBobSpeed : float = 7
@export var weaponBobH : float = 1.5
@export var weaponBobV : float = 1
@export_range(0.0, 2.0, 0.1) var inputMultiplier : float = 0.05

# Called when the node enters the scene tree for the first time.
func enter(previousState) -> void:
	PLAYER.velocity.y += jumpVelocity
	animation.pause()

func update(delta):
	PLAYER.updateGravity(delta)
	#Can be used for boost jumping (MOVEMENT GAME YEAHHH)
	#PLAYER.updateInput(PLAYER.velocity.length() + speed * inputMultiplier, acceleration, deceleration)
	PLAYER.updateVelocity()
	weapon.sway_weapon(delta, false)
	weapon.weaponBob(delta, weaponBobSpeed, weaponBobH, weaponBobV)
	
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
	
	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")

	if Input.is_action_pressed("knife"):
		weapon.knife()

	if Input.is_action_just_pressed("shoot"):
		weapon.shoot()
