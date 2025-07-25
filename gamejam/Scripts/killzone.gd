extends Area2D

@onready var timer: Timer = $Timer
@onready var game_over: Panel = $"../CanvasLayer/GameOver"

func _ready() -> void:
	game_over.visible = false

func _on_body_entered(body: CharacterBody2D) -> void:
	game_over.visible = true
	Engine.time_scale = 0.75
	body.get_node("CollisionShape2D").queue_free()
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
