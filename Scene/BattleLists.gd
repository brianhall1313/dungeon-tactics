class_name BattleLists
extends Node

@onready var enemies:BattleLists
@onready var player:BattleLists

func _ready():
	enemies=$enemies
	player=$player
	connect_signals()

func connect_signals():
	GlobalSignalBus.connect('turn_start',_on_turn_start)


func load_character():
	pass


func add_character(character_data):
	if character_data['faction']=="player":
		player.add(character_data)
	if character_data['faction']=='enemy':
		enemies.add(character_data)



func remove_character(character):
	if character.faction=='player':
		player.remove(character)
	elif character.faction=='enemy':
		enemies.remove(character)

func get_enemies():
	return enemies

func get_player():
	return player


func check_turn_over(current_turn:String):
	if current_turn == "player":
		if player.is_turn_over():
			GlobalSignalBus.all_units_activated.emit(current_turn)
	elif current_turn == 'enemy':
		if enemies.is_turn_over():
			GlobalSignalBus.all_units_activated.emit(current_turn)


func _on_turn_start(turn:String):
	if turn=='player':
		player.full_turn_start()
	elif turn=='enemy':
		enemies.full_turn_start()
