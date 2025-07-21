extends Area2D

signal chest_opened

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_open = false
var player_in_range = null

func _ready():
	animated_sprite_2d.play("treasure_closed")
	$indicator.visible = false
	$dash.visible = false

func _process(_delta):
	if player_in_range and not is_open and Input.is_action_just_pressed("pick"):
		$dash.visible = true
		open_chest(player_in_range)
		
		

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = body
		$indicator.visible = true

func _on_body_exited(body):
	if body == player_in_range:
		player_in_range = null
		$indicator.visible = false
		$dash.visible = false

func open_chest(player):
	is_open = true
	animated_sprite_2d.play("treasure_opened")
	emit_signal("chest_opened", player)
	
	if player.has_method("unlock_dash"):
		player.unlock_dash()
		print_debug("Dash Unlocked")

	# Optionally: Give player an item, play sound, etc.
