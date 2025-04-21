class_name StateMachine

extends Node

@export var currentState : State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(onChildTransition)
		else:
			push_warning("State machine contains incompatible child node")
	await owner.ready
	currentState.enter(null)

func _process(delta):
	currentState.update(delta)
	Global.debug.addProperty("Current State",currentState, 3)
	
func _physics_process(delta):
	currentState.physics_update(delta)
	
func onChildTransition(new_state_name: StringName):
	var newState = states.get(new_state_name)
	if newState != null:
		if newState != currentState:
			currentState.exit()
			newState.enter(currentState)
			currentState = newState
	else:
		push_warning("State does not exist HELP!!")
