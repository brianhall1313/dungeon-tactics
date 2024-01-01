extends Node2D
class_name Reflexes
@export var base_reflexes_D:int
@export var modified_reflexes_D:int
@export var max_reflexes:int
@export var modified_max_reflexes:int
@export var current_reflexes:int
@onready var parent=$".."
@onready var reflexes:Array


func setup():
	reflexes=parent.stats['reflexes']
	base_reflexes_D=reflexes[0]
	modified_reflexes_D=base_reflexes_D#in the future this should be modified by equipment
	max_reflexes=reflexes[1]
	modified_max_reflexes=max_reflexes#in the future this should be modified by equipment
	current_reflexes=modified_max_reflexes
