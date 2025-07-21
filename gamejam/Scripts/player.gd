extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var steps_taken = 0
var jumps_performed = 0
var speed_upgraded = false
var double_jump_unlocked = false
var dash_unlocked = false
@export var SPEED = 150.0
@export_range(0,1) var deceleration = 0.1
@export_range(0,1) var acceleration = 0.1
const BASE_SPEED = 150.0
const UPGRADED_SPEED = 250.0
@export var JUMP_VELOCITY = -400.0
@export_range(0,1) var decelerate_on_jump_release = 0.5
@export var dash_speed = 1000.0
@export var dash_max_distance = 300.0
@export var dash_curve : Curve
@export var dash_cooldown = 1.0
@export var is_dashing := false
@export var dash_start_position := 0.0
@export var dash_direction := 0
@export var dash_timer := 0.0
var has_double_jumped = false
var is_wall_sliding = false
var wall_slide_speed = 200.0
var wall_jump_force = Vector2(300.0, -350.0)
var can_wall_jump = true
var was_on_wall = false

func _ready():
	add_to_group("player")
	load_progress()
	$dj.visible = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jumps_performed += 1
			has_double_jumped = false
			_check_jump_milestone()
		elif (is_on_wall() or was_on_wall) and can_wall_jump:
			var wall_jump_direction = 1 if get_wall_normal().x < 0 else -1
			velocity.x = wall_jump_force.x * wall_jump_direction
			velocity.y = wall_jump_force.y
			can_wall_jump = false
			has_double_jumped = false
			jumps_performed += 1
			_check_jump_milestone()
		elif double_jump_unlocked and not has_double_jumped:
			velocity.y = JUMP_VELOCITY
			has_double_jumped = true
			jumps_performed += 1
			_check_jump_milestone()
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * acceleration)
		if is_on_floor():
			steps_taken += 1
			_check_step_milestone()
		play_movement_animation(velocity)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * deceleration)
		play_idle_animation()
	handle_wall_slide()
	if Input.is_action_just_pressed('dash') and direction and not is_dashing and dash_timer <= 0:
		if dash_unlocked:
			is_dashing = true
			dash_start_position = position.x
			play_dash_animation(Vector2(direction, 0))
			dash_direction = direction
			dash_timer = dash_cooldown
		else:
			print("Dash not unlocked yet!")
	if is_dashing:
		var current_distance = abs(position.x - dash_start_position)
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y =0
	if dash_timer > 0 :
		dash_timer -= delta
	move_and_slide()
	handle_wall_slide()
	if is_on_floor():
		can_wall_jump = true
	was_on_wall = is_on_wall()

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
		$dj.visible = true
		await get_tree().create_timer(2.0).timeout
		$dj.visible = false
		save_progress()

func save_progress():
	var save_data = {
		"steps_taken": steps_taken,
		"jumps_performed": jumps_performed,
		"speed_upgraded": speed_upgraded,
		"double_jump_unlocked": double_jump_unlocked,
		"dash_unlocked": dash_unlocked,
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
		speed_upgraded = save_data.get("speed_upgraded", false)
		double_jump_unlocked = save_data.get("double_jump_unlocked", false)
		dash_unlocked = save_data.get("dash_unlocked", false)
		if speed_upgraded:
			SPEED = UPGRADED_SPEED

func handle_wall_slide():
	var is_near_wall = is_on_wall()
	if is_near_wall and not is_on_floor() and velocity.y > 0:
		is_wall_sliding = true
		velocity.y = min(velocity.y, wall_slide_speed)
	else:
		is_wall_sliding = false

func play_movement_animation(velocity: Vector2):
	if velocity.x > 0:
		sprite.flip_h = false
		animation_player.play("right_walk")
	elif velocity.x < 0:
		sprite.flip_h = true
		animation_player.play("right_walk")

func play_idle_animation():
	animation_player.play("right_idle")

func play_dash_animation(velocity: Vector2):
	if velocity.x > 0:
		sprite.flip_h = false
		animation_player.play("right_walk")
	elif velocity.x < 0:
		sprite.flip_h = true
		animation_player.play("right_walk")

func play_jump_animation(velocity: Vector2):
	if velocity.x < 0:
		sprite.flip_h = true
		animation_player.play("right_jump")
	elif velocity.x > 0:
		sprite.flip_h = false
		animation_player.play("right_jump")

func unlock_dash():
	if not dash_unlocked:
		dash_unlocked = true
		print("Dash unlocked!")
		save_progress()
	else:
		print("Dash already unlocked.")
