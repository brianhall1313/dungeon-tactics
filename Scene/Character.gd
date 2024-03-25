extends AnimatedSprite2D

@export var character_name:String="Default"
@export var default_position:Vector2i=Vector2i(0,0)
@export var grid_position:Vector2i
@export var job:String="classless"
@export var tags:Array=['humanoid']
@export var move:int = 5
@export var combat:int = 5
@export var ranged_combat:int = 5
@export var will:int = 5
@export var armor:int = 10
@export var health:int = 5
@export var current_health:int=health
@export var current_weapon:String="weapon"
@export var equipment:Dictionary={'weapon':{'name':'dagger','range':1,'attack_bonus':1,'damage_bonus':-1},
									'ranged_weapon':{'name':'Bow','range':5,'attack_bonus':1,'damage_bonus':0},
									'armor':{'name':'shirt','bonus':0},
									'accessory 1':{},
									'accessory 2':{}
									}
@export var spells:Array=["Elemental Bolt",'Summon Undead','Heal']
@export var abilities:Array=[]
@export var experience:int=0
@export var level:int=0
@export var inventory:Array=[]
@export var status:Array=[]
@export var faction:String
@export var turn_tracker:Dictionary={'moved':false,'action':false,'turn_complete':false}
var previous_position:Vector2
var previous_position_coor:Vector2i
var possible_targets:Array=[]


signal dead(character)	

func turn_start():
	for point in self.turn_tracker:
		self.turn_tracker[point] = false
	previous_position=self.position
	previous_position_coor=self.grid_position
	#we will add updates for start of turn stuff here


func character_setup(character_data):
	print('character setup')
	$Sprite2D["scale"]=Vector2(.1,.1)
	self.character_name=character_data['character_name']
	self.default_position=character_data.default_position
	self.experience=character_data.experience
	self.faction=character_data['faction']
	self.job=character_data['job']
	self.tags=character_data['tags']
	stat_setup(character_data['stats'])
	if 'humanoid' in tags:
		equipment_setup(character_data['equipment'])
	else:
		equipment['weapon']=BeastWeapons.beast_weapons[character_data['equipment'][0]].duplicate()
	spell_setup(character_data['spells'])
	ability_setup(character_data['abilities'])
	select_weapon(false)
	turn_start()


func stat_setup(njob:Dictionary):
	self.move=njob['move']
	self.combat=njob['combat']
	self.ranged_combat=njob['ranged_combat']
	self.will=njob['will']
	self.health=njob['health']
	self.current_health=njob['health']



func equipment_setup(new_equipment:Array):
	equipment={}
	for x in new_equipment:
		print(x)
		if Weapons.weapons_dictionary.has(x):
			if Weapons.weapons_dictionary[x]['range']<2:
				equipment['weapon']=Weapons.weapons_dictionary[x].duplicate()
			else:
				equipment['ranged_weapon']=Weapons.weapons_dictionary[x].duplicate()
		elif Armor.armor_dictionary.has(x):
			equipment[x]=Armor.armor_dictionary[x].duplicate()
	print(equipment)
	calculate_armor()
	if equipment.has('weapon'):
		current_weapon = 'weapon'
	else:
		equipment['weapon']=Weapons.weapons_dictionary['unarmed'].duplicate()
	if equipment.has('ranged_weapon'):
		current_weapon = 'ranged_weapon'

func spell_setup(spell_list:Array):
	for spell in spell_list:
		self.spells.append(spell)


func ability_setup(new_abilities:Array):
	for ability in new_abilities:
		self.spells.append(ability)


func select_weapon(in_combat:bool):
	if in_combat:
		current_weapon='weapon'
	elif equipment.has('ranged_weapon'):
		current_weapon='ranged_weapon'
	else:
		current_weapon='weapon'


func get_attack():
	var bonus:int
	if current_weapon=='weapon':
		bonus=equipment[current_weapon]['attack_bonus']+combat
	else:
		bonus=equipment[current_weapon]['attack_bonus']+ranged_combat
	return bonus

func get_damage_bonus():
	var bonus:int
	bonus=equipment[current_weapon]['damage_bonus']
	return bonus

func turn(turn_action):
	if turn_action=='turn_complete':
		turn_tracker[turn_action]=true
		GlobalSignalBus.turn_over.emit(self)
		print("turn is over1")
	if turn_action=='moved':
		turn_tracker[turn_action]=true
	if turn_action=='action':
		turn_tracker[turn_action]=true
	if turn_tracker['action'] and turn_tracker['moved']:
		turn_tracker['turn_complete']=true
		print("turn is over "+self.character_name)
		GlobalSignalBus.turn_over.emit(self)


func take_damage(damage:int):
	damage=damage-armor
	GlobalSignalBus.combat_message.emit("The damage dealt is "+str(damage))
	if damage >=0:
		if current_health<=damage:
			current_health=0
			on_lethal_hit()
		else:
			current_health-=damage


func heal(amount:int):
	if current_health<health:
		if current_health+amount > health:
			current_health=health
		else:
			current_health+=amount
	print(character_name,"healed for",amount)



func on_lethal_hit():
	GlobalSignalBus.death.emit(self)
	print('oh shit you got me!!')

func movement(new_position:Vector2,new_grid_position:Vector2i):
	self.previous_position=self.position
	self.previous_position_coor=self.grid_position
	self.position=new_position
	self.grid_position=new_grid_position
	turn_tracker['moved']=true


func undo_movement():
	if previous_position:
		position=previous_position
		grid_position=previous_position_coor
		turn_tracker['moved']=false


func calculate_armor():
	for x in equipment:
		if equipment[x].has("type"):
			if equipment[x].has("bonus"):
				self.armor+=equipment[x]["bonus"]
			if equipment[x].has("move_modifier"):
				self.move+=equipment[x]['move_modifier']


func export_save_data():
	var data:Dictionary={
		"character_name":self.character_name,
		"job":self.job,
		"tags":self.tags.duplicate(),
		"equipment":self.equipment.duplicate(true),
		"spells":self.spells.duplicate(),
		"abilities":self.abilities.duplicate(),
		"experience":self.experience,
		"level":self.level,
		"inventory":self.inventory.duplicate(),
	}
	return data
