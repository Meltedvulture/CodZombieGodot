extends Node3D

class_name Barrier

@onready var planks = [$Plank1, $Plank2, $Plank3, $Plank4, %Plank5]
@export var health : int = 5
@onready var animationPlayer = %PlankAnimations
@onready var collision = $StaticBody3D/Collision
var maxHealth = 5
var isDead = false


func repairBarrier():
	if health != 5:
		health += 1
		animationPlayer.play("Plank" + str(maxHealth - health) + "_Repair", -1, -1, true)
		collision.disabled = true
		isDead = false
		

func takeDamage():
	if health > 0:
		print("TakenDamage BARIERRER")
		animationPlayer.play("Plank" + str(health) + "_Falloff")
		health -= 1
	elif health == 0:
		isDead = true 
		collision.disabled = true
