extends Node2D

func _ready():
	if not Globals.background_music.is_playing():
		Globals.background_music.play()
