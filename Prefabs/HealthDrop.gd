extends Node2D

const min_scale_adder = 0
const max_scale_adder = 0.2
const scaling_speed = .06
const heal_amount = 10

onready var max_scale = $Sprite.scale.x + max_scale_adder
onready var min_scale = $Sprite.scale.x + min_scale_adder
onready var target_scale = max_scale

var active = true


func _physics_process(_delta):
    $Sprite.scale.x = lerp($Sprite.scale.x, target_scale, scaling_speed)
    $Sprite.scale.y = lerp($Sprite.scale.y, target_scale, scaling_speed)
    if $Sprite.scale.x >= (max_scale - 0.05):
        target_scale = min_scale
    elif $Sprite.scale.x <= (min_scale + 0.05):
        target_scale = max_scale


func _on_HealthDrop_body_entered(body: Node2D):
    if not active:
        return
        
    if body.name == "Player":
        body.get_health_pickup(heal_amount)

    active = false
    queue_free()
