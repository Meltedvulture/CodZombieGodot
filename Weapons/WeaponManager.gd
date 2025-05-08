@tool

extends Node3D

class_name WeaponController

# OnReady variables
@onready var weaponMesh : MeshInstance3D = %WeaponMesh
@onready var weaponMagazine : MeshInstance3D = %WeaponMagazine
@onready var weaponBolt : MeshInstance3D = %WeaponBolt
@onready var weaponShadow : MeshInstance3D = %WeaponShadow

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

#********Animation names Index:********
		# "fullReload"
		# "emptyReload"
		# "startReload"
		# "finishReload"
		# "shellReload"
		# "boltCycle"
		# "shoot"
		
		# Documemtation stuff:
		# Magazine reloads are for guns where all ammo is loaded at once
		# Shell reloads are for guns where they load individual rounds

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
var maxClipAmmo
var clipAmmo


var canShoot : bool = true
var weaponName
var weaponAccuracy
var time_per_shot: float = 0.1  # Default time between shots (calculated dynamically)
var cooldown_timer: float = 0.0  # Tracks the remaining cooldown time
var bulletHole = preload("res://Scenes/Bullet Hole.tscn")
var maxInventorySize = 2 #Arrays start at 0, we have 2 weapon slots
var weaponInventory = []
var weaponAmmoInventory = []
var currentWeaponIndex : int = 0
var shotgun
var fireMode
var reloadMode

@export var weaponAnimationPlayer : AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.reserveLabel = %Reserve
	Global.clipLabel = %Clip
	Global.pointsLabel = %Points
	Global.weaponManager = self
	#weaponInventory.resize(1)
	addWeapon("res://Weapons/1911.tres")
	loadWeapon()

func _input(event):
	if event.is_action_pressed("weaponDown"):
		if !weaponAnimationPlayer.is_playing():
			switchWeapon(1)

	if event.is_action_pressed("weaponUp"):
		if !weaponAnimationPlayer.is_playing():
			switchWeapon(-1)
	
	if event.is_action_pressed("knife"):
		knife()

	if event is InputEventMouseMotion:
		mouseMovement = event.relative

func addWeapon(WeaponPath: String):
	if weaponInventory.size() < maxInventorySize:
		weaponInventory.append(WeaponPath)
		var weapon = load(WeaponPath)
		weaponAmmoInventory.append([weapon.clip, weapon.reserve])
	else:
		weaponInventory[currentWeaponIndex] = WeaponPath
		var weapon = load(WeaponPath)
		weaponAmmoInventory[currentWeaponIndex] = [weapon.clip, weapon.reserve]
	loadWeapon()

func switchWeapon(direction: int) -> void:
	# Increment or decrement the current weapon index based on the direction
	currentWeaponIndex += direction
	
	# Use modulo (%) to loop the index within the bounds of the array
	# Ensure it works correctly for negative indices by adding maxInventorySize before taking the modulus
	currentWeaponIndex = wrap_index(currentWeaponIndex, weaponInventory.size())
	
	# Equip the weapon at the new index
	loadWeapon()


func wrap_index(index: int, size: int) -> int:
	# Wrap the index to stay within [0, size)
	if size == 0:
		return 0  # Avoid division by zero if the inventory is empty
	return (index % size + size) % size


