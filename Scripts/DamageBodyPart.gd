extends Node

#This is a help script
#Goes on body parts and sends damage to parent
@export var bodyPart : String = "Body"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func takeDamage(amount: int):
	owner.emit_signal("zombieDamage", amount, bodyPart)

func takeKnifeDamage(amount : int):
	owner.emit_signal("zombieDamage", amount, "Body")
