extends Node2D

func _ready():
    if Globals.collected_health_powerups.has(self.name):
        queue_free()

func _on_Area2D_body_entered(body: Node2D):
    if body.name == "Player":
        body.get_health_upgrade()
        print("Found health upgrade!")
        $PauseTimer.start()
        z_index = 5
        $PickUpSound.play()
        $PickUpText.visible = true
        get_tree().paused = true
        Globals.collected_health_powerups.append(self.name)

func _on_PauseTimer_timeout():
    get_tree().paused = false
    queue_free()
