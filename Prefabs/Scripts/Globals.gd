extends Node

var Explosion := preload ("res://Prefabs/Environment/Explosion.tscn")

const save_path = "user://savegame.save"

var coming_from_door = ""

var player_direction = 1
onready var rng = RandomNumberGenerator.new()

var collected_health_powerups: Array = []
var collected_jump_powerups: Array = []
var collected_beam_powerups: Array = []
var player_health = 99

# TODO: In Globals, show countdown timer 
onready var self_destruct_shaker := Shaker.new(100.0, 10.0, 0)
var player: KinematicBody2D
var camera: Camera2D
var is_self_destructing := false
var explosion_interval := 0.25
var explosion_interval_counter := 0.0

func _physics_process(delta):
	if !is_instance_valid(camera):
		player = get_tree().get_nodes_in_group("Player").front()
		if is_instance_valid(player):
			camera = player.get_node("Camera2D")
	
	if is_self_destructing and is_instance_valid(camera):
		var shake_offset = self_destruct_shaker.get_shake_offset(delta)
		camera.offset = shake_offset
		explosion_interval_counter += delta
		if explosion_interval_counter > explosion_interval:
			explosion_interval = rng.randf_range(0.1, 0.5)
			explosion_interval_counter = 0
			var explosion = Explosion.instance()
			add_child(explosion)
			explosion.z_index = 2
			explosion.position = Vector2(player.position.x - rng.randi_range( - 500, 500), player.position.y - rng.randi_range( - 500, 500))

func _ready():
	rng.randomize()
	OS.set_window_position(OS.get_screen_position(OS.get_current_screen()) + OS.get_screen_size() * 0.5 - OS.get_window_size() * 0.5)

func save():
	var save_game = File.new()
	save_game.open(save_path, File.WRITE)
	
	var save_data = {
		"is_self_destructing": is_self_destructing,
		"collected_health_powerups": collected_health_powerups,
		"collected_jump_powerups": collected_jump_powerups,
		"collected_beam_powerups": collected_beam_powerups,
		"player_health": player_health,
		"player_direction": player_direction,
		"coming_from_door": coming_from_door,
		"current_level": "res://Levels/" + get_tree().get_current_scene().get_name() + ".tscn" # careful: This takes the name of the root node, but needs name of the scene to load! The function name is wrong!
	   }
	save_game.store_line(to_json(save_data))
	
func load():
	var save_game = File.new()
	if not save_game.file_exists(save_path):
		push_error("save file not found")
		return
		
	save_game.open(save_path, File.READ)
	var save_data = parse_json(save_game.get_line())

	is_self_destructing = save_data.get("is_self_destructing", false)
	collected_health_powerups = save_data.get("collected_health_powerups")
	collected_jump_powerups = save_data.get("collected_jump_powerups")
	collected_beam_powerups = save_data.get("collected_beam_powerups")
	player_health = save_data.get("player_health")
	player_direction = save_data.get("player_direction")
	coming_from_door = save_data.get("coming_from_door")
	var level_to_load = save_data.get("current_level")
	
	#var root = get_tree().get_root()
	#var current_scene = root.get_child(root.get_child_count() - 1)
	#current_scene.free()
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene(level_to_load)
