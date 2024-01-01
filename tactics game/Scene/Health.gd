extends Node2D
class_name Health
@export var base_health_D:int
@export var modified_health_D:int
@export var max_health:int
@export var modified_max_health:int
@export var current_health:int
@onready var parent=$".."
@onready var toughness:Array
@export var alive:bool
signal damage_received
signal lethal_hit


func setup():
	toughness=parent.stats['toughness']
	base_health_D=toughness[0]
	modified_health_D=base_health_D#in the future this should be modified by equipment
	max_health=toughness[1]
	modified_max_health=max_health#in the future this should be modified by equipment
	current_health=modified_max_health
	alive=true
	
func attack_resolution(list:Array):
	for attack in list:
		if alive:
			damage_taken(attack)


func damage_taken(damage:int):#This should be called for each individual die rolled when damages calculated 
	if parent.armor and parent.armor['current_armor']>0:
		damage_to_armor(damage)
	else:
		damage_to_health(damage)

func damage_to_armor(damage:int):
	var armor_resist:int=randi_range(1,parent.armor['armor'][0])
	# we need to add handling for armour piercing when we add that
	if armor_resist>=damage:
		print("succeeded with the defense of "+str(armor_resist))
	else:
		print("failed to defend with "+str(armor_resist))
		parent.armor['current_armor']-=1
		if parent.armor['current_armor']==0:
			print('oh no my armour is destroyed')

func damage_to_health(damage:int):
	var health_resist:int=randi_range(1,modified_health_D)
	if damage>health_resist:
		print("failed to defend with "+str(health_resist))
		current_health-=1
		if current_health <= 0:
			print('oh god I died')
			alive=false
			lethal_hit.emit()
	else:
		print("succeeded with the defense of "+str(health_resist))


func healed(heal:int):
	current_health=min(current_health+heal,modified_health_D)
