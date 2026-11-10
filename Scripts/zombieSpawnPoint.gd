extends Node3D

class_name ZombieSpawnPoint

@export var barrier: Barrier
@export var spawnEnabled : bool = false

var zombie = preload("res://Scenes/Zombie.tscn")
var timer: float = 0
var rng = RandomNumberGenerator.new()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer >= max(rng.randf_range(3 * 0.95 ** (ZombieRoundManager.round - 1), 4), 0.1):
		timer = 0
		spawnZombie()

func spawnZombie():
	if ZombieRoundManager.zombiesToSpawn > 0 and spawnEnabled == true:
		ZombieRoundManager.zombiesToSpawn -= 1
		ZombieRoundManager.currentZombies += 1
		var zombieInstance = zombie.instantiate()
		add_child(zombieInstance)
		zombieInstance.barrier = barrier
		zombieInstance.target = barrier
		zombieInstance.global_transform.origin = global_position
