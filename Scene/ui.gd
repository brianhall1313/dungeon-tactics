extends CanvasLayer

@onready var selected=$selected_character_info
@onready var targeted=$targeted_character_info
@onready var selected_portrait =$left_portrait
@onready var targeted_portrait=$right_portrait





func _on_map_hide_selected_ui():
	selected.hide()
	selected_portrait.hide()


func _on_map_hide_targeted_ui():
	targeted.hide()
	targeted_portrait.hide()


func _on_map_show_selected_ui():
	selected.show()
	selected_portrait.show()


func _on_map_show_targeted_ui():
	targeted.show()
	targeted_portrait.show()


func _on_map_update_selected_ui(character):
	selected.update(character)
	selected_portrait.update(character)


func _on_map_update_targeted_ui(character):
	targeted.update(character)
	targeted_portrait.update(character)

