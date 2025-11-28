extends StaticBody3D

class_name mysteryBoxLocation

@onready var animationPlayer = $AnimationPlayer
@onready var mysteryBox = $"Mystery Box"
@onready var interactCollision = $"Interact Collision"

@onready var weaponMesh = %WeaponMesh
@onready var weaponMagazine = %WeaponMagazine
@onready var weaponBolt = %WeaponBolt
@onready var weaponNode = $"Mystery Box/Weapon"
@onready var changeDelayTimer = $"Change Delay"

@export var objectName : String = "Mystery Box"
@export var hasBox = false
@export var cost = 950

var defaultText = "Hold F to roll the " + objectName + " Cost: " + str(cost)
var pickedWeaponText = "You should not be seeing this text, THIS IS AN ERROR WAAAHH"

var opened = false
var tookWeapon = false
var choseWeapon = false
var mysteryBoxPool = null
var rng = RandomNumberGenerator.new()
var loadedWeapon
var timesrolled = 0

func _ready() -> void:
	startBox()

func hoverText():
	if choseWeapon:
		return pickedWeaponText
	else:
		return "Hold F to roll the " + objectName + " Cost: " + str(cost)

func update():
	pass


func purchase():
	if Global.points >= cost and opened == false:
		Global.points -= cost
		Global.updatePoints()
		opened = true
		timesrolled += 1
		animationPlayer.play("Open", -1, 1)
		await animationPlayer.animation_finished
		if opened == true:
			animationPlayer.play("Close", -1, 1)
			choseWeapon = false
			opened = false
	elif choseWeapon:
		Global.weaponManager.addWeapon(str(loadedWeapon.resource_path))
		animationPlayer.stop()
		animationPlayer.play("Close", -1, 1)
		choseWeapon = false
		opened = false
		interactCollision.disabled = false

func finishedRolling():
	pickedWeaponText = "Hold F to take " + str(loadedWeapon.name)
	choseWeapon = true
	
	if rng.randi_range(timesrolled, 20) == 20 and Global.zombieRoundManager.boxLocations.size() > 1:
		timesrolled = 0
		choseWeapon = false
		loadedWeapon = null
		interactCollision.disabled = true
		animationPlayer.play("Change Position", -1, 1)
		await animationPlayer.animation_finished
		hasBox = false
		changeDelayTimer.start(8)
		await changeDelayTimer.timeout
		Global.zombieRoundManager.changeBoxLocation(self)
		

func randomizeWeapon():
	loadedWeapon = mysteryBoxPool[rng.randi_range(0, mysteryBoxPool.size() - 1)]
	weaponMesh.mesh = loadedWeapon.mesh
	weaponMagazine.mesh = loadedWeapon.magazine
	weaponBolt.mesh = loadedWeapon.bolt
	weaponNode.rotation_degrees = loadedWeapon.rotation
	weaponNode.rotation_degrees.y += 90
	

func startBox():
	mysteryBoxPool = Global.zombieRoundManager.mysteryBoxPool.weaponPool
	interactCollision.disabled = true
	choseWeapon = false
	opened = false
	mysteryBox.visible = hasBox
	if hasBox == true:
		animationPlayer.play("Arrive Position", -1, 1)
		await animationPlayer.animation_finished
		interactCollision.disabled = false
