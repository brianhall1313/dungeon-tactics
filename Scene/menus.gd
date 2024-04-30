extends Control
signal movement_selected
signal fight_selected
signal turn_end_selected

@onready var sa_open:bool=false

func _ready():
	GlobalSignalBus.connect("show_fight_menu",show_menu)
	GlobalSignalBus.connect("hide_fight_menu",hide_menu)
	GlobalSignalBus.connect("hide_sa_menu",sa_close)
	GlobalSignalBus.connect("update_menu",update)



func show_menu():
	$fight_menu.show_menu()
	$fight_menu/fight_menu_move.grab_focus()
	
func hide_menu():
	hide()


func sa_close():
	$sa_menu.close()
 

func update(chara):
	$fight_menu.update_menu(chara)


func _on_fight_menu_fight_selected():
	GlobalSignalBus.fight_selected.emit()


func _on_fight_menu_movement_selected():
	GlobalSignalBus.move_selected.emit()


func _on_fight_menu_turn_end_selected():
	GlobalSignalBus.turn_end_selected.emit()


func _on_sa_menu_open():
	sa_open = true


func _on_sa_menu_go_back_pressed():
	sa_open = false
