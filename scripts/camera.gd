extends Camera2D
class_name Camera

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_decay: float = 5.0
var shake_time: float = 0.0
var shake_time_speed: float = 20.0
var noise = FastNoiseLite.new()

func _physics_process(delta: float) -> void:
	if shake_duration > 0:
		shake_time += delta * shake_time_speed
		shake_duration -= delta
		
		offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity
		)
		
		shake_intensity = max(shake_intensity - shake_decay * delta, 0)
	else:
		# Resets camera offset
		offset = lerp(offset, Vector2.ZERO, 10.5 * delta)

func screen_shake(intensity: float = 6.0, duration: float = 0.5) -> void:
	noise.frequency = 2.0
	
	shake_intensity = intensity
	shake_duration = duration
	shake_time = 0 # Resets shake time before starts
