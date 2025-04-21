class_name SprintingPlayerState

extends PlayerMovementState

@export var speed: float = 6.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25
@export var topAnimSpeed : float = 3
@export var weaponBobSpeed : float = 10.0
@export var weaponBobH : float = 1.5
@export var weaponBobV : float = 1

func enter(previousState) -> void:
	animation.play("Sprinting", 0.5, 1.0)

func update(delta):
	PLAYER.updateGravity(delta)
	PLAYER.updateInput(speed, acceleration, deceleration)
	PLAYER.updateVelocity()
	setAnimationSpeed(PLAYER.velocity.length())
	
	weapon.sway_weapon(delta, false)
	weapon.weaponBob(delta, weaponBobSpeed, weaponBobH, weaponBobV)
	
	#Stop sprinting when in air
	#if !Global.player.is_on_floor():
		#transition.emit("WalkingPlayerState")
		
	if Input.is_action_just_released("sprint"):
		transition.emit("WalkingPlayerState")
		
	if Input.is_action_just_pressed("crouch") and PLAYER.velocity.length() > 5.0:
		transition.emit("SlidingPlayerState")
		
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
	
	if PLAYER.velocity.y < -2.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")

func setAnimationSpeed(spd):
	var alpha = remap(spd, 0.0, speed, 0.0, 1.0)
	animation.speed_scale = lerp(0.0, topAnimSpeed, alpha)
