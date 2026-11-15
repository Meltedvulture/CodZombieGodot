extends StaticBody3D

class_name mysteryBoxLocation

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var mysteryBox : Node3D = $"Mystery Box"
@onready var interactCollision : CollisionShape3D = $"Interact Collision"
@onready var weaponMesh : MeshInstance3D = %WeaponMesh
@onready var weaponMagazine : MeshInstance3D = %WeaponMagazine
@onready var weaponBolt : MeshInstance3D = %WeaponBolt
@onready var weaponNode : Node3D = $"Mystery Box/Weapon"
@onready var changeDelayTimer : Timer = $"Change Delay"

@export var objectName : String = "Mystery Box"
@export var hasBox : bool = false
@export var cost : int = 950

var defaultText : String = "Hold F to roll the " + objectName + " Cost: " + str(cost)
var pickedWeaponText : String = "You should not be seeing this text, THIS IS AN ERROR WAAAHH"

var opened : bool = false
var tookWeapon : bool = false
var choseWeapon : bool = false
var mysteryBoxPool = null
var rng = RandomNumberGenerator.new()
var loadedWeapon
var timesrolled : int = 0

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
		Global.updateLabels()
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
	
	if rng.randi_range(timesrolled, 20) == 20 and ZombieRoundManager.boxLocations.size() > 1:
		timesrolled = 0
		choseWeapon = false
		loadedWeapon = null
		interactCollision.disabled = true
		animationPlayer.play("Change Position", -1, 1)
		await animationPlayer.animation_finished
		hasBox = false
		changeDelayTimer.start(8)
		await changeDelayTimer.timeout
		ZombieRoundManager.changeBoxLocation(self)
		

func randomizeWeapon():
	loadedWeapon = mysteryBoxPool[rng.randi_range(0, mysteryBoxPool.size() - 1)]
	weaponMesh.mesh = loadedWeapon.mesh
	weaponMagazine.mesh = loadedWeapon.magazine
	weaponBolt.mesh = loadedWeapon.bolt
	weaponNode.rotation_degrees = loadedWeapon.rotation
	weaponNode.rotation_degrees.y += 90
	

func startBox():
	mysteryBoxPool = ZombieRoundManager.mysteryBoxPool.weaponPool
	interactCollision.disabled = true
	choseWeapon = false
	opened = false
	mysteryBox.visible = hasBox
	if hasBox == true:
		animationPlayer.play("Arrive Position", -1, 1)
		await animationPlayer.animation_finished
		interactCollision.disabled = false
