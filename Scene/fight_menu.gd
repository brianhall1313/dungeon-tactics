extends VBoxContainer
signal movement_selected
signal fight_selected
signal turn_end_selected
signal sa_setup(character)
signal sa_selected

@onready var move_button =$fight_menu_move
@onready var fight_button =$fight_menu_fight
@onready var sa_button= $fight_menu_spells_and_abilities
@onready var end_button=$fight_menu_end_turn


func _ready():
	hide()




func update_menu(character):
	if character:
		if len(character.abilities)>0 or len(character.spells)>0:
			populate_submenu(character)
			sa_button.set_disabled(false)
		else:
			sa_button.set_disabled(true)
		if character.turn_tracker["moved"]==true:
			move_button.set_disabled(true)
		else:
			move_button.set_disabled(false)
		if character.turn_tracker["action"]==true:
			fight_button.set_disabled(true)
			sa_button.set_disabled(true)
		else:
			fight_button.set_disabled(false)
			sa_button.set_disabled(false)

func move(pos:Vector2):
	position=pos

func show_menu():
	show()
	$fight_menu_move.grab_focus()


func populate_submenu(character):
	sa_setup.emit(character)
	


func _on_fight_menu_move_move_selected():
	movement_selected.emit()
	hide()

func _on_fight_menu_fight_fight_selected():
	fight_selected.emit()
	hide()


func _on_fight_menu_end_turn_end_selected():
	turn_end_selected.emit()
	hide()


func _on_fight_menu_spells_and_abilities_sa_selected():
	release_focus()
	hide()
	sa_selected.emit()


func _on_sa_menu_go_back_pressed():
	show_menu()
