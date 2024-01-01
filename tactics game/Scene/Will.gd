class_name Will
extends Node2D

@export var base_will_D:int
@export var modified_will_D:int
@export var max_will:int
@export var modified_max_will:int
@export var current_will:int
@onready var parent=$".."
@onready var will:Array


func setup():
	will=parent.stats['will']
	base_will_D=will[0]
	modified_will_D=base_will_D#in the future this should be modified by equipment
	max_will=will[1]
	modified_max_will=max_will#in the future this should be modified by equipment
	current_will=modified_max_will
