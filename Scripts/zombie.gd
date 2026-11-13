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
	move_speed = clamp(rng.randf_range(0.5, 0.5 + (ZombieRoundManager.round * 0.5)), 0.5, 2)
	rng.randomize()

# Called every frame.
var path_update_timer := 0.0
var path_update_interval := 0.2 # Update path 5 times a second instead of 60

func _physics_process(delta):
	# 1. Apply gravity properly
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if not target or not canMove:
		move_and_slide()
		return

	# 2. Throttle target updates to prevent jitter and save performance
	path_update_timer -= delta
	if path_update_timer <= 0.0:
		navAgent.target_position = target.global_position
		path_update_timer = path_update_interval

	# 3. Stop moving if we've reached the player
	if navAgent.is_navigation_finished():
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	# 4. Calculate horizontal direction ONLY (ignore Y axis)
	var next_location = navAgent.get_next_path_position()
	var direction = next_location - global_position
	direction.y = 0.0 
	
	if direction.length() > 0.01:
		direction = direction.normalized()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		
		# Safely rotate towards movement direction
		var target_angle = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 10.0 * delta)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

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
