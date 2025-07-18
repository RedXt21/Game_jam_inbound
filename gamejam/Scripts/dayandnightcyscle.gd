extends CanvasModulate

class_name DayandNight

@export var gradient: GradientTexture1D

var time: float = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	var value = (sin(time - PI / 2) + 1.0) / 2.0
	
