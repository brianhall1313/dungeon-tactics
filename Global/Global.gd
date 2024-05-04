extends Node

var current_state:State
var dead_position:Vector2
var debug:bool = true
var character=preload("res://Scene/Character.tscn")
var cell_size:int = 16
var current_level:int = 0
@onready var free_spaces:Array[int] =[4,7,8,12,13,14,15,16]
@onready var water_spaces:Array[int] =[]
@onready var flight_spaces:Array[int] =[5]
@onready var wall_spaces:Array[int] =[18,19,20]
@onready var cap_stone: int = 17
@onready var torch = preload("res://Animations/torch.tscn")
@onready var decorations:Array[int] = [22,24]

func _ready():
	randomize()

func set_death_position(new_position:Vector2):
	dead_position=new_position
