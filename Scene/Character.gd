extends AnimatedSprite2D

@export var move:int = 5
@export var combat:int = 5
@export var ranged_combat:int = 5
@export var will:int = 5
@export var armor:int = 5
@export var health:int = 5
@export var current_health:int=health
@export var equipment:Dictionary={'weapon':{'name':'dagger','range':1,'attack bonus':1,'damage bonus':-1},
									'armor':{'name':'shirt','bonus':0},
									'accessory 1':{},
									'accessory 2':{}
									}
@export var inventory:Array=[]
@export var status:Array=[]
@export var faction:String
@export var character_name:String='Default'
@export var turn_tracker:Dictionary={'moved':false,'action':false,'turn_complete':false}
var previous_position:Vector2


signal turn_over
signal dead(character)	

func turn_start():
	for point in turn_tracker:
		turn_tracker[point] = false
	print("turn start")
	#we will add updates for start of turn stuff here

func get_attack():
	var bonus:int
	bonus=equipment['weapon']['attack bonus']+combat
	return bonus

func get_damage_bonus():
	var bonus:int
	bonus=equipment['weapon']['damage bonus']
	return bonus

func turn(turn_action):
	if turn_action=='turn_complete':
		turn_tracker[turn_action]=true
	if turn_action=='moved':
		turn_tracker[turn_action]=true
	if turn_action=='action':
		turn_tracker[turn_action]=true
	if turn_tracker['action'] and turn_tracker['moved']:
		turn_tracker['turn_complete']=true
		GlobalSignalBus.turn_over.emit()
		print("turn is over")


func take_damage(damage:int):
	damage=damage-armor
	if damage >=0:
		if current_health<=damage:
			current_health=0
			on_lethal_hit()
		else:
			current_health-=damage
			print()
	else:
		print('no damage dealt')



func on_lethal_hit():
	GlobalSignalBus.death.emit(self)
	print('oh shit you got me!!')


func undo_movement():
	position=previous_position
	turn_tracker['moved']=false
