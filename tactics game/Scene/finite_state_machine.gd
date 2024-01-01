class_name FiniteStateMachine
extends Node

@export var state:State#state is a custom object
@onready var initial_state = $GridInteract


# Called when the node enters the scene tree for the first time.
func _ready():
	change_state(initial_state)
	connect_input()


func change_state(new_state:State):
	
	if state is State:
		state._exit_state()
	new_state._enter_state()
	state=new_state
	Global.current_state=new_state


func connect_input():
	GlobalSignalBus.connect('interact',interaction)
	GlobalSignalBus.connect('moved',move)
	GlobalSignalBus.connect('cancel',cancel)


func interaction():
	state.interact()
	
	
func move(direction):
	state.movement(direction)

func cancel():
	state.cancle()
