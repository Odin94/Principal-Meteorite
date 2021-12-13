extends Area2D

export var triggers_hit_recovery := false
export var damage := 10

var body_to_hurt = null

func _physics_process(_delta):
    if body_to_hurt != null:
        body_to_hurt.get_hurt(position.x, triggers_hit_recovery)

func _on_DamagingArea_body_entered(body: Node2D):
    if body.name == "Player":
        body_to_hurt = body


func _on_DamagingArea_body_exited(body: Node2D):
    if body.name == "Player":
        body_to_hurt = null
