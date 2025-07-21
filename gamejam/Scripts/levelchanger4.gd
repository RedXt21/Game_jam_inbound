extends Area2D

@onready var timer: Timer = $Timer
@onready var panel: Panel = $"../CanvasLayer2/Panel"

func _ready() -> void:
	panel.visible = false

func _on_body_entered(_body: CharacterBody2D) -> void:
	panel.visible = true
	timer.start()

func _on_timer_timeout() -> void:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
