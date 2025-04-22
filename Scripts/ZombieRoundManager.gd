extends Node

class_name ZombieRoundManager

#var roundLabel = Global.player.get_node("/root/RoundLabel")

@export var round = 1
@export var baseZombies = 4
var zombiesToSpawn = 6
var currentZombies = 0

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
	zombiesToSpawn = baseZombies + int(2 * pow(round, 1.5))
