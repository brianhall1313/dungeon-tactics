extends Node2D
var saves :Array=[]
@onready var save_interface=$"Save Interface"
# Called when the node enters the scene tree for the first time.
func _ready():
	populate_slots()
	save_interface.populate_data("Save",saves)
	GlobalSignalBus.connect('save',_save_data)

func populate_slots():
	saves = []
	for slot in range(1,5):
		var save_metadata = SaveAndLoad.load_metadata(slot)
		saves.append(save_metadata)


func _save_data(slot):
	SaveAndLoad.save_game(World.save(),slot)
	get_tree().change_scene_to_file("res://Scene/level_select.tscn")


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://Scene/level_select.tscn")