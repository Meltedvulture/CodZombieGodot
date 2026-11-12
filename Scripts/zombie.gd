extends CharacterBody3D


@onready var navAgent = $NavigationAgent3D
@onready var damageTimer = $DamageTimer
# Exported variables
@export var max_health: int = 100
@export var move_speed: float = 1.0
@export var gravity: float = 9.8  # Gravity strength (adjust as needed)
var target: Node3D  # Reference to the player
var barrier : Node3D
var canMove = true
var attacking = false

# Internal variables
var current_health: int
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	current_health = max_health + (ZombieRoundManager.round * 50)
	move_speed = clamp(rng.randf_range(0.5, 0.5 + (ZombieRoundManager.round * 0.5)), 0.5, 4)
	rng.randomize()

# Called every frame.
func _physics_process(delta):
	if not is_on_floor():  # Apply gravity if not on the floor
		velocity.y -= gravity * delta
	
	if target:
		navAgent.set_target_position(target.global_position)
	
	var nextLocation = navAgent.get_next_path_position()
	velocity = (nextLocation-global_position).normalized() * move_speed
	look_at(navAgent.get_next_path_position())
	rotation.x = 0
	rotation.z = 0
	
	# Use move_and_slide to handle movement and gravity
	if canMove == true:
		move_and_slide()

func _process(delta: float) -> void:
	pass

# Function to handle taking damage
func take_damage(amount: int):
	current_health -= amount
	Global.points += 10
	Global.updatePoints()
	# Check if the enemy is dead
	if current_health <= 0:
		Global.points += 130
		Global.updatePoints()
		Global.emit_signal("zombieDied")
		queue_free()  # Remove the enemy from the scene when dead

func _on_area_3d_body_entered(body):
	if body == barrier:
		damageBarrier()
	

func damageBarrier():
	await get_tree().create_timer(3).timeout
	if barrier.isDead == false:
		barrier.takeDamage()
		damageBarrier()
	else:
		target = Global.player


func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if body == Global.player:
		attacking = true
		attack(body)
		
func attack(body):
		canMove = false
		damageTimer.start(rng.randf_range(0.3, 1))
		await damageTimer.timeout
		if Global.player.playerDead == true:
			return
		if body and body.has_method("takePlayerDamage"):
			body.takePlayerDamage(60)
		damageTimer.start(rng.randf_range(0.75, 2))
		await damageTimer.timeout
		if attacking == true and Global.player.playerDead == false:
			attack(body)
		else:
			canMove = true


func _on_area_3d_2_body_exited(body: Node3D) -> void:
	if body == Global.player:
		attacking = false
