extends Node2D

var enabled = true

func _on_Area2D_body_entered(body):
    if body.name == "Player" and enabled:
        enabled = false
        Globals.save()
        $PauseTimer.start()
        $SaveSound.play()
        $SaveText.visible = true
        get_tree().paused = true


func _on_PauseTimer_timeout():
    get_tree().paused = false
    $SaveText.visible = false
