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
var roundLabel
var playerStateMachine
var currentStateName : String
var referenceFPS = 60
var inputAllowed = true

func _ready():
	call_deferred("updatePoints")

func fiLerp(weight: float, delta: float) -> float:
	if delta <= 0.0:
		return 0.0
	var w: float = clamp(weight, 0.0, 1.0)
	if w >= 1.0:
		w = 1.0
	
	return 1.0 - pow(1.0 - w, delta * referenceFPS)

func updateLabels():
	clipLabel.text = str(Global.weaponManager.clipAmmo)
	reserveLabel.text = str(Global.weaponManager.reserveAmmo)
	pointsLabel.text = str(points)

func updatePoints():
	pointsLabel.text = str(points)

func updateRound():
	roundLabel.text = str(ZombieRoundManager.round)




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
