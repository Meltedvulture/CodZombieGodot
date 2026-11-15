extends StaticBody3D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@export var objectName : String = "Door"
@export var cost : int = 1000
@export var spawnPoints: Array[ZombieSpawnPoint]

func update():
	pass

func hoverText():
	return "Hold F to buy " + objectName + " Cost: " + str(cost)

func purchase():
	if Global.points >= cost:
		Global.points -= cost
		Global.updateLabels()
		animationPlayer.play("open", -1, 1)
		for spawnPoint in spawnPoints:
			spawnPoint.spawnEnabled = true
