extends RayCast3D


var collidedObject
@onready var purchaseLabel = %InteractionLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	collidedObject = get_collider()
	if collidedObject:
		if collidedObject.is_in_group("BuyableObject"):
			purchaseLabel.text = "Hold F to buy " + collidedObject.objectName + " Cost: " + str(collidedObject.cost)
			if Input.is_action_just_pressed("interact"):
				collidedObject.purchase()
	else:
		purchaseLabel.text = ""
