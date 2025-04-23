extends StaticBody3D

var objectType = "Door"
@onready var animationPlayer = $AnimationPlayer
@export var objectName : String = "Door"
@export var cost = 1000


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func purchase():
	if Global.points > cost:
		Global.points -= cost
		Global.updatePoints() 
		animationPlayer.play("open", -1, 1)
