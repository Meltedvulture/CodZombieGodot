extends Node

#var roundLabel = Global.player.get_node("/root/RoundLabel")

var round = 1
var baseZombies = 4
var mysteryBoxPool = preload("res://Weapons/weaponPools/DefaultWeaponPool.tres")
var boxLocations = []

var zombiesToSpawn = 6
var currentZombies = 0
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	Global.zombieDied.connect(zombieDied)

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
	
