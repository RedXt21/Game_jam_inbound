extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_reset_pressed() -> void:
	if FileAccess.file_exists("user://player_progress.save"):
		FileAccess.remove("user://player_progress.save")
	if FileAccess.file_exists("user://chest_states.save"):
		FileAccess.remove("user://chest_states.save")
	for player in get_tree().get_nodes_in_group("player"):
		player.steps_taken = 0
		player.jumps_performed = 0
		player.speed_upgraded = false
		player.double_jump_unlocked = false
		player.dash_unlocked = false
		player.SPEED = player.BASE_SPEED
		player.save_progress()
	get_tree().reload_current_scene()
