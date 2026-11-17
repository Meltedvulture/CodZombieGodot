extends Node

#var roundLabel = Global.player.get_node("/root/RoundLabel")

var round : int = 30
var baseZombies : int = 4
var mysteryBoxPool = preload("res://Weapons/weaponPools/DefaultWeaponPool.tres")
var boxLocations = []

var zombiesToSpawn : int = 6
var currentZombies : int = 0
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	zombiesToSpawn = baseZombies + int(2 * pow(round, 1.5))
	Global.zombieDied.connect(zombieDied)

func _process(delta):
	pass

func zombieDied():
	currentZombies -= 1
	if zombiesToSpawn == 0 and currentZombies == 0:
		Global.player.flashLabel()
		Global.player.playPlayerSFX(preload("res://Audio/mus_zombie_round_over.SN65.pc.snd.wav"), -9.0)
		await get_tree().create_timer(12).timeout
		Global.player.playPlayerSFX(preload("res://Audio/mus_zombie_round_start.SN65.pc.snd.wav"), -9.0)
		newRound()

func newRound():
	Global.emit_signal("roundChange")
	round += 1
	Global.updateLabels()
	zombiesToSpawn = baseZombies + int(2 * pow(round, 1.5))

func changeBoxLocation(currentBoxLocation):
	var boxDestination = rng.randi_range(0, boxLocations.size() - 1)
	
	while boxLocations[boxDestination] == currentBoxLocation:
		boxDestination = rng.randi_range(0, boxLocations.size() - 1)
		
	boxLocations[boxDestination].hasBox = true
	boxLocations[boxDestination].startBox()
	
