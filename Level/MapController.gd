extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ZombieRoundManager.boxLocations = $"Box Locations".get_children()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
