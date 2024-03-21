extends VBoxContainer
signal open
signal go_back_pressed
signal activate(name:String)

@onready var prototype_button=preload("res://Scene/sa_button_prototype.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignalBus.connect("sa_button_pressed",_on_sa_button_pressed)
	hide()

func show_menu():
	show()
	get_viewport().set_input_as_handled()
	$sa_menu_go_back.grab_focus()


func close():
	hide()
	get_viewport().set_input_as_handled()
	go_back_pressed.emit()


func _on_sa_menu_go_back_button_up():
	close()


func _on_fight_menu_sa_selected():
	open.emit()
	show_menu()


func _on_fight_menu_sa_setup(character):
	var children = get_children()
	for child in children:
		if child.name != "sa_menu_go_back":
			child.queue_free()
	if len(character.abilities)>0:
		for i in character.abilities:
			var button = prototype_button.instantiate()
			button.name=i
			button.text=i
			if character.turn_tracker['action']:
				button.disabled=true
			add_child(button)

	if len(character.spells)>0:
		for i in character.spells:
			var button = prototype_button.instantiate()
			button.name=i
			button.text=i
			if character.turn_tracker['action']:
				button.disabled=true
			add_child(button)


func _on_sa_button_pressed(text):
	print("targeting with " + text)
	hide()
