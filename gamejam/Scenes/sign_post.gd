extends Sprite2D

func _ready() -> void:
	$press_enter.visible = false


func on_body_entered(body: Node2D) -> void:
	$press_enter.visible = true
		


func _on_area_2d_body_exited(body: Node2D) -> void:
	$press_enter.visible = false
