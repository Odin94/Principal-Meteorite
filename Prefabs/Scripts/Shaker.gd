# Noise-based shaker, inspired by https://github.com/theshaggydev/the-shaggy-dev-projects/blob/main/projects/godot-3/screen-shake/sample_scene.gd

class_name Shaker extends Node

# How fast the shake changes direction
var _shake_speed
# How far the shake moves
var _shake_strength
# Multiplier for lerping the shake strength to zero
var _shake_decay_rate


var noise = OpenSimplexNoise.new()
# Used to keep track of where we are in the noise
# so that we can smoothly move through it
var noise_i: float = 0.0
var rand = RandomNumberGenerator.new()


func get_shake_offset(delta: float) -> Vector2:
	# Fade out the intensity over time
	_shake_strength = lerp(_shake_strength, 0, _shake_decay_rate * delta)
	
	var shake_offset = calculate_offset(delta, _shake_speed, _shake_strength)
	return shake_offset


func _init(shake_speed: float = 30.0, shake_strength: float = 60.0, shake_decay_rate: float = 3.0) -> void:
	rand.randomize()
	
	noise.seed = rand.randi()
	# Period affects how quickly the noise changes values
	noise.period = 2
	
	_shake_speed = shake_speed
	_shake_strength = shake_strength
	_shake_decay_rate = shake_decay_rate


func calculate_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, noise_i) * strength,
		noise.get_noise_2d(100, noise_i) * strength
	)


func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-_shake_strength, _shake_strength),
		rand.randf_range(-_shake_strength, _shake_strength)
	)
