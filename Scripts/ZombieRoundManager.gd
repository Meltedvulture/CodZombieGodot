extends Node

class_name ZombieRoundManager

#var roundLabel = Global.player.get_node("/root/RoundLabel")

@export var round = 1
@export var baseZombies = 4
@export var mysteryBoxPool = preload("res://Weapons/weaponPools/DefaultWeaponPool.tres")
@export var boxLocations : Array[mysteryBoxLocation]
var zombiesToSpawn = 6
var currentZombies = 0
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	Global.zombieDied.connect(zombieDied)
	Global.zombieRoundManager = self

func _process(delta):
	pass

func zombieDied():
	currentZombies -= 1
	if zombiesToSpawn == 0 and currentZombies == 0:
		Global.player.flashLabel()
		#INSERET SOUND EFFECT HERER
		await get_tree().create_timer(10).timeout
		newRound()

func newRound():
	Global.emit_signal("roundChange")
	round += 1
	Global.updateRound()
	zombiesToSpawn = baseZombies + int(2 * pow(round, 1.5))

func changeBoxLocation(currentBoxLocation):
	var boxDestination = rng.randi_range(0, boxLocations.size() - 1)
	
	while boxLocations[boxDestination] == currentBoxLocation:
		boxDestination = rng.randi_range(0, boxLocations.size() - 1)
		
	boxLocations[boxDestination].hasBox = true
	boxLocations[boxDestination].startBox()
	
