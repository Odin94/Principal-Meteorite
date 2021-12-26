extends KinematicBody2D

var velocity := Vector2(0, 0)
const speed = 500
const gravity = 45
const jump_force = -1200

export var direction = -1
export var health = 50
export var damage = 20
export var trigger_distance = 500

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

func _ready():
    $AnimatedSprite.play("_idle")

func _physics_process(_delta):
    if health <= 0:
        return

    if $HitEffectTimeout.is_stopped():
        if is_on_floor():
            jump()
    
    if not is_on_floor():
        velocity.x = speed * direction
    else:
        velocity.x = 0
        $AnimatedSprite.play("_idle")
    
    velocity.y += gravity
    velocity = move_and_slide(velocity, Vector2.UP)


func jump():
    if $JumpingCooldown.is_stopped() and position.distance_to(player.position) < trigger_distance:  # and idle animation at last frame?
        var x_pos_delta = player.position.x - position.x
        var abs_pos_delta = abs(x_pos_delta)
        if abs_pos_delta == 0:
            abs_pos_delta += 1
        direction = x_pos_delta / abs_pos_delta
        
        if position.distance_to(player.position) < 180:
            velocity.y = jump_force / 2
        else:
            velocity.y = jump_force
        
        $AnimatedSprite.play("jumping")
        $JumpingCooldown.start()


func _on_DamageArea_body_entered(body: Node2D):
    if health <= 0:
        return

    if body.name == "Player":
        body.get_hurt(damage, position.x, true)


func _on_DamageArea_area_entered(area: Area2D):
    if area.name.validate_node_name().begins_with("Bullet"):
        get_hurt(area.damage)
        area.hit_enemy()


func get_hurt(incoming_damage: int):
    $HurtSound.play()
    set_modulate(Color(1, 0.3, 0.3, 0.3))
    velocity.x = 0
    $HitEffectTimeout.start(.1)
    health -= incoming_damage
    if health <= 0:
        die()


func _on_HitEffectTimeout_timeout():
    set_modulate(Color(1, 1, 1, 1))
    velocity.x = speed * direction

func die():
    $DeathSound.play()
    $AnimatedSprite.play("death")
    set_modulate(Color(1, 1, 1, 1))
    yield($AnimatedSprite, "animation_finished")
    queue_free()
