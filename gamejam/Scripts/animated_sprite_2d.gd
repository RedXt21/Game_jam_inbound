extends AnimatedSprite2D

class_name animationController

const movementToIdle = {
	"right_walk": "right_idle",
	"left_walk": "left_idle",
}

func _ready() -> void:
	play("right_idle")

func play_movement_animation(velocity: Vector2):
	if velocity.x > 0:
		flip_h = false
		play("right_walk")
	elif velocity.x < 0:
		flip_h = true
		play("left_walk")

func play_idle_animation():
	if movementToIdle.keys().has(animation):
		play(movementToIdle[animation])
