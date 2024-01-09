extends Node


var turn_counter:int
var turn:String
@export var victory:Array=[]
@onready var map=$Map

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_input()
	



func connect_input():
	GlobalSignalBus.connect('interact',interaction)
	GlobalSignalBus.connect('moved',move)
	GlobalSignalBus.connect('cancel',cancel)


func interaction():
	Global.current_state.interact()
	print("we've gotten to the encounter manager")
	
	
func move(direction):
	Global.current_state.movement(direction)

func cancel():
	Global.current_state.cancle()
