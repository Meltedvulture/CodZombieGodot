class_name Weapons

extends Resource

@export var name : StringName
@export_category("Shooting and Ammo")
@export var Damage = 20
@export var clip = 8
@export var reserve = 32
@export var maxReserve = 80
@export var rpm = 450
##Accuracy of 1 means perfect accuracy, higher is more inaccurate
@export var Accuracy = 1
@export var melee : bool = false


@export_category("Bolt Action Specifics")
##Toggles whether the weapon will be bolt action/pumped
@export var boltAction : bool = false



@export_category("Weapon Orientation")
@export var position : Vector3
@export var rotation : Vector3
@export var scale : Vector3 = Vector3(1,1,1)
@export_category("Weapon Sway")
@export var sway_min : Vector2 = Vector2(-20.0,-20.0)
@export var sway_max : Vector2 = Vector2(20.0,20.0)
@export_range(0,0.2,0.01) var swaySpeedPosition : float = 0.07
@export_range(0,0.2,0.01) var swaySpeedRotation : float = 0.1
@export_range(0,0.25,0.01) var swayAmountPosition : float = 0.1
@export_range(0,50,0.1) var swayAmountRotation : float = 30
@export_category("Idle Sway")
@export var idleSwayAdjustment : float = 1.0
@export var idleSwayRotationStrength : float = 300.0
@export_range(0.1,10.0,0.1) var randomSwayAmount : float = 5.0
@export_category("Visual Settings")
@export var mesh : Mesh
@export var shadow : bool
