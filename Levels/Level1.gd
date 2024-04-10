extends Node2D

var Elevator := preload ("res://Prefabs/Environment/Elevator.tscn")

func _ready():
	if not Globals.background_music.is_playing():
		Globals.background_music.play()
	
	if Globals.is_self_destructing:
		var elevator = Elevator.instance()
		elevator.position = Vector2(320, 140)
		elevator.idle_position = elevator.position
		elevator.target_position = Vector2(320, -320)
		add_child(elevator)
