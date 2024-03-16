extends Node2D


onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
var door_closed = false

func _process(_delta):
	if not door_closed and (player.position.x > 810 or player.position.y < 1020):
		$BoneDoor.move_down()
		door_closed = true


func _on_Virus_death():
	pass # TODO: Start self-destruct
