extends StaticBody3D

var cost = 2500
var bottleMesh = preload("res://Models/Blender/Perks/Juggernog/Juggernog Bottle.res")
var capMesh = preload("res://Models/Blender/Perks/Juggernog/Juggernog Cap.res")


func update():
	pass

func hoverText():
	return "Hold F to buy Juggernog Cost: " + str(cost)

func purchase():
	if Global.points >= cost:
		Global.weaponManager.givePerk("juggernog", bottleMesh, capMesh, cost)
