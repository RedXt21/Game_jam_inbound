extends Area2D

func _on_body_entered(_body: CharacterBody2D) -> void:
	print_debug("Coin Acquired")
	queue_free()
