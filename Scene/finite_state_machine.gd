class_name FiniteStateMachine
extends Node

@export var state:State#state is a custom object
@onready var initial_state = $grid_interact
@onready var states:Dictionary = {'grid_interact' : $grid_interact,
								'character_interaction': $character_interaction,
								'movement_selection': $movement_selection,
								'fight_selection' : $fight_selection}
# Called when the node enters the scene tree for the first time.
func _ready():
	change_state(initial_state)

func change_state(new_state:State):
	
	if state is State:
		state._exit_state()
	new_state._enter_state()
	state=new_state
	Global.current_state=new_state


func _on_map_change_state(state_name):
	change_state(states[state_name])
