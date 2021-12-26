extends Node2D


var open = false

export(String, FILE, "*.tscn") var next_level = "res://Levels/Level1.tscn"

func _on_EnterDoorArea_body_entered(body: Node2D):
    if body.name == "Player" and open:
        #warning-ignore:return_value_discarded
        get_tree().change_scene(next_level)


func _on_OpenDoorArea_area_entered(area: Area2D):
    if area.name == "Bullet" and not open:
        $AnimatedSprite.play("opening")
        $DoorBlocker.queue_free()
        open = true
