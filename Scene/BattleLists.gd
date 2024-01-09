class_name BattleLists
extends Node

@onready var enemies:BattleLists
@onready var player:BattleLists

func _ready():
	enemies=$enemy_list
	player=$player_list

func remove_character(character):
	if character.faction=='player':
		player.remove(character)
	elif character.faction=='enemy':
		enemies.remove(character)

func get_enemies():
	return enemies.list

func get_player():
	return player.list
