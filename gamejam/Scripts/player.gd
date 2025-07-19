extends CharacterBody2D

# --- Player Progression Counters ---
var steps_taken = 0
var jumps_performed = 0
var attacks_made = 0

# --- Unlock Flags ---
var speed_upgraded = false
var double_jump_unlocked = false
var combo_attack_unlocked = false
var dash_unlocked = false
var magic_unlocked = false

# --- Player Stats ---
var SPEED = 300.0
const BASE_SPEED = 300.0
const UPGRADED_SPEED = 400.0
const JUMP_VELOCITY = -400.0

# --- Double Jump State ---
var has_double_jumped = false

func _ready():
	load_progress()

func _physics_process(delta: float) -> void:
	# Debug: Print progression counters  
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jumps_performed += 1
			has_double_jumped = false
			_check_jump_milestone()
		elif double_jump_unlocked and not has_double_jumped:
			velocity.y = JUMP_VELOCITY
			has_double_jumped = true
			jumps_performed += 1
			_check_jump_milestone()

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		# Count a step only if moving and on the ground
		if is_on_floor():
			steps_taken += 1
			_check_step_milestone()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# --- Placeholder: Attack Input ---
	# Replace 'ui_attack' with your actual attack action name
	if Input.is_action_just_pressed("attack"):
		attacks_made += 1
		_check_attack_milestone()
		# Call your attack function here

# --- Milestone Check Functions ---
func _check_step_milestone():
	if not speed_upgraded and steps_taken >= 100:
		SPEED = UPGRADED_SPEED
		speed_upgraded = true
		print("Speed upgraded! New speed:", SPEED)
		save_progress()

func _check_jump_milestone():
	if not double_jump_unlocked and jumps_performed >= 5:
		double_jump_unlocked = true
		print("Double jump unlocked!")
		save_progress()

func _check_attack_milestone():
	if not combo_attack_unlocked and attacks_made >= 5:
		combo_attack_unlocked = true
		print("Combo attack unlocked!")
		save_progress()

func save_progress():
	var save_data = {
		"steps_taken": steps_taken,
		"jumps_performed": jumps_performed,
		"attacks_made": attacks_made,
		"speed_upgraded": speed_upgraded,
		"double_jump_unlocked": double_jump_unlocked,
		"combo_attack_unlocked": combo_attack_unlocked
	}
	var file = FileAccess.open("user://player_progress.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_progress():
	if not FileAccess.file_exists("user://player_progress.save"):
		return
	var file = FileAccess.open("user://player_progress.save", FileAccess.READ)
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	file.close()
	if result == OK and typeof(json.data) == TYPE_DICTIONARY:
		var save_data = json.data
		steps_taken = save_data.get("steps_taken", 0)
		jumps_performed = save_data.get("jumps_performed", 0)
		attacks_made = save_data.get("attacks_made", 0)
		speed_upgraded = save_data.get("speed_upgraded", false)
		double_jump_unlocked = save_data.get("double_jump_unlocked", false)
		combo_attack_unlocked = save_data.get("combo_attack_unlocked", false)
		# Apply upgrades if already unlocked
		if speed_upgraded:
			SPEED = UPGRADED_SPEED
