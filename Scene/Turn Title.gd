extends Label

@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignalBus.connect("turn_start",_on_turn_start)
	hide()


func _on_turn_start(turn):
	if turn == "player":
		self.text = "Player Turn!"
	elif turn == "enemy":
		self.text = "Enemey Turn!"
	self.show()
	timer.start()
	await timer.timeout
	self.hide()
