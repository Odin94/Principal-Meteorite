extends KinematicBody2D

export (PackedScene) var Bullet

onready var shooting_cooldown = $ShootingCooldown

var velocity = Vector2(0, 0)
const speed = 360
const gravity = 45
const jump_force = -900

var direction = 1

func _physics_process(delta):
    if Input.is_action_pressed("right"):
        velocity.x = speed
        direction = 1
        $Sprite.play("running")
        $Sprite.flip_h = false
    elif Input.is_action_pressed("left"):
        velocity.x = -speed
        direction = -1
        $Sprite.play("running")
        $Sprite.flip_h = true
    else:
        $Sprite.play("idle")
        
    if not is_on_floor():
        $Sprite.play("jumping")

    velocity.y += gravity

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_force

    # returns lowered y-velocity when colliding with floor, applies moving platform speed etc
    # Needs UP to know which way is up and which way is the floor (for eg. is_on_floor())
    velocity = move_and_slide(velocity, Vector2.UP) 

    velocity.x = lerp(velocity.x, 0, 0.25)  # lerp = linear interpolation  # weight can be constant because _physics_process delta is constant
    
    if Input.is_action_pressed("shoot"):
        shoot()

func shoot():
    if shooting_cooldown.is_stopped():
        var bullet = Bullet.instance()
        owner.add_child(bullet)
        bullet.transform = global_transform
        bullet.set_direction(Vector2(direction, 0))
        
        shooting_cooldown.start()  # Timer node has Wait Time & One Shot to run only once for a certain time
