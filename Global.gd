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


func updateLabels():
	clipLabel.text = str(Global.weaponManager.clipAmmo)
	reserveLabel.text = str(Global.weaponManager.reserveAmmo)
	pointsLabel.text = str(points)

func updatePoints():
	pointsLabel.text = str(points)

func updateRound():
	roundLabel.text = str(Global.zombieRoundManager.round)




#Debug property Line:
#Global.debug.addProperty("Name Of Property",Value, Order)


#Parity Features List
#Powerup Drops
#Perks





#Quick Revive: on a fatal hit, instead of death we give the user invicibility
#and speed, zombies will run away from the user temperorily


#Juggernog: Sets health to 250, gives increased regen speed
#Focuses on Health and survivability, not much to add


#Speed Cola: speeds up all player animations
#Not much to add tbh


#Double Tap: Doubles damage, 50% chance to not consume ammo 
#or every second shot consumes no ammo?
#Perk Focuses on long term ammo for higher rounds

#Staminup: Increases overall speed, increases stamina and regen
#Increases sliding speed

#Life Steal Perk?
#each kill heals the player for a little health
