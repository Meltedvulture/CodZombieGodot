extends Node3D

class_name Barrier

@onready var planks = [$Plank1, $Plank2, $Plank3, $Plank4, %Plank5]
@export var health : int = 5
@onready var animationPlayer = %PlankAnimations
@onready var collision = $StaticBody3D/ZombieCollision
var maxHealth = 5
var isDead = false
var touchingPlayer = false

func repairBarrier():
	if health != 5:
		health += 1
		animationPlayer.play("Plank" + str(health) + "_Repair", -1, 1.5)
		collision.disabled = false
		isDead = false
		

func takeDamage():
	if health > 0:
		animationPlayer.play("Plank" + str(health) + "_Falloff")
		health -= 1
	elif health == 0:
		isDead = true 
		collision.disabled = true


func _on_player_area_body_entered(body):
	if body == Global.player:
		touchingPlayer = true

func _on_player_area_body_exited(body):
	if body == Global.player:
		touchingPlayer = false

func _input(event):
	if event.is_action_pressed("interact"):
		repairTimer()

func repairTimer():
	await get_tree().create_timer(1.5).timeout
	if Input.is_action_pressed("interact") and touchingPlayer == true:
		repairBarrier()
		repairTimer()
	else:
		pass
