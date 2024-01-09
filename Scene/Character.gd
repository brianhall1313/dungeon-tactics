extends AnimatedSprite2D

@export var default_position:Vector2i=Vector2i(0,0)
@export var job:String
@export var move:int = 5
@export var combat:int = 5
@export var ranged_combat:int = 5
@export var will:int = 5
@export var armor:int = 10
@export var health:int = 5
@export var current_health:int=health
@export var equipment:Dictionary={'weapon':{'name':'dagger','range':1,'attack bonus':1,'damage bonus':-1},
									'armor':{'name':'shirt','bonus':0},
									'accessory 1':{},
									'accessory 2':{}
									}
@export var spells:Dictionary={}
@export var abilities:Dictionary={}
@export var experience:int=0
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


func character_setup(character_data):
	self.character_name=character_data['name']
	self.default_position=character_data.default_position
	self.experience=character_data.experience
	self.faction=character_data['faction']
	self.job=character_data['job']
	stat_setup(character_data['stats'])
	equipment_setup(character_data['equipment'])
	spell_setup(character_data['spells'])
	ability_setup(character_data['abilities'])


func stat_setup(job:Dictionary):
	self.move=job['move']
	self.combat=job['combat']
	self.ranged_combat=job['ranged_combat']
	self.will=job['will']
	self.health=job['health']
	self.current_health=job['health']



func equipment_setup(equipment:Array):
	pass


func spell_setup(spell_list:Dictionary):
	pass


func ability_setup(abilities:Array):
	pass



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

func movement(new_position:Vector2):
	self.previous_position=self.position
	self.position=new_position
	turn_tracker['moved']=true


func undo_movement():
	position=previous_position
	turn_tracker['moved']=false
