extends Node2D

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
onready var camera: Camera2D = player.get_node("Camera2D")
var door_closed = false

func _process(_delta):
	if not door_closed and (player.position.x > 810 or player.position.y < 1020):
		$BoneDoor.move_down()
		door_closed = true

func _on_Virus_death():
	# TODO
	# Short heavy shake after boss death
	camera.isShaking = true
	# Spawn explosions everywhere

	# Set self-destruct-enabled var in Globals
	Globals.is_self_destructing = true
	pass
