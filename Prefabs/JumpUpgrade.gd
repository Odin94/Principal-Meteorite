extends Node2D


func _on_Area2D_body_entered(body: Node2D):
    print(body.name)
    if body.name == "Player":
        body.air_jump_count_max += 1
        print("Found jump upgrade!")
        $PauseTimer.start()
        $PickUpSound.play()
        get_tree().paused = true

func _on_PauseTimer_timeout():
    print("timeout")
    get_tree().paused = false
    queue_free()
