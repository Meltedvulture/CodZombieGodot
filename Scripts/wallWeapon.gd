extends StaticBody3D

@export var weapon : Weapons
@export var objectName : String = "Wall Weapon"
@export var weaponCost = 1000
@export var ammoCost = 500
var cost = weaponCost

func purchase():
	if Global.points >= weaponCost:
		Global.points -= weaponCost
		Global.updatePoints() 
		cost = ammoCost
		Global.weaponManager.addWeapon(str(weapon.resource_path))
