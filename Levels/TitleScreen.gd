extends Control


func _ready():
	$VBoxContainer/Start.grab_focus()


func _on_Start_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Levels/Level0_intro.tscn")


func _on_Load_pressed():
	Globals.load()


func _on_Exit_pressed():
	get_tree().quit()


func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.play()
