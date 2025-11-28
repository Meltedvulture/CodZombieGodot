extends Node

signal zombieDied
signal roundChange

var debug
var player
var weaponManager
var points = 5000
var reserveLabel : Label
var clipLabel : Label
var pointsLabel : Label
var roundLabel
var zombieRoundManager

func _ready():
	call_deferred("updatePoints")


func updateLabels(clipAmmo, reserveAmmo):
	clipLabel.text = str(clipAmmo)
	reserveLabel.text = str(reserveAmmo)
	pointsLabel.text = str(points)

func updatePoints():
	pointsLabel.text = str(points)

func updateRound():
	roundLabel.text = str(Global.zombieRoundManager.round)


#Debug property Line:
#Global.debug.addProperty("Name Of Property",Value, Order)
