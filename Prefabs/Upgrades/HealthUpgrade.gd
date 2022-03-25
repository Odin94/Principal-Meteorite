extends Node2D

const min_scale = 1
const max_scale = 1.3
var target_scale = max_scale

func _ready():
    if Globals.collected_health_powerups.has(self.name):
        queue_free()

func _physics_process(_delta):
    $Area2D/Sprite.scale.x = lerp($Area2D/Sprite.scale.x, target_scale, .03)
    $Area2D/Sprite.scale.y = lerp($Area2D/Sprite.scale.y, target_scale, .03)
    if $Area2D/Sprite.scale.x >= (max_scale - 0.05):
        target_scale = min_scale
    elif $Area2D/Sprite.scale.x <= (min_scale + 0.05):
        target_scale = max_scale

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
