extends VBoxContainer
signal movement_selected
signal fight_selected
@onready var move_button =$fight_menu_move
@onready var fight_button =$fight_menu_fight

func update_menu(character):
	if character:
		if character.turn_tracker["moved"]==true:
			move_button.set_disabled(true)
		else:
			move_button.set_disabled(false)
		if character.turn_tracker["action"]==true:
			fight_button.set_disabled(true)
		else:
			fight_button.set_disabled(false)

func move(pos:Vector2):
	position=pos
	

func _ready():
	hide()

func _on_character_interaction_show_fight_menu():
	show()
	$fight_menu_move.grab_focus()

func _on_fight_menu_move_move_selected():
	movement_selected.emit()
	hide()

func _on_fight_menu_fight_fight_selected():
	fight_selected.emit()
	hide()
