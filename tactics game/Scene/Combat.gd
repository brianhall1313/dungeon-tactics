extends Node2D
class_name Combat
@export var base_combat_D:int
@export var modified_combat_D:int
@export var max_combat:int
@export var modified_max_combat:int
@export var current_combat:int
@export var equipment_die:Array=[]
@export var potential_targets:Array=[]

@onready var parent=$".."
@onready var strength:Array

signal damage_received
signal lethal_hit

func setup():
	strength=parent.stats['strength']
	base_combat_D=strength[0]
	modified_combat_D=base_combat_D#in the future this should be modified by equipment
	max_combat=strength[1]
	modified_max_combat=max_combat#in the future this should be modified by equipment
	current_combat=modified_max_combat
	equipment_die=parent.weapon['die']


func set_potential_targets(list:Array):
	potential_targets=[]
	potential_targets+=list


func clear_potential_targets():
	potential_targets=[]


func attack():
	var attack_rolls=[]
	for x in range(modified_max_combat):
		attack_rolls.append(randi_range(1,modified_combat_D))
	for x in range(equipment_die[1]):
		attack_rolls.append(randi_range(1,equipment_die[0]))
	clear_potential_targets()#I needed to do this somewhere and apparently that's here
	return attack_rolls
		
