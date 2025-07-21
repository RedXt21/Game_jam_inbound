extends Area2D

signal chest_opened

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var chest_id: String = "chest_1"

var is_open = false
var player_in_range = null

const SAVE_PATH := "user://chest_states.save"

func _ready():
	var chest_states = load_chest_states()
	is_open = chest_states.get(chest_id, false)
	if is_open:
		animated_sprite_2d.play("treasure_opened")
		$indicator.visible = false
		$dash.visible = false
	else:
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
	save_chest_state()

func save_chest_state():
	var chest_states = load_chest_states()
	chest_states[chest_id] = true
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(chest_states)
	file.close()

func load_chest_states():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			return data
	return {}
