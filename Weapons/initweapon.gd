@tool

extends Node3D

class_name WeaponController

# Exported variables
@export var weaponType : Weapons:
	set(value):
		weaponType = value
		if Engine.is_editor_hint():
			loadWeapon()

@export var swaySpeed : float = 1.2
@export var reset : bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			loadWeapon()

# OnReady variables
@onready var weaponMesh : MeshInstance3D = %WeaponMesh
@onready var weaponShadow : MeshInstance3D = %WeaponShadow

# Internal variables
var mouseMovement : Vector2
var randomSwayX
var randomSwayY
var randomSwayAmount = 0
var time : float = 0.0
var idleSwayAdjustment = 0
var idleSwayRotationStrength
var rng = RandomNumberGenerator.new()
var weaponBobAmount : Vector2 = Vector2(0,0)
var reserveAmmo
var clipAmmo
var canShoot : bool = true
var weaponName

var time_per_shot: float = 0.1  # Default time between shots (calculated dynamically)
var cooldown_timer: float = 0.0  # Tracks the remaining cooldown time

var bulletHole = preload("res://Scenes/Bullet Hole.tscn")

@export var reserveLabel : Label
@export var clipLabel : Label
@export var weaponAnimationPlayer : AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize with a default weapon type if none is selected
	if weaponType == null:
		weaponType = load("res://Weapons/Crowbar.tres")
	loadWeapon()

func _input(event):
	if event.is_action_pressed("weapon1"):
		weaponType = load("res://Weapons/1911.tres")
		loadWeapon()

	if event.is_action_pressed("weapon2"):
		weaponType = load("res://Weapons/Crowbar.tres")
		loadWeapon()

	if event is InputEventMouseMotion:
		mouseMovement = event.relative

func loadWeapon() -> void:
	if weaponType == null:
		return
	
	weaponName = weaponType.name
	weaponMesh.mesh = weaponType.mesh  # Set weapon mesh
	weaponShadow.mesh = weaponType.mesh  # Set weapon mesh
	position = weaponType.position      # Set weapon position
	rotation_degrees = weaponType.rotation  # Set weapon rotation
	scale = weaponType.scale # Set weapon rotation
	weaponShadow.visible = weaponType.shadow  # Turn shadow on/off
	idleSwayAdjustment = weaponType.idleSwayAdjustment
	idleSwayRotationStrength = weaponType.idleSwayRotationStrength
	randomSwayAmount = weaponType.randomSwayAmount
	clipAmmo = weaponType.clip
	reserveAmmo = weaponType.reserve
	clipLabel.text = str(clipAmmo)
	reserveLabel.text = str(reserveAmmo)
	time_per_shot = 60.0 / weaponType.rpm  # Calculate time between shots

func sway_weapon(delta, isIdle: bool) -> void:
	if weaponType == null:
		return
		
	# Clamp mouse movement
	mouseMovement.x = clamp(mouseMovement.x, weaponType.sway_min.x, weaponType.sway_max.x)
	mouseMovement.y = clamp(mouseMovement.y, weaponType.sway_min.y, weaponType.sway_max.y)
	
	#Idle Bob
	if isIdle:
		# Get sway noise
		var swayRandom : float = getSwayNoise()
		var swayRandomAdjusted = swayRandom * idleSwayAdjustment

		# Update time for sine waves
		time += delta * (swaySpeed + swayRandom)

		# Calculate random sway
		randomSwayX = sin(time * 1.5 + swayRandomAdjusted)
		randomSwayY = sin(time - swayRandomAdjusted)

	# Lerp weapon position
		if randomSwayAmount != 0:
			randomSwayX /= randomSwayAmount
			randomSwayY /= randomSwayAmount

		position.x = lerp(position.x, weaponType.position.x - (mouseMovement.x * weaponType.swayAmountPosition + randomSwayX) * delta, weaponType.swaySpeedPosition)
		position.y = lerp(position.y, weaponType.position.y + (mouseMovement.y * weaponType.swayAmountPosition + randomSwayY) * delta, weaponType.swaySpeedPosition)

		# Lerp weapon rotation
		rotation_degrees.y = lerp(rotation_degrees.y, weaponType.rotation.y + (mouseMovement.x * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)
		rotation_degrees.x = lerp(rotation_degrees.x, weaponType.rotation.x - (mouseMovement.y * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)
	
	#Movement bob (Not idle)
	else:
		position.x = lerp(position.x, weaponType.position.x - (mouseMovement.x * weaponType.swayAmountPosition + weaponBobAmount.x) * delta, weaponType.swaySpeedPosition)
		position.y = lerp(position.y, weaponType.position.y + (mouseMovement.y * weaponType.swayAmountPosition + weaponBobAmount.y) * delta, weaponType.swaySpeedPosition)
		# Lerp weapon rotation
		rotation_degrees.y = lerp(rotation_degrees.y, weaponType.rotation.y + (mouseMovement.x * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)
		rotation_degrees.x = lerp(rotation_degrees.x, weaponType.rotation.x - (mouseMovement.y * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)

func weaponBob(delta, bobSpeed: float, hbobAmount: float, vbobAmount) -> void:
	time += delta
	
	weaponBobAmount.x = sin(time * bobSpeed) * hbobAmount
	weaponBobAmount.y = abs(cos(time * bobSpeed) * vbobAmount)
	
func getSwayNoise() -> float: 
	var noiseLocation : float = rng.randf_range(0, 1.0)
	return noiseLocation

func shoot() -> void:
	if clipAmmo != 0 and canShoot == true:
		# Trigger the shot
		canShoot = false  # Prevent further shooting
		cooldown_timer = time_per_shot  # Reset the cooldown timer
		
		
		#Run Raycast function
		var camera = Global.player.CAMERA_CONTROLLER
		var spaceState = camera.get_world_3d().direct_space_state
		var screenCenter = get_viewport().size / 2
		var origin = camera.project_ray_origin(screenCenter)
		var endpoint = origin + camera.project_ray_normal(screenCenter) * 1000
		var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
		query.collide_with_bodies = true
		var result = spaceState.intersect_ray(query)
		
		var hitPosition = result.get("position")
		var hitNormal = result.get("normal")
		clipAmmo -= 1
		updateLabels()
		weaponAnimationPlayer.stop()
		weaponAnimationPlayer.seek(0)
		weaponAnimationPlayer.play(weaponName + "/" + "shoot", -1, 2, false)
		
		#Apply decal
		if result:
			var instance = bulletHole.instantiate()
			get_tree().root.add_child(instance)
			instance.global_position = hitPosition
			instance.look_at(instance.global_transform.origin + hitNormal, Vector3.UP)
			instance.rotate_object_local(Vector3(1,0,0), 90)
			await get_tree().create_timer(rng.randi_range(4, 12)).timeout
			instance.queue_free()
	elif reserveAmmo > 0:
		reloadWeapon()

func updateLabels():
	clipLabel.text = str(clipAmmo)
	reserveLabel.text = str(reserveAmmo)

func reloadWeapon():
	canShoot = false

func _process(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta  # Decrease the cooldown timer
	else:
		canShoot = true  # Allow shooting once the cooldown ends


#func _physics_process(delta) -> void:
