extends KinematicBody2D

var velocity := Vector2(0, 0)
const speed = 100
const gravity = 45
const jump_force = -900

export var direction = -1

func _ready():
    if direction == 1:
        $AnimatedSprite.flip_h = true
    $FloorChecker.position.x += $CollisionShape2D.shape.radius * direction
    $AnimatedSprite.play("walking")

func _physics_process(_delta):
    if is_on_floor() and (is_on_wall() or not $FloorChecker.is_colliding()):
        change_direction()
    
    velocity.x = speed * direction
    
    velocity.y += gravity
    velocity = move_and_slide(velocity, Vector2.UP)


func change_direction():
    direction *= -1
    $FloorChecker.position.x += $CollisionShape2D.shape.radius * 2 * direction
    $AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
