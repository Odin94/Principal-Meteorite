extends Node2D

onready var pause_timer = $PauseTimer

func _on_Area2D_body_entered(body: Node2D):
    print(body.name)
    if body.name == "Player":
        body.jump_count_max += 1
        print("Found jump upgrade!")
        pause_timer.start()
        pause_timer.pause_mode
        get_tree().paused = true




func _on_PauseTimer_timeout():
    print("timeout")
    get_tree().paused = false
    queue_free()
