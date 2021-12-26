extends Node2D


var open = false


func _on_EnterDoorArea_body_entered(body: Node2D):
    if body.name == "Player" and open:
        #warning-ignore:return_value_discarded
        get_tree().reload_current_scene()


func _on_OpenDoorArea_area_entered(area: Area2D):
    if area.name == "Bullet" and not open:
        $AnimatedSprite.play("opening")
        $DoorBlocker.queue_free()
        open = true
