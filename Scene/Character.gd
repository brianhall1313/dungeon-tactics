class_name Character
extends AnimatedSprite2D

@export var character_name:String="Default"
@export var default_position:Vector2i=Vector2i(-100,-100)
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
@export var equipment:Dictionary={'weapon':'dagger',
									'ranged_weapon':'Bow',
									'off_hand':'',
									'armor':'unarmored',
									'accessory 1':'',
									'accessory 2':''
									}
@export var spells:Array=[]
@export var abilities:Array=[]
@export var experience:int=0
@export var level:int=0
@export var inventory:Array=[]
@export var status:Array=[]
@export var faction:String
@export var turn_tracker:Dictionary={'moved':false,'action':false,'turn_complete':false}

@onready var sprite = $Sprite2D
@onready var health_bar = $health_bar


var previous_position:Vector2
var previous_position_coor:Vector2i
var possible_targets:Array=[]


signal dead(character)	

func turn_start():
	set_health_bar_value(current_health)
	sprite.modulate=Color('WHITE')
	for point in self.turn_tracker:
		self.turn_tracker[point] = false
	previous_position=self.position
	previous_position_coor=self.grid_position
	#we will add updates for start of turn stuff here


func character_setup(character_data):
	sprite["scale"]=Vector2(.1,.1)
	if 'character_name' in character_data:
		self.character_name=character_data['character_name']
	else:
		self.character_name=Names.get_random_name()
	if "default_position" in character_data:
		if typeof(character_data['default_position'])==6:
			self.default_position=character_data.default_position
		else:
			print(character_data["default_position"])
			self.default_position=set_default_position(character_data["default_position"])
	if 'experience' in character_data:
		self.experience=character_data['experience']
	self.faction=character_data['faction']
	self.job=character_data['job']
	if ClassData.class_dictionary[self.job]["sprite"] != '':
		var texture_string="res://textures/"+ ClassData.class_dictionary[self.job]["sprite"]
		sprite.texture = load(texture_string)
		sprite.scale = Vector2(.75,.75)
	if 'tags' in character_data:
		self.tags=character_data['tags']
	else:
		self.tags=ClassData.class_dictionary[self.job]['tags'].duplicate()
	if 'stats' in character_data:
		stat_setup(character_data['stats'])
	else:
		stat_setup(ClassData.class_dictionary[self.job])
	if 'equipment' in character_data:
		equipment_setup(character_data['equipment'])
	else:
		equipment_setup(ClassData.class_dictionary[self.job]['equipment'])
	if 'spells' in character_data:
		spell_setup(character_data['spells'])
	else:
		spell_setup(ClassData.class_dictionary[self.job]['spells'])
	if 'abilities' in character_data:
		ability_setup(character_data['abilities'])
	else:
		ability_setup(ClassData.class_dictionary[self.job]['abilities'])
	select_weapon(false)
	setup_health_bar()
	turn_start()


func stat_setup(njob:Dictionary):
	self.move=njob['move']
	self.combat=njob['combat']
	self.ranged_combat=njob['ranged_combat']
	self.will=njob['will']
	self.health=njob['health']
	self.current_health=njob['health']


func set_default_position(pos):
	return Vector2i(pos[0],pos[1])


func set_health_bar_value(i:int):
	health_bar.value = i



func equipment_setup(new_equipment):
	equipment={}
	for x in new_equipment:
		if Weapons.weapons_dictionary.has(x):
			if Weapons.weapons_dictionary[x]['range']<2:
				equipment['weapon']=x
			else:
				equipment['ranged_weapon']=x
		elif Armor.armor_dictionary.has(x):
			if Armor.armor_dictionary[x]["type"]=='shield':
				self.equipment['off_hand']=x
			else:
				equipment['armor']=x
	print(equipment)
	calculate_armor()
	if equipment.has('weapon'):
		current_weapon = 'weapon'
	else:
		equipment['weapon']='unarmed'
		current_weapon ='weapon'
	if equipment.has('ranged_weapon'):
		current_weapon = 'ranged_weapon'

func spell_setup(spell_list:Array):
	for spell in spell_list:
		self.spells.append(spell)


func ability_setup(new_abilities:Array):
	for ability in new_abilities:
		self.spells.append(ability)


func setup_health_bar():
	health_bar.max_value = self.health
	health_bar.value = self.health
	
	var style = StyleBoxFlat.new()
	health_bar.add_theme_stylebox_override('fill',style)
	if self.faction == "enemy":
		style.bg_color = Color("RED")
	if self.faction == "player":
		style.bg_color = Color("BLUE")
	style.set_corner_radius_all(5)



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
		bonus=Weapons.weapons_dictionary[equipment[current_weapon]]['attack_bonus']+combat
	else:
		bonus=Weapons.weapons_dictionary[equipment[current_weapon]]['attack_bonus']+ranged_combat
	return bonus

