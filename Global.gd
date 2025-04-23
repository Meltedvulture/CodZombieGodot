extends Node

signal zombieDied
signal roundChange

var debug
var player
var points = 500
var reserveLabel : Label
var clipLabel : Label
var pointsLabel : Label

func updateLabels(clipAmmo, reserveAmmo):
	clipLabel.text = str(clipAmmo)
	reserveLabel.text = str(reserveAmmo)
	pointsLabel.text = str(points)

func updatePoints():
	pointsLabel.text = str(points)


#Debug property Line:
#Global.debug.addProperty("Name Of Property",Value, Order)
