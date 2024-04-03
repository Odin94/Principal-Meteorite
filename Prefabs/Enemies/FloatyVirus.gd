extends Area2D

var velocity := Vector2(0, 0)
export var health = 40

var triggered = false
var fully_spawned = false

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
var rng = RandomNumberGenerator.new()

var speed = rng.randf_range(50, 300.0)
var frequency = rng.randf_range(3, 5.0)
var amplitude = rng.randf_range(0.25, 1.5)

var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Globals.is_self_destructing:
		set_modulate(Color(0, 0, 0, 1))
		$SpawnInTimer.wait_time = rng.randf_range(0.5, 2.5)
		$SpawnSound.pitch_scale = rng.randf_range(0.8, 1.2)


func _physics_process(delta):
	if self.position.distance_to(player.global_position) < 250 and !triggered:
		triggered = true
		$SpawnInTimer.start()
		$SpawnSound.play()
	if !triggered:
		return
		
	if not fully_spawned:
		set_modulate(lerp(get_modulate(), Color(1, 1, 1, 1), 1.5 * delta))
		return

	if health <= 0:
		return

	time += delta
	var direction = Vector2(1, cos(time * frequency) * amplitude)
	velocity = direction * speed

	global_position += velocity * delta


func _on_SpawnInTimer_timeout():
	fully_spawned = true
	set_modulate(Color(1, 1, 1, 1))
