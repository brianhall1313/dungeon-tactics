extends Node

var current_state:State
var dead_position:Vector2
var debug = true


func _ready():
	randomize()

func set_death_position(new_position:Vector2):
	dead_position=new_position
