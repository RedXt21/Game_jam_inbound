extends Area2D

func _on_body_entered(_body: CharacterBody2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/level_3.tscn")
