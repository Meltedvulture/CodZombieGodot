@tool

extends Node3D

class_name WeaponController

# OnReady variables
@onready var weaponMesh : MeshInstance3D = %WeaponMesh
@onready var weaponMagazine : MeshInstance3D = %WeaponMagazine
@onready var weaponBolt : MeshInstance3D = %WeaponBolt
@onready var weaponShadow : MeshInstance3D = %WeaponShadow
@onready var shootTimer = $"../../../../Shoot Timer"
@onready var reticle = $"../../../../UserInterface/Reticle"
@onready var knifeNode = $"../../Knife"
@onready var bulletSpawnPoint = $"../../Bullet Spawn"

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
@export var weaponRig : Node3D
var mouseMovement : Vector2
var randomSwayX
var randomSwayY
var randomSwayAmount = 0
var time : float = 0.0
var idleSwayAdjustment = 0
var idleSwayRotationStrength
var rng = RandomNumberGenerator.new()
var weaponBobAmount : Vector2 = Vector2(0,0)
var canSwayPosition = true
var isSighting = false
var canSight = true
var actionable = true
#actionable is a master condition that controls when player can input
#anything related to weapons, this is for when player is locked in certain
#animations or states
#Everything else is for certain conditions

var reserveAmmo
var maxClipAmmo
var clipAmmo

var sightMode
var sightPosition
var sightSpeed

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
var verticalRecoil
var horizontalRecoil
var weaponBulletPhysics
var weaponBulletScene

@export var weaponAnimationPlayer : AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.reserveLabel = %Reserve
	Global.clipLabel = %Clip
	Global.pointsLabel = %Points
	Global.weaponManager = self
	#weaponInventory.resize(1)
	addWeapon("res://Weapons/1911.tres")
	apply_clip_and_fov_shader_to_view_model(knifeNode, -1.0)

func _input(event):
	if event.is_action_pressed("weaponDown"):
		if !weaponAnimationPlayer.is_playing():
			switchWeapon(1)

	if event.is_action_pressed("weaponUp"):
		if !weaponAnimationPlayer.is_playing():
			switchWeapon(-1)
	
		

	if event is InputEventMouseMotion:
		mouseMovement = event.relative

func addWeapon(WeaponPath: String):
	if weaponInventory.size() < maxInventorySize:
		weaponInventory.append(WeaponPath)
		var weapon = load(WeaponPath)
		weaponAmmoInventory.append([weapon.clip, weapon.reserve])
		currentWeaponIndex = weaponAmmoInventory.find(weapon)
	else:
		weaponInventory[currentWeaponIndex] = WeaponPath
		var weapon = load(WeaponPath)
		weaponAmmoInventory[currentWeaponIndex] = [weapon.clip, weapon.reserve]
	weaponAnimationPlayer.stop()
	if weaponName:
		actionable = false
		weaponAnimationPlayer.play(weaponName + "/" + "store")
		await weaponAnimationPlayer.animation_finished
		loadWeapon()
		weaponAnimationPlayer.play(weaponName + "/" + "pullout")
		await weaponAnimationPlayer.animation_finished
		actionable = true
	else:
		actionable = false
		loadWeapon()
		weaponAnimationPlayer.play(weaponName + "/" + "pullout")
		await weaponAnimationPlayer.animation_finished
		actionable = true