func get_damage_bonus():
	var bonus:int
	bonus=Weapons.weapons_dictionary[equipment[current_weapon]]['damage_bonus']
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
	if turn_tracker['turn_complete']==true:
		sprite.modulate=Color('WEB GRAY')


func take_damage(damage:int):
	damage=damage-armor
	if damage >=0:
		GlobalSignalBus.combat_message.emit("The damage dealt is "+str(damage))
		if current_health<=damage:
			current_health=0
			set_health_bar_value(current_health)
			on_lethal_hit()
		else:
			current_health-=damage
			set_health_bar_value(current_health)
			take_damage_animation()
	else:
		GlobalSignalBus.combat_message.emit("Armor blocked the damage")


func heal(amount:int):
	if current_health<health:
		if current_health+amount > health:
			current_health=health
		else:
			current_health+=amount
	set_health_bar_value(current_health)
	GlobalSignalBus.combat_message.emit(character_name + " is healed for " + str(amount))


func revive():
	self.current_health = self.health
	set_health_bar_value(self.health)
	turn_start()



func on_lethal_hit():
	GlobalSignalBus.death.emit(self)
	print('oh shit you got me!!')


func tween_movement(new_previous_position:Vector2,new_grid_position:Vector2i):
	self.previous_position=new_previous_position
	self.previous_position_coor=self.grid_position
	self.grid_position=new_grid_position
	turn_tracker['moved']=true


func movement(new_position:Vector2,new_grid_position:Vector2i):
	self.previous_position=self.position
	self.previous_position_coor=self.grid_position
	self.position=new_position
	self.grid_position=new_grid_position
	turn_tracker['moved']=true


func undo_movement():
	if previous_position:
		self.position=previous_position
		grid_position=previous_position_coor
		turn_tracker['moved']=false


func calculate_armor():
	self.armor = 10
	for x in equipment:
		if equipment[x] in Armor.armor_dictionary:
			self.armor += Armor.armor_dictionary[equipment[x]]['bonus']
		elif equipment[x] == 'staff':
			#Staff armor bonus
			self.armor += 1


func cast(action:String):
	if SpellsAndAbilities.spells_and_abilities_directory[action]:
		if SpellsAndAbilities.spells_and_abilities_directory[action]["spell"]:
			var cast_roll = AttackTools._dice_roll()+will
			if cast_roll >= SpellsAndAbilities.spells_and_abilities_directory[action]['cost']: 
				return true
			else:
				GlobalSignalBus.combat_message.emit(character_name + ' has failed to cast: got a '+str(cast_roll))
				return false
		else:
			take_raw_damage(SpellsAndAbilities.spells_and_abilities_directory[action]["cost"])
			return true
	return false


func take_raw_damage(damage:int):
	GlobalSignalBus.combat_message.emit(self.character_name+" pays the price: "+str(damage))
	if current_health<=damage:
		current_health=0
		set_health_bar_value(current_health)
		on_lethal_hit()
	else:
		current_health-=damage
		set_health_bar_value(current_health)




func package_stats():
	var stats:Dictionary={
		"move":self.move,
		"combat":self.combat,
		"ranged_combat":self.ranged_combat,
		"armor":self.armor,
		"will":self.will,
		"health":self.health,
	}
	return stats


func export_save_data():
	var data:Dictionary={
		"character_name":self.character_name,
		"job":self.job,
		"stats":package_stats(),
		"tags":self.tags.duplicate(),
		"spells":self.spells.duplicate(),
		"abilities":self.abilities.duplicate(),
		"experience":self.experience,
		"level":self.level,
		"inventory":self.inventory.duplicate(),
	}
	#it's easier to set up if equipment is an array
	data["equipment"] = []
	for x in equipment:
		data["equipment"].append(x)
	return data


func take_damage_animation():
	var tween = get_tree().create_tween()
	var move_range:int = 5
	GlobalSignalBus.play_effect.emit("basic_hit")
	tween.tween_property(self, "modulate", Color.RED, .1)
	var start_x = sprite.offset.x - move_range
	var mid_x = sprite.offset.x 
	var end_x = sprite.offset.x + move_range
	tween.tween_property(sprite, "offset:x", end_x, .01).from(start_x)
	tween.tween_property(sprite, "offset:x", start_x, .01).from(end_x)
	tween.tween_property(sprite, "offset:x", end_x, .01).from(start_x)
	tween.tween_property(sprite, "offset:x", start_x, .01).from(end_x)
	tween.tween_property(self, "modulate", Color.WHITE, .2)
	await tween.finished
	sprite.offset.x = mid_x
