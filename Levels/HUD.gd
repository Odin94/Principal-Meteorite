extends CanvasLayer


func _ready():
    $HP.text = String(99)


func _on_Player_health_changed(health: int):
    $HP.text = String(health)
