extends Node

signal zombieDied
signal roundChange

var debug
var player
var weaponManager
var points = 500
var reserveLabel : Label
var clipLabel : Label
var pointsLabel : Label

#func _ready():
	#await get_tree().create_timer(0).timeout
	#print("added weapon")
	#weaponManager.addWeapon(load("res://Weapons/Crowbar.tres"))


func updateLabels(clipAmmo, reserveAmmo):
	clipLabel.text = str(clipAmmo)
	reserveLabel.text = str(reserveAmmo)
	pointsLabel.text = str(points)

func updatePoints():
	pointsLabel.text = str(points)


#Debug property Line:
#Global.debug.addProperty("Name Of Property",Value, Order)
