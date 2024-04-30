extends Node
@onready var effects:Dictionary={
	"arrow":preload("res://Animations/arrow.tscn"),
	"blunt":preload("res://Animations/blunt.tscn"),
	"slash":preload("res://Animations/slash.tscn"),
	"fireball":preload("res://Animations/fireball.tscn"),
	"elemental_explosion":preload("res://Animations/elemental_explosion.tscn"),
	"heal":preload("res://Animations/heal.tscn"),
	"summon_circle":preload("res://Animations/summon_circle.tscn")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignalBus.connect("play_animation",_on_play_animation)

func _on_play_animation(animation,target,origin):
	if origin:
		ranged_animation(origin,target,animation)
	else:
		play_basic(animation,target)

func play_basic(animation,target):
	var sprite = effects[animation].instantiate()
	sprite.position = target.position
	get_tree().current_scene.add_child(sprite)
	sprite.play()
	await sprite.animation_looped
	sprite.queue_free()

func ranged_animation(character,defender,sprite,ending=false):
	GlobalSignalBus.change_state.emit('animation_state')
	var animate: AnimatedSprite2D = effects[sprite].instantiate()
	var ending_sprite: AnimatedSprite2D
	if ending:
		ending_sprite = effects[ending].instantiate()
	get_tree().current_scene.add_child(animate)
	animate.position = character.position
	animate.look_at(defender.position)
	animate.play()
	var tween = get_tree().create_tween()
	tween.tween_property(animate,"position",defender,.5).from(animate.position)
	tween.tween_callback(animate.queue_free)
	await tween.finished
	if ending:
		add_child(ending_sprite)
		ending_sprite.position = defender
		ending_sprite.play()
		await ending_sprite.animation_looped
		ending_sprite.queue_free()
