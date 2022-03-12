extends Control


func _ready():
    $VBoxContainer/Start.grab_focus()


func _on_Start_pressed():
    get_tree().change_scene("res://Levels/Level1.tscn")


func _on_Load_pressed():
    pass # Replace with function body.


func _on_Exit_pressed():
    get_tree().quit()
