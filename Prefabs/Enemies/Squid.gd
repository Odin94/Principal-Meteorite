extends KinematicBody2D

export (PackedScene) var SquidBullet

var velocity := Vector2(0, 0)
const speed = 100
var gravity = 0

export var direction = -1
export var health = 300
export var damage = 20

var bullet_lifespan = 1

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

func _ready():
    if direction == 1:
        $AnimatedSprite.flip_h = true
    $AnimatedSprite.play("sleeping")

func _physics_process(_delta):
    if health <= 0:
        return
        
    shoot()
    
    if $HitEffectTimeout.is_stopped():
        if is_on_wall():
            change_direction()
        velocity.x = speed * direction
    
    velocity = move_and_slide(velocity, Vector2.UP)


func shoot():
    if $ShootingCooldown.is_stopped():
        # $ShotSound.play()
        var bullet: Area2D = SquidBullet.instance()
        
        owner.add_child(bullet)
        bullet.transform = global_transform
        
        var bullet_offset = $AnimatedSprite.frames.get_frame("_idle", 0).get_width() * 0.9
        bullet.position.x += bullet_offset if direction == 1 else -bullet_offset
        
        bullet.set_damage(damage)
        bullet.set_direction(bullet.position.direction_to(player.global_position))
        bullet.limit_lifespan(bullet_lifespan)
        bullet.scale = Vector2(4, 4)
        
        $ShootingCooldown.start()


func change_direction():
    if $TurnAroundCooldown.is_stopped():
        direction *= -1
        
        $AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
        $TurnAroundCooldown.start()


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



