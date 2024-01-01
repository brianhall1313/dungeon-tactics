class_name Move
extends Node
var previous_position:Vector2i
var grid_position:Vector2i
@onready var parent=$".."
@export var base_move: int=5
@export var modified_move: int=5#hard coding this for now
@export var movement_traits: Array=[]#for when I want to add flight and teleportation
@export var movement_path: Array=[]
@export var possible_movement: Array=[]

@export var starting_position: Vector2i=Vector2i(0,0)


func _exit_state():
	possible_movement=[]
	movement_path=[]
	


func move(new_position,raw_position):
	previous_position=grid_position
	grid_position=new_position
	parent.position=raw_position


func set_possible_movement(list):
	possible_movement=list
