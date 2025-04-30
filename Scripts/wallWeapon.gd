extends StaticBody3D

@export var weapon : Weapons
@export var objectName : String = "Wall Weapon"
@export var weaponCost = 1000
@export var ammoCost = 500
var cost = weaponCost

func update():
	if !Global.weaponManager.weaponInventory.has(str(weapon.resource_path)):
		cost = weaponCost

func purchase():
	if Global.points >= cost:
		Global.points -= cost
		Global.updatePoints() 
		cost = ammoCost
		Global.weaponManager.addWeapon(str(weapon.resource_path))
