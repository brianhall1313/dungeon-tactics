extends AudioStreamPlayer

var effect_dict:Dictionary = {"basic_hit":preload("res://Sound/mixkit-fast-blow-2144.wav"),
}
# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignalBus.connect('play_effect',_on_play_effect)

func _on_play_effect(effect):
	stream=effect_dict[effect]
	play()
