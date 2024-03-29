extends Node

var current_state:State
var dead_position:Vector2
var debug:bool = true
var Character=preload("res://Scene/Character.tscn")
var cell_size:int = 16
var current_level:int = 0
@onready var free_spaces:Array=[4]
@onready var water_spaces:Array=[]
@onready var flight_spaces:Array=[]
@onready var wall_spaces:Array=[5,9,10,11]

func _ready():
	randomize()

func set_death_position(new_position:Vector2):
	dead_position=new_position
