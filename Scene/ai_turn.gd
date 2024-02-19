class_name AITurn
extends State
signal ai_turn_start
signal ai_turn_over


func _enter_state():
	ai_turn_start.emit(  )
	print("now it's the AI's turn")
