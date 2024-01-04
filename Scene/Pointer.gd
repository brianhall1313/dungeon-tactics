extends Sprite2D
@export var grid_position: Vector2i=Vector2i(0,0)

func movement(pos:Vector2i,raw:Vector2):
	grid_position=pos
	self.position=raw
