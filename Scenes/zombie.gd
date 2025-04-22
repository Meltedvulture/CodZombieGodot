extends CharacterBody3D

# Exported variables
@export var max_health: int = 150
@export var move_speed: float = 2.0
@export var gravity: float = 9.8  # Gravity strength (adjust as needed)
var target: Node3D  # Reference to the player
var barrier : Node3D

# Internal variables
var current_health: int
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	current_health = max_health
	

# Called every frame.
func _physics_process(delta):
	if not is_on_floor():  # Apply gravity if not on the floor
		velocity.y -= gravity * delta

	if target:
		# Move towards the player
		var direction = (target.global_transform.origin - global_transform.origin).normalized()
		direction.y = 0  # Ignore vertical movement to avoid climbing slopes unnaturally
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		 

	# Use move_and_slide to handle movement and gravity
	move_and_slide()

# Function to handle taking damage
func take_damage(amount: int):
	current_health -= amount
	Global.points += 10
	# Check if the enemy is dead
	if current_health <= 0:
		Global.points += 130
		Global.emit_signal("zombieDied")
		queue_free()  # Remove the enemy from the scene when dead

func _on_area_3d_body_entered(body):
	if body == barrier:
		print("touched barrier i THInk")
		damageBarrier()
	

func damageBarrier():
	await get_tree().create_timer(2).timeout
	if barrier.isDead == false:
		barrier.takeDamage()
		damageBarrier()
	else:
		target = Global.player
