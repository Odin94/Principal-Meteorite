extends KinematicBody2D

var velocity := Vector2(0, 0)
const speed = 100
var gravity = 0

export var direction = -1
export var health = 300
export var damage = 20


func _ready():
    if direction == 1:
        $AnimatedSprite.flip_h = true
    $FloorChecker.position.x += $CollisionShape2D.shape.get_extents().x * direction
    $AnimatedSprite.play("sleeping")

func _physics_process(_delta):
    if health <= 0:
        return
    
    if $HitEffectTimeout.is_stopped():
        if is_on_floor() and (is_on_wall() or not $FloorChecker.is_colliding()):  # TODO: change direction when hitting a wall? Or have a pre-determined route?
            change_direction()
        velocity.x = speed * direction
    
    velocity.y += gravity
    velocity = move_and_slide(velocity, Vector2.UP)


func change_direction():
    direction *= -1
    $FloorChecker.position.x += $CollisionShape2D.shape.get_extents().x * 2 * direction
    
    $AnimatedSprite.flip_h = !$AnimatedSprite.flip_h


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
    # TODO: Play cool death animation stuff
    set_modulate(Color(1, 1, 1, 1))
    yield($AnimatedSprite, "animation_finished")
    queue_free()
