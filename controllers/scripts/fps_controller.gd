class_name Player 
extends CharacterBody3D

@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATIONPLAYER : AnimationPlayer
@export var CROUCH_SHAPECAST : Node3D
@export var weaponController : WeaponController

@onready var healthTimer = $"Health Regen Timer"
@onready var weaponRig = $CameraController/Camera3D/WeaponRig
@onready var damageVignette = $CameraController/Camera3D/CanvasLayer/DamageVignette

var cameraOffset : Vector3

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3
var isCrouching : bool = false

var health : float = 100
var maxHealth : float = 100
var healthRecovery : float = 12.0

var stamina : float = 100
var maxStamina : float = 100
var sprintRecovery : float = 16.0
var sprintUse : float = 24.0


var currentRotation : float
var playerDead = false


var red = Color(0.75,0.0,0.0,1.0)
var white = Color(1.0,1.0,1.0,1.0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = 14

func _unhandled_input(event: InputEvent) -> void:
	
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		
func _input(event):
	
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _update_camera(delta):
	if Global.inputAllowed == true:
		# Rotates camera using euler rotation
		currentRotation = _rotation_input
		_mouse_rotation.x += _tilt_input * delta
		_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
		_mouse_rotation.y += _rotation_input * delta
		
		_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
		_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

		CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
		global_transform.basis = Basis.from_euler(_player_rotation)
		
		CAMERA_CONTROLLER.rotation.z = 0.0

		_rotation_input = 0.0
		_tilt_input = 0.0
	
func _ready():
	Global.roundLabel = %RoundLabel
	Global.player = self
	Global.roundChange.connect(flashLabel)
	health = 100
	maxHealth = 100
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Prevents player from activating crouch cast
	CROUCH_SHAPECAST.add_exception($".")

func _process(delta):
	_update_camera(delta)
	damageVignette.material.set_shader_parameter("intensity", move_toward(damageVignette.material.get_shader_parameter("intensity"), 0.0, Global.fiLerp(0.01, delta)))
	# Update camera movement based on mouse movement
	CAMERA_CONTROLLER.rotation = lerp(CAMERA_CONTROLLER.rotation, CAMERA_CONTROLLER.rotation + cameraOffset, Global.fiLerp(0.025, delta))
	cameraOffset = lerp(cameraOffset, Vector3(0,0,0), Global.fiLerp(0.05, delta))
	

	if stamina < maxStamina and Global.currentStateName != "SprintingPlayerState":
		stamina = min(stamina + sprintRecovery * delta, maxStamina)
		
		
	if health < maxHealth and healthTimer.is_stopped():
		health = min(health + healthRecovery * delta, maxHealth)
	
	if health / maxHealth < 0.33 and playerDead == false:
		damageVignette.material.set_shader_parameter("intensity",0.5)


func updateGravity(delta) -> void:
	velocity.y -= gravity * delta
	

func updateInput(speed: float, acceleration: float, deceleration: float) -> void:
		# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	Global.debug.addProperty("Movement Speed",speed, 2)
	var delta = get_process_delta_time()
	
	if direction:
		velocity.x = lerp(velocity.x,direction.x * speed, Global.fiLerp(acceleration, delta))
		velocity.z = lerp(velocity.z,direction.z * speed, Global.fiLerp(acceleration, delta))
	else:
		velocity.x = move_toward(velocity.x, 0, Global.fiLerp(deceleration, delta))
		velocity.z = move_toward(velocity.z, 0, Global.fiLerp(deceleration, delta))

func updateVelocity() -> void:
		move_and_slide()
		Global.debug.addProperty("Player Y Velocity", velocity.y, 1)

func flashLabel():
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(%RoundLabel.label_settings, "font_color", white, 1.0)
	tween.tween_property(%RoundLabel.label_settings, "font_color", red, 1.0)

func meleeLunge():
	velocity += -global_transform.basis.z * 14

func takePlayerDamage(damage):
	health -= damage
	damageVignette.material.set_shader_parameter("intensity",0.5)
	if health > 0:
		healthTimer.start(3)
	else:
		deathAnimation()

func deathAnimation():
	playerDead = true
	Global.inputAllowed = false
	weaponRig.visible = false
	ANIMATIONPLAYER.play("crouch", -1.0, 2)

func landAnimation():
	var landingTween = create_tween()
	landingTween.tween_property(weaponRig, "position", Vector3(0,-0.2,0), 0.15)
	landingTween.tween_property(weaponRig, "position", Vector3(0,0,0), 0.3)
