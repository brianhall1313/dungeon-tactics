extends Control
signal movement_selected
signal fight_selected
signal turn_end_selected

@onready var sa_open:bool=false



func move(pos:Vector2):
	position=pos
	
func show_menu():
	$fight_menu.show_menu()
	
func hide_menu():
	hide()


func sa_close():
	$sa_menu.close()
 

func update(chara):
	$fight_menu.update_menu(chara)


func _on_fight_menu_fight_selected():
	fight_selected.emit()


func _on_fight_menu_movement_selected():
	movement_selected.emit()


func _on_fight_menu_turn_end_selected():
	turn_end_selected.emit()


func _on_sa_menu_open():
	sa_open = true


func _on_sa_menu_go_back_pressed():
	sa_open = false
