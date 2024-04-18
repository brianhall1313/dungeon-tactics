extends Node

var current_state:State
var dead_position:Vector2
var debug:bool = true
var character=preload("res://Scene/Character.tscn")
var cell_size:int = 16
var current_level:int = 0
@onready var free_spaces:Array=[4]
@onready var water_spaces:Array=[]
@onready var flight_spaces:Array=[5]
@onready var wall_spaces:Array=[9,10,11]
@onready var effects:Dictionary={"fireball":preload("res://Animations/fireball.tscn"),
						"elemental_explosion":preload("res://Animations/elemental_explosion.tscn"),
						"heal":preload("res://Animations/heal.tscn"),
						"summon_circle":preload("res://Animations/summon_circle.tscn")
}

func _ready():
	randomize()

func set_death_position(new_position:Vector2):
	dead_position=new_position
