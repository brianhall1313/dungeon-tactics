class_name FiniteStateMachine
extends Node

@export var state:State#state is a custom object
@onready var initial_state = $grid_interact
@onready var states:Dictionary = {'grid_interact' : $grid_interact,
								'character_interaction': $character_interaction,
								'movement_selection': $movement_selection,
								'fight_selection' : $fight_selection,
								'ai_turn':$ai_turn,
								'sa_resolution':$sa_resolution,
								'pause_menu':$pause_menu,
								'game_over':$game_over,
								'animation_state':$animation_state,
								}
func _ready():
	connect_bus()
	
func connect_bus():
	GlobalSignalBus.connect('change_state',_on_change_state)

func change_state(new_state:State):
	if state != $game_over:
		if state is State:
			if new_state == $animation_state:
				new_state.previous_state = state
			state._exit_state()
		new_state._enter_state()
		state=new_state
		Global.current_state=new_state


func _on_change_state(state_name):
	change_state(states[state_name])
