extends CenterContainer

@export var reticleLines : Array[Line2D]
@export var playerController : CharacterBody3D
@export var reticleSpeed : float = 0.25 #Changes Transition speed between distances
@export var reticleDistance : float = 2.0 #Changes distance multiplier
@export var dotRadius : float = 1.0
@export var dotColor : Color = Color.WHITE

func _ready():
	queue_redraw()

func _process(delta):
	adjustReticleLines()


func _draw():
	draw_circle(Vector2(20,20),dotRadius,dotColor)


func adjustReticleLines():
	var vel = playerController.get_real_velocity()
	var origin = Vector3(0,0,0)
	var pos = Vector2(20,20)
	var speed = origin.distance_to(vel)
	#Top
	reticleLines[0].position = lerp(reticleLines[0].position, pos + Vector2(0, -speed * reticleDistance), reticleSpeed)
	
	#Right
	reticleLines[1].position = lerp(reticleLines[1].position, pos + Vector2(speed * reticleDistance, 0), reticleSpeed)
	
	#Bottom
	reticleLines[2].position = lerp(reticleLines[2].position, pos + Vector2(0, speed * reticleDistance), reticleSpeed)
	
	#Left
	reticleLines[3].position = lerp(reticleLines[3].position, pos + Vector2(-speed * reticleDistance, 0), reticleSpeed)
