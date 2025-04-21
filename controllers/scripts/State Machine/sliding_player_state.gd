class_name SlidingPlayerState

extends PlayerMovementState

@export var speed: float = 10.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25
@export var tiltAmount : float = 1
@export_range(1, 6, 0.1) var slideAnimSpeed : float = 4.0

@onready var crouchShapeCast : ShapeCast3D = %ShapeCast3D

func enter(_previousState) -> void:
	setTilt(PLAYER.currentRotation)
	animation.speed_scale = 1.0
	animation.play("Sliding", -1.0, slideAnimSpeed)

func update(delta):
	PLAYER.updateGravity(delta)
	PLAYER.updateInput(speed, acceleration, deceleration)
	PLAYER.updateVelocity()

func setTilt(playerRotation) -> void:
	var tilt = Vector3.ZERO
	tilt.z = clamp(tiltAmount * playerRotation, -0.1, 0.1)
	if tilt.z == 0.0:
		tilt.z = 0.05
	#for i in range(0,8):
		#print(str(i) + ": " + str(animation.get_animation("Sliding").track_get_path(i)))
	animation.get_animation("Sliding").bezier_track_set_key_value(3,1,tilt.z)
	animation.get_animation("Sliding").bezier_track_set_key_value(3,1,tilt.z)

func finish():
	transition.emit("CrouchingPlayerState")
