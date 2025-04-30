extends StaticBody3D

@onready var animationPlayer = $AnimationPlayer
@export var objectName : String = "Door"
@export var cost = 1000
@export var spawnPoints: Array[ZombieSpawnPoint]

func update():
	pass

func purchase():
	if Global.points >= cost:
		Global.points -= cost
		Global.updatePoints() 
		animationPlayer.play("open", -1, 1)
		for spawnPoint in spawnPoints:
			spawnPoint.spawnEnabled = true
