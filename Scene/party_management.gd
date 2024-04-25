extends Node2D

@onready var character_name = $"management_ui/party management screen/party_management/party display/member display/GridContainer/name"
@onready var character_class = $"management_ui/party management screen/party_management/party display/member display/GridContainer/class name"
@onready var character_move =$"management_ui/party management screen/party_management/party display/member display/GridContainer/character move"
@onready var character_combat = $"management_ui/party management screen/party_management/party display/member display/GridContainer/character combat"
@onready var character_ranged = $"management_ui/party management screen/party_management/party display/member display/GridContainer/character ranged"
@onready var character_armor = $"management_ui/party management screen/party_management/party display/member display/GridContainer/character armor"
@onready var character_will = $"management_ui/party management screen/party_management/party display/member display/GridContainer/character will"
@onready var character_health = $"management_ui/party management screen/party_management/party display/member display/GridContainer/character health"
@onready var equipment_window = $"management_ui/party management screen/party_management/party display/member display/equipment window"
@onready var inventory = $"management_ui/party management screen/party_management/party display/inventory display/party inventory/inventory display"
@onready var item_description = $"management_ui/party management screen/party_management/party display/inventory display/party inventory/Item description background/item display/item description"
@onready var item_name = $"management_ui/party management screen/party_management/party display/inventory display/party inventory/Item description background/item display/item title bar/current item name"
@onready var equip = $"management_ui/party management screen/party_management/party display/inventory display/party inventory/Item description background/item display/button options/equip button"
@onready var drop = $"management_ui/party management screen/party_management/party display/inventory display/party inventory/Item description background/item display/button options/drop button"
@onready var player_gold = $"management_ui/party management screen/party_management/title_stats/player magement stats/player gold"
@onready var member_count = $"management_ui/party management screen/party_management/title_stats/player magement stats/member count"
@onready var party_list = $"management_ui/party management screen/party_management/party display/list display/party list/party"


var party_button=preload("res://Scene/party_member_button.tscn")
var current_party: Array
var current_inventory: Array
var current_gold: int

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignalBus.connect("character_selected",_character_selected)
	update_data()
	update_ui()
	

func update_data():
	current_party=World.player_party
	current_gold=World.player_gold
	current_inventory=World.player_inventory
	
func update_ui():
	if current_party:
		update_party_list()
	if current_gold:
		player_gold.text=current_gold
	if current_inventory:
		update_inventory()


func update_inventory():
	pass


func update_party_list():
	print("called")
	if current_party:
		member_count.text=str(len(current_party))
		for member in current_party:
			print(member)
			var new = party_button.instantiate()
			if ('character_name' in member) == false:
				member["character_name"]=Names.get_random_name()
			new.text = member['character_name']
			party_list.add_child(new)


func add_button(character):
	var new = party_button.instantiate()
	new.name=character["character_name"]
	party_list.add_child(new)
	new.text = character["character_name"]


func _character_selected(dude):
	var character: Dictionary
	for x in current_party:
		if x["character_name"] == dude:
			character = x
	character_name.text = character["character_name"]
	character_class.text = character["job"]
	character_move.text = str(character["stats"]["move"])
	character_combat.text = str(character["stats"]["combat"])
	character_ranged.text = str(character["stats"]["ranged_combat"])
	character_armor.text = str(character["stats"]["armor"])
	character_will.text = str(character["stats"]["will"])
	character_health.text = str(character["stats"]["health"])
	equipment_window.text = ''
	for item in character['equipment']:
		equipment_window.text+=character['equipment'][item] + ", "
	equipment_window.text = equipment_window.text.erase(len(equipment_window.text)-2)


func _on_back_button_button_up():
	get_tree().change_scene_to_file("res://Scene/level_select.tscn")