func switchWeapon(direction: int) -> void:
	if isSighting == false and actionable == true:
		# Increment or decrement the current weapon index based on the direction
		currentWeaponIndex += direction
		
		# Use modulo (%) to loop the index within the bounds of the array
		# Ensure it works correctly for negative indices by adding maxInventorySize before taking the modulus
		currentWeaponIndex = wrap_index(currentWeaponIndex, weaponInventory.size())
		
		# Equip the weapon at the new index
		actionable = false
		weaponAnimationPlayer.play(weaponName + "/" + "store")
		await weaponAnimationPlayer.animation_finished
		loadWeapon()
		weaponAnimationPlayer.play(weaponName + "/" + "pullout")
		await weaponAnimationPlayer.animation_finished
		actionable = true


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

	weaponBulletPhysics = weaponType.bulletPhysics
	
	if !Engine.is_editor_hint():
		if weaponType.bulletScene != null:
			weaponBulletScene = load(weaponType.bulletScene)


	shotgun = weaponType.shotgun
	fireMode = weaponType.fireMode
	reloadMode = weaponType.reloadMode
	
	sightMode = weaponType.sightMode
	sightPosition = weaponType.sightPosition
	sightSpeed = weaponType.sightSpeed
	
	verticalRecoil = weaponType.verticalRecoil
	horizontalRecoil = weaponType.horizontalRecoil
	

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
	
	
	apply_clip_and_fov_shader_to_view_model(self, -1.0)
	
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
		if canSwayPosition and isSighting == false:
			position.x = lerp(position.x, weaponType.position.x + (mouseMovement.x * weaponType.swayAmountPosition + randomSwayX) * delta, weaponType.swaySpeedPosition)
			position.y = lerp(position.y, weaponType.position.y - (mouseMovement.y * weaponType.swayAmountPosition + randomSwayY) * delta, weaponType.swaySpeedPosition)

		# Lerp weapon rotation
		rotation_degrees.y = lerp(rotation_degrees.y, weaponType.rotation.y - (mouseMovement.x * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)
		rotation_degrees.x = lerp(rotation_degrees.x, weaponType.rotation.x - (mouseMovement.y * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)
	
	#Movement bob (Not idle)
	else:
		if canSwayPosition and isSighting == false:
			position.x = lerp(position.x, weaponType.position.x + (mouseMovement.x * weaponType.swayAmountPosition + weaponBobAmount.x) * delta, weaponType.swaySpeedPosition)
			position.y = lerp(position.y, weaponType.position.y - (mouseMovement.y * weaponType.swayAmountPosition + weaponBobAmount.y) * delta, weaponType.swaySpeedPosition)
		# Lerp weapon rotation
		rotation_degrees.y = lerp(rotation_degrees.y, weaponType.rotation.y - (mouseMovement.x * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)
		rotation_degrees.x = lerp(rotation_degrees.x, weaponType.rotation.x + (mouseMovement.y * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)

func weaponBob(delta, bobSpeed: float, hbobAmount: float, vbobAmount) -> void:
	time += delta
	
	weaponBobAmount.x = sin(time * bobSpeed) * hbobAmount
	weaponBobAmount.y = abs(cos(time * bobSpeed) * vbobAmount)
	
func getSwayNoise() -> float: 
	var noiseLocation : float = rng.randf_range(0, 1.0)
	return noiseLocation

func shoot() -> void:
	if clipAmmo != 0 and canShoot == true and actionable == true:
		canShoot = false  # Prevent further shooting
		cooldown_timer = time_per_shot  # Reset the cooldown timer
		shootCooldown()
		
		if weaponBulletPhysics == "Hitscan":
			#Run Raycast function
			var camera = Global.player.CAMERA_CONTROLLER
			var spaceState = camera.get_world_3d().direct_space_state
			var screenCenter = get_viewport().size / 2
			var origin = camera.project_ray_origin(screenCenter)
			
			if shotgun:
				for i in 8:
					var accuracyAdjustment = Vector3 (
					rng.randf_range(-weaponAccuracy, weaponAccuracy),
					rng.randf_range(-weaponAccuracy, weaponAccuracy),
					rng.randf_range(-weaponAccuracy, weaponAccuracy)
					)
					

					var endpoint = origin + camera.project_ray_normal(screenCenter) * 1000 + accuracyAdjustment * 10
					var query = PhysicsRayQueryParameters3D.create(origin, endpoint, 4294967295 - 2)
					query.collide_with_bodies = true
					var result = spaceState.intersect_ray(query)
					
					var hitPosition = result.get("position")
					var hitNormal = result.get("normal")
					var hitBody = result.get("collider")  # Get the object that was hit
					if hitBody and hitBody.has_method("take_damage"):
						hitBody.take_damage(weaponType.Damage)  # Deal damage to the enemy
					
					#Apply decal
					#if result:
						#var instance = bulletHole.instantiate()
						#get_tree().root.add_child(instance)
						#instance.global_position = hitPosition
						#instance.look_at(instance.global_transform.origin + hitNormal, Vector3.UP)
						#instance.rotate_object_local(Vector3(1,0,0), 90)
						#removeHitMark(instance)
			else:
				var accuracyAdjustment = Vector3 (
					rng.randf_range(-weaponAccuracy, weaponAccuracy),
					rng.randf_range(-weaponAccuracy, weaponAccuracy),
					rng.randf_range(-weaponAccuracy, weaponAccuracy)
				)
					

				var endpoint = origin + camera.project_ray_normal(screenCenter) * 1000 + accuracyAdjustment * 10
				var query = PhysicsRayQueryParameters3D.create(origin, endpoint, 4294967295 - 2)
				query.collide_with_bodies = true
				var result = spaceState.intersect_ray(query)
					
				var hitPosition = result.get("position")
				var hitNormal = result.get("normal")
				var hitBody = result.get("collider")  # Get the object that was hit
				if hitBody and hitBody.has_method("take_damage"):
					hitBody.take_damage(weaponType.Damage)  # Deal damage to the enemy
					
				#Apply decal
				#if result:
					#var instance = bulletHole.instantiate()
					#get_tree().root.add_child(instance)
					#instance.global_position = hitPosition
					#instance.look_at(instance.global_transform.origin + hitNormal, Vector3.UP)
					#instance.rotate_object_local(Vector3(1,0,0), 90)
					#removeHitMark(instance)
		elif weaponBulletPhysics == "Projectile":
			var bulletInstance = weaponBulletScene.instantiate()
			var accuracyAdjustment = Vector3 (
				rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
				rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
				rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy)
			)
			bulletInstance.global_transform = bulletSpawnPoint.global_transform
			bulletInstance.rotation += accuracyAdjustment / 100
			bulletInstance.scale = Vector3(0.25, 0.25, 0.25)
			get_tree().get_root().add_child(bulletInstance)
		
		
		
		clipAmmo -= 1
		weaponAmmoInventory[currentWeaponIndex][0] = clipAmmo
		Global.updateLabels() 
		weaponAnimationPlayer.stop()
		weaponAnimationPlayer.seek(0)
		weaponAnimationPlayer.play(weaponName + "/" + "shoot", -1, 1, false)
		Global.player.cameraOffset += Vector3(verticalRecoil, horizontalRecoil, 0)

		if fireMode == "Bolt":
			await weaponAnimationPlayer.animation_finished
			weaponAnimationPlayer.play(weaponName + "/" + "boltCycle", -1, 1, false)
			await weaponAnimationPlayer.animation_finished
			



func reloadWeapon():
	if actionable == true:
		actionable = false
		canShoot = false
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

		Global.updateLabels()
		weaponAmmoInventory[currentWeaponIndex] = [clipAmmo, reserveAmmo]
		actionable = true
		canShoot = true


func shootCooldown():
	shootTimer.start(time_per_shot)
	await shootTimer.timeout
	canShoot = true
	if reserveAmmo > 0 and clipAmmo == 0:
		if weaponAnimationPlayer.is_playing():
			await weaponAnimationPlayer.animation_finished
			reloadWeapon()
			return
		else:
			reloadWeapon()
			return
	if fireMode == "Auto" and Input.is_action_pressed("shoot"):
			shoot()


func _process(delta: float) -> void:
		
	if !Engine.is_editor_hint():
		if Input.is_action_just_pressed("reload") and clipAmmo != maxClipAmmo:
			reloadWeapon()
			
		#GUN SIGHT CODE AND FUNCTIONS
		if Input.is_action_pressed("sightDown") and canSight and actionable:
			isSighting = true
			reticle.visible = false
			weaponAccuracy = weaponType.Accuracy / 4
			position = weaponType.position
			rotation_degrees = weaponType.rotation
			weaponRig.position = (lerp(weaponRig.position, sightPosition, sightSpeed))
		else:
			isSighting = false
			reticle.visible = true
			weaponAccuracy = weaponType.Accuracy
			weaponRig.position = (lerp(weaponRig.position, Vector3.ZERO, sightSpeed))

		if Global.player.sprinting == true:
			weaponRig.rotation_degrees = (lerp(weaponRig.rotation_degrees, Vector3(-10,40,0), 0.125))
		else:
			weaponRig.rotation = (lerp(weaponRig.rotation, Vector3.ZERO, 0.125))



#func removeHitMark(Instance):
	#await get_tree().create_timer(rng.randi_range(4, 12)).timeout
	#Instance.queue_free()

func knife():
	if canShoot == true and actionable == true:
		canShoot = false
		canSight = false
		actionable = false
		var camera = Global.player.CAMERA_CONTROLLER
		var spaceState = camera.get_world_3d().direct_space_state
		var screenCenter = get_viewport().size / 2
		var origin = camera.project_ray_origin(screenCenter)
		var endpoint = origin + camera.project_ray_normal(screenCenter) * 1.25
		var query = PhysicsRayQueryParameters3D.create(origin, endpoint, 4294967295 - 2)
		query.collide_with_bodies = true
		var result = spaceState.intersect_ray(query)
		
		var hitBody = result.get("collider")  # Get the object that was hit
		if hitBody and hitBody.has_method("take_damage"):
			weaponAnimationPlayer.play("Melee", -1, 1.5)
			
		else:
			endpoint = origin + camera.project_ray_normal(screenCenter) * 2
			query = PhysicsRayQueryParameters3D.create(origin, endpoint, 4294967295 - 2)
			result = spaceState.intersect_ray(query)
			hitBody = result.get("collider")
			if hitBody and hitBody.has_method("take_damage") and !Input.is_action_pressed("move_backward"):
				weaponAnimationPlayer.play("Melee Lunge", -1, 1.5)
				Global.player.meleeLunge()
			else:
				weaponAnimationPlayer.play("Melee", -1, 1.5)
		await weaponAnimationPlayer.animation_finished
		weaponAnimationPlayer.play(weaponName + "/" + "pullout")
		await weaponAnimationPlayer.animation_finished
		canShoot = true
		canSight = true
		actionable = true

func knifeDamage():
	var camera = Global.player.CAMERA_CONTROLLER
	var spaceState = camera.get_world_3d().direct_space_state
	var screenCenter = get_viewport().size / 2
	var origin = camera.project_ray_origin(screenCenter)
	var endpoint = origin + camera.project_ray_normal(screenCenter) * 1.25
	var query = PhysicsRayQueryParameters3D.create(origin, endpoint, 4294967295 - 2)
	query.collide_with_bodies = true
	var result = spaceState.intersect_ray(query)
		
	var hitBody = result.get("collider")  # Get the object that was hit
	if hitBody and hitBody.has_method("take_damage"):
		hitBody.take_damage(150)




#Applys shader to prevent weapon clipping
func apply_clip_and_fov_shader_to_view_model(node3d : Node3D, fov_or_negative_for_unchanged = -1.0):
	var all_mesh_instances = node3d.find_children("*", "MeshInstance3D")
	if node3d is MeshInstance3D:
		all_mesh_instances.push_back(node3d)
	for mesh_instance in all_mesh_instances:
		var mesh = mesh_instance.mesh
		# Important to turn shadow casting off for view model or will cause issues with both
		# view model, casting shadows on itself once unclipped, & also will look weird casting on world.
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if mesh != null:
			for surface_idx in mesh.get_surface_count():
				var base_mat = mesh.surface_get_material(surface_idx)
				if not base_mat is BaseMaterial3D: continue
				var weapon_shader_material := ShaderMaterial.new()
				weapon_shader_material.shader = load("res://shaders/weaponClip.gdshader")
				weapon_shader_material.set_shader_parameter("texture_albedo", base_mat.albedo_texture)
				weapon_shader_material.set_shader_parameter("texture_metallic", base_mat.metallic_texture)
				weapon_shader_material.set_shader_parameter("texture_roughness", base_mat.roughness_texture)
				weapon_shader_material.set_shader_parameter("texture_normal", base_mat.normal_texture)
				weapon_shader_material.set_shader_parameter("albedo", base_mat.albedo_color)
				weapon_shader_material.set_shader_parameter("metallic", base_mat.metallic)
				weapon_shader_material.set_shader_parameter("specular", base_mat.metallic_specular)
				weapon_shader_material.set_shader_parameter("roughness", base_mat.roughness)
				weapon_shader_material.set_shader_parameter("viewmodel_fov", fov_or_negative_for_unchanged)
				var tex_channels = { 0: Vector4(1., 0., 0., 0.), 1: Vector4(0., 1., 0., 0.), 2: Vector4(0., 0., 1., 0.), 3: Vector4(1., 0., 0., 1.), 4: Vector4() }
				weapon_shader_material.set_shader_parameter("metallic_texture_channel", tex_channels[base_mat.metallic_texture_channel])
				mesh_instance.set_surface_override_material(surface_idx, weapon_shader_material)

func givePerk(perk, bottleMesh, capMesh, cost):
	if actionable == true:
		Global.points -= cost
		Global.updateLabels()
		match perk:
			"juggernog":
				await playDrinkAnimation()
				Global.player.maxHealth = 250
			"speedCola":
				pass

func playDrinkAnimation():
	actionable = false
	weaponAnimationPlayer.play(weaponName + "/" + "pullout")
	await weaponAnimationPlayer.animation_finished
	weaponAnimationPlayer.play("Drink Perk")
	await weaponAnimationPlayer.animation_finished
	weaponAnimationPlayer.play(weaponName + "/" + "pullout")
	actionable = true
	return




	
#✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅
