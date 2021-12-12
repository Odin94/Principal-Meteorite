extends KinematicBody2D

export (PackedScene) var Bullet

onready var shooting_cooldown = $ShootingCooldown

var velocity := Vector2(0, 0)
const speed = 360
const gravity = 45
const jump_force = -900

var direction = 1

var air_jump_count_max = 0
var air_jump_count = air_jump_count_max

func _physics_process(_delta):
    if Input.is_action_pressed("right"):
        velocity.x = speed
        direction = 1
        $AnimatedSprite.play("running")
        $AnimatedSprite.flip_h = false
    elif Input.is_action_pressed("left"):
        velocity.x = -speed
        direction = -1
        $AnimatedSprite.play("running")
        $AnimatedSprite.flip_h = true
    else:
        $AnimatedSprite.play("idle")
        
    if not is_on_floor():
        $AnimatedSprite.play("jumping")
        if not Input.is_action_pressed("jump") and velocity.y < 0:
            velocity.y = 0

    velocity.y += gravity
    
    if is_on_floor():
        air_jump_count = air_jump_count_max

    if Input.is_action_just_pressed("jump") and (is_on_floor() or air_jump_count > 0):
        velocity.y = jump_force
        if !is_on_floor():
            air_jump_count -= 1

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
        
        var bullet_offset = $AnimatedSprite.frames.get_frame("idle", 0).get_width() * 0.9
        bullet.position.x += bullet_offset if direction == 1 else -bullet_offset
        
        bullet.set_direction(Vector2(direction, 0))
        
        shooting_cooldown.start()  # Timer node has Wait Time & One Shot to run only once for a certain time
