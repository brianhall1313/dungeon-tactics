extends Node

var height:int=10
var width:int=10
var current_state:State
var board_state
var current_character
var dead_position:Vector2i
var dead_position_raw:Vector2

func _ready():
	randomize()

func set_death_position(new_position:Vector2i,raw_position:Vector2):
	dead_position=new_position
	dead_position_raw=raw_position
