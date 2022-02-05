extends Node2D

func _ready():
    if Globals.collected_beam_powerups.has(self.name):
        queue_free()

func _on_Area2D_body_entered(body: Node2D):
    if body.name == "Player":
        body.get_fire_beam_upgrade()
        print("Found Fire Beam upgrade!")
        $PauseTimer.start()
        $PickUpSound.play()
        $PickUpText.visible = true
        get_tree().paused = true
        Globals.collected_beam_powerups.append(self.name)

func _on_PauseTimer_timeout():
    get_tree().paused = false
    queue_free()
