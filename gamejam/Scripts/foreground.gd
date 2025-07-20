extends Sprite2D

@export var strength: int = 2

func _process(delta: float) -> void:
	position += (get_global_mouse_position()/strength*delta) - position
