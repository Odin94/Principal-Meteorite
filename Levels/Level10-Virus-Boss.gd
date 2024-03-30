extends Node2D

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player").front()
onready var camera: Camera2D = player.get_node("Camera2D")
var door_closed = false

func _process(_delta):
	if not door_closed and (player.position.x > 810 or player.position.y < 1020):
		$BoneDoor.move_down()
		door_closed = true
		
	if Globals.is_self_destructing:
		if player.position.x < 810:
			$BoneDoor.move_up()

func _on_Virus_death():
	# Short heavy shake after boss death
	camera.isShaking = true
	# TODO: spawn explosions everywhere

	# Set self-destruct-enabled var in Globals
	Globals.is_self_destructing = true

	yield (get_tree().create_timer(3), "timeout")
	$PauseTimer.start()
	$SelfDestructText.visible = true
	get_tree().paused = true

func _on_PauseTimer_timeout():
	get_tree().paused = false
	$SelfDestructText.visible = false