func loadWeapon():
	if weaponType == null:
		return

	if !Engine.is_editor_hint():
		weaponType = load(weaponInventory[currentWeaponIndex])

	weaponName = weaponType.name
	weaponMesh.mesh = weaponType.mesh
	weaponMagazine.mesh = weaponType.magazine
	weaponBolt.mesh = weaponType.bolt
	weaponShadow.mesh = weaponType.mesh

	position = weaponType.position
	rotation_degrees = weaponType.rotation
	scale = weaponType.scale
	weaponShadow.visible = weaponType.shadow
	idleSwayAdjustment = weaponType.idleSwayAdjustment
	idleSwayRotationStrength = weaponType.idleSwayRotationStrength
	randomSwayAmount = weaponType.randomSwayAmount

	shotgun = weaponType.shotgun
	fireMode = weaponType.fireMode
	reloadMode = weaponType.reloadMode

	# Load ammo from weaponAmmoInventory instead of resetting to default
	if currentWeaponIndex < weaponAmmoInventory.size():
		var ammo_data = weaponAmmoInventory[currentWeaponIndex]
		clipAmmo = ammo_data[0]
		reserveAmmo = ammo_data[1]
	else:
		clipAmmo = weaponType.clip
		reserveAmmo = weaponType.reserve
		weaponAmmoInventory.append([clipAmmo, reserveAmmo])

	maxClipAmmo = weaponType.maxClip
	Global.clipLabel.text = str(clipAmmo)
	Global.reserveLabel.text = str(reserveAmmo)
	time_per_shot = 60.0 / weaponType.rpm
	weaponAccuracy = weaponType.Accuracy

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
		
		if shotgun:
			for i in 8:
				var accuracyAdjustment = Vector3 (
				rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
				rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
				rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy)
				)
				

				var endpoint = origin + camera.project_ray_normal(screenCenter) * 1000 + accuracyAdjustment * 10
				var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
				query.collide_with_bodies = true
				var result = spaceState.intersect_ray(query)
				
				var hitPosition = result.get("position")
				var hitNormal = result.get("normal")
				var hitBody = result.get("collider")  # Get the object that was hit
				if hitBody and hitBody.has_method("take_damage"):
					hitBody.take_damage(weaponType.Damage)  # Deal damage to the enemy
				
				#Apply decal
				if result:
					var instance = bulletHole.instantiate()
					get_tree().root.add_child(instance)
					instance.global_position = hitPosition
					instance.look_at(instance.global_transform.origin + hitNormal, Vector3.UP)
					instance.rotate_object_local(Vector3(1,0,0), 90)
					removeHitMark(instance)
		else:
			var accuracyAdjustment = Vector3 (
			rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
			rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
			rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy)
			)
				

			var endpoint = origin + camera.project_ray_normal(screenCenter) * 1000 + accuracyAdjustment * 10
			var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
			query.collide_with_bodies = true
			var result = spaceState.intersect_ray(query)
				
			var hitPosition = result.get("position")
			var hitNormal = result.get("normal")
			var hitBody = result.get("collider")  # Get the object that was hit
			if hitBody and hitBody.has_method("take_damage"):
				hitBody.take_damage(weaponType.Damage)  # Deal damage to the enemy
				
			#Apply decal
			if result:
				var instance = bulletHole.instantiate()
				get_tree().root.add_child(instance)
				instance.global_position = hitPosition
				instance.look_at(instance.global_transform.origin + hitNormal, Vector3.UP)
				instance.rotate_object_local(Vector3(1,0,0), 90)
				removeHitMark(instance)
		
		clipAmmo -= 1
		weaponAmmoInventory[currentWeaponIndex][0] = clipAmmo
		Global.updateLabels(clipAmmo, reserveAmmo) 
		weaponAnimationPlayer.stop()
		weaponAnimationPlayer.seek(0)
		weaponAnimationPlayer.play(weaponName + "/" + "shoot", -1, 2, false)
		

		if fireMode == "Bolt":
			await weaponAnimationPlayer.animation_finished
			weaponAnimationPlayer.play(weaponName + "/" + "boltCycle", -1, 1, false)
			
	elif reserveAmmo > 0 and clipAmmo == 0:
		reloadWeapon()
		return


func reloadWeapon():
	canShoot = false
	cooldown_timer = 100
	if reloadMode == "Shell":
		var ammoNeeded = maxClipAmmo - clipAmmo
		weaponAnimationPlayer.play(weaponName + "/" + "startReload", -1, 1, false)
		await weaponAnimationPlayer.animation_finished
		for n in ammoNeeded:
			weaponAnimationPlayer.play(weaponName + "/" + "shellReload", -1, 1, false)
			reserveAmmo -= 1
			clipAmmo += 1
			await weaponAnimationPlayer.animation_finished
		weaponAnimationPlayer.play(weaponName + "/" + "finishReload", -1, 1, false)
	else:
		if clipAmmo > 0:
			weaponAnimationPlayer.play(weaponName + "/" + "fullReload", -1, 1, false)
			await weaponAnimationPlayer.animation_finished
		else:
			weaponAnimationPlayer.play(weaponName + "/" + "emptyReload", -1, 1, false)
			await weaponAnimationPlayer.animation_finished
		var ammoNeeded = maxClipAmmo - clipAmmo
		if reserveAmmo >= ammoNeeded:
			reserveAmmo -= ammoNeeded
			clipAmmo = maxClipAmmo
		else:
			clipAmmo += reserveAmmo
			reserveAmmo = 0

	Global.updateLabels(clipAmmo, reserveAmmo)
	weaponAmmoInventory[currentWeaponIndex] = [clipAmmo, reserveAmmo]
	canShoot = true
	cooldown_timer = 0

func _process(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta  # Decrease the cooldown timer
	else:
		canShoot = true  # Allow shooting once the cooldown ends
		if fireMode == "Auto" and Input.is_action_pressed("shoot"):
			shoot()
		
		
	if !Engine.is_editor_hint():
		if Input.is_action_just_pressed("reload") and clipAmmo != maxClipAmmo:
			reloadWeapon()


func removeHitMark(Instance):
	await get_tree().create_timer(rng.randi_range(4, 12)).timeout
	Instance.queue_free()

func knife():
	if canShoot == true:
		weaponAnimationPlayer.stop()
		canShoot = false
		weaponAnimationPlayer.play("Melee", -1, 1.5)
		cooldown_timer = weaponAnimationPlayer.current_animation_length
		
		var camera = Global.player.CAMERA_CONTROLLER
		var spaceState = camera.get_world_3d().direct_space_state
		var screenCenter = get_viewport().size / 2
		var origin = camera.project_ray_origin(screenCenter)
		var endpoint = origin + camera.project_ray_normal(screenCenter) * 1.25
		var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
		query.collide_with_bodies = true
		var result = spaceState.intersect_ray(query)
		
		var hitBody = result.get("collider")  # Get the object that was hit
		if hitBody and hitBody.has_method("take_damage"):
			hitBody.take_damage(200)  # Deal damage to the enemy
		
		await weaponAnimationPlayer.animation_finished
		canShoot = true
#func _physics_process(delta) -> void:


#✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅
