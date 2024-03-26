extends Node


var turn_counter:int
var turn:String
@export var default_turn:String='player'
@export var victory:Array=['Defeat all enemies']
@onready var map=$Map
var ai_skip_turn=true

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_input()
	load_level(LevelData.level_data)
	#Here we should handle cutscene stuff
	#here we should handle party placement
	match_start()


func get_current_board_state():
	var x =map.board_state#.duplicate() #I don't know if it would be a good idea to duplicate or just send the address
	return x


func connect_input():
	GlobalSignalBus.connect('interact',interaction)
	GlobalSignalBus.connect('moved',move)
	GlobalSignalBus.connect('cancel',cancel)
	GlobalSignalBus.connect('all_units_activated',turn_handover)
	GlobalSignalBus.connect('party_wipe',_on_party_wipe)
	
	


func interaction():
	if turn == 'player':
		Global.current_state.interact()	
	
func move(direction):
	if turn == 'player':
		Global.current_state.movement(direction)

func cancel():
	if turn == 'player':
		Global.current_state.cancle()

func match_start():
	turn_counter = 1
	turn = default_turn
	print("let's_start_the_match")
	if turn=='player':
		print('Round: ' + str(turn_counter) + " Player's turn")
		GlobalSignalBus.change_state.emit("grid_interact")
		GlobalSignalBus.turn_start.emit(turn)
	else:
		print('Round: ' + str(turn_counter) + " Enemy's turn")
		GlobalSignalBus.turn_start.emit(turn)
		GlobalSignalBus.change_state.emit('ai_turn')

func turn_handover():
	if turn=='enemy':
		turn_counter+=1
		turn = 'player'
		print('Round: ' + str(turn_counter) + " Player's turn")
		GlobalSignalBus.turn_start.emit(turn)
		GlobalSignalBus.change_state.emit("grid_interact")
		
	else:
		
		print('Round: ' + str(turn_counter) + " Enemy's turn")
		turn = 'enemy'
		GlobalSignalBus.turn_start.emit(turn) 
		GlobalSignalBus.change_state.emit('ai_turn')
		if Global.debug and ai_skip_turn:
			turn_handover()
		else:
			$ai_manager.begin_turn()
  


func _on_party_wipe(faction:String):
	if faction == 'enemy':
		print("Player Wins")
	else:
		print("player looses~")
	GlobalSignalBus.change_state.emit('game_over')


func load_level(level_data):
	var level:Dictionary=level_data[Global.current_level]
	map.setup_level(level)
