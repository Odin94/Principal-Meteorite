extends KinematicBody2D

var velocity := Vector2(0, 0)
const speed = 100
const gravity = 45
const jump_force = -900

export var direction = -1
export var detects_cliffs = true


func _ready():
    if direction == 1:
        $AnimatedSprite.flip_h = true
    $FloorChecker.position.x += $CollisionShape2D.shape.get_extents().x * direction
    $AnimatedSprite.play("walking")
    $FloorChecker.enabled = detects_cliffs

func _physics_process(_delta):
    if $HitEffectTimeout.is_stopped():
        if is_on_floor() and (is_on_wall() or not $FloorChecker.is_colliding()):
            change_direction()
        velocity.x = speed * direction
    
    velocity.y += gravity
    velocity = move_and_slide(velocity, Vector2.UP)


func change_direction():
    if $TurnAroundCooldown.is_stopped():
        direction *= -1
        $FloorChecker.position.x += $CollisionShape2D.shape.get_extents().x * 2 * direction
        
        $AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
        $TurnAroundCooldown.start()


func _on_DamageArea_body_entered(body: Node2D):
    if body.name == "Player":
        body.get_hurt(position.x)
        
    if body.name == "Bullet":
        get_hurt()
        body.hit_enemy()
        
        
func get_hurt():
    set_modulate(Color(1, 0.3, 0.3, 0.3))
    velocity.x = 0
    $HitEffectTimeout.start(.1)
    

func _on_HitEffectTimeout_timeout():
    set_modulate(Color(1, 1, 1, 1))
    velocity.x = speed * direction
