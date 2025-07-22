extends Sprite2D

func _ready() -> void:
	$press_enter.visible = false

func on_body_entered(_body: Node2D) -> void:
	$press_enter.visible = true

func _on_area_2d_body_exited(_body: Node2D) -> void:
	$press_enter.visible = false
