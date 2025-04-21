class_name CrouchingPlayerState

extends PlayerMovementState

@export var speed: float = 2.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25
@export_range(1, 6, 0.1) var crouchSpeed : float = 4.0
@export var weaponBobSpeed : float = 7
@export var weaponBobH : float = 1.5
@export var weaponBobV : float = 1

@onready var crouchShapeCast : ShapeCast3D = %ShapeCast3D
var released  : bool = false


func enter(previousState) -> void:
	animation.speed_scale = 1.0
	if previousState.name != "SlidingPlayerState":
		animation.play("crouch", -1.0, crouchSpeed)
	elif previousState.name == "SlidingPlayerState":
		animation.current_animation = "crouch"
		animation.seek(1.0, true)

func exit() -> void:
	released = false

func update(delta):
	PLAYER.updateGravity(delta)
	PLAYER.updateInput(speed, acceleration, deceleration)
	PLAYER.updateVelocity()
	
	weapon.sway_weapon(delta, true)
	weapon.weaponBob(delta, weaponBobSpeed, weaponBobH, weaponBobV)
	
	if !Input.is_action_pressed("crouch"):
		uncrouch()

	if Input.is_action_just_pressed("shoot"):
		weapon.shoot()

func uncrouch():
	if crouchShapeCast.is_colliding() == false:
		animation.play("crouch", -1.0, -crouchSpeed, true)
		await animation.animation_finished
		if PLAYER.velocity.length() == 0:
			transition.emit("IdlePlayerState")
		else:
			transition.emit("WalkingPlayerState")
	elif crouchShapeCast.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch()
