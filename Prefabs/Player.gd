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
var touched_ground_recently = true
var jump_was_pressed = false

var bullet_lifespan = 0.2

var in_hit_recovery = false

func _physics_process(_delta):
    if $MinHitRecoveryTimer.is_stopped() and is_on_floor():
        in_hit_recovery = false
        set_modulate(Color(1, 1, 1, 1))
    
    if not in_hit_recovery:
        process_input()

    velocity.y += gravity
        
    # returns lowered y-velocity when colliding with floor, applies moving platform speed etc
    # Needs UP to know which way is up and which way is the floor (for eg. is_on_floor())
    velocity = move_and_slide(velocity, Vector2.UP) 

    velocity.x = lerp(velocity.x, 0, 0.25)  # lerp = linear interpolation  # weight can be constant because _physics_process delta is constant

func process_input():
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
        limit_floorless_jump_time()
    
    if is_on_floor():
        touched_ground_recently = true
        air_jump_count = air_jump_count_max
        if jump_was_pressed:
            jump()

    if Input.is_action_just_pressed("jump"):
        jump_was_pressed = true
        remember_jump_press()
        if (touched_ground_recently or air_jump_count > 0):
            jump()
    
    if Input.is_action_pressed("shoot"):
        shoot()


func shoot():
    if shooting_cooldown.is_stopped():
        $ShotSound.play()
        var bullet = Bullet.instance()
        owner.add_child(bullet)
        bullet.transform = global_transform
        
        var bullet_offset = $AnimatedSprite.frames.get_frame("idle", 0).get_width() * 0.9
        bullet.position.x += bullet_offset if direction == 1 else -bullet_offset
        
        bullet.set_direction(Vector2(direction, 0))
        bullet.limit_lifespan(bullet_lifespan)        
        
        shooting_cooldown.start()  # Timer node has Wait Time & One Shot to run only once for a certain time


func limit_floorless_jump_time():
    # Coyote jump
    yield(get_tree().create_timer(.1), "timeout")
    touched_ground_recently = false


func remember_jump_press():
    yield(get_tree().create_timer(.15), "timeout")
    jump_was_pressed = false
    
    
func jump():
    velocity.y = jump_force
    if !touched_ground_recently:
        air_jump_count -= 1
    touched_ground_recently = false
    $JumpSound.play()
    
    
func get_hurt(var source_x):
    if not in_hit_recovery:
        set_modulate(Color(1, 0.3, 0.3, 0.3))
        velocity.y = jump_force * 0.5
        
        if position.x <= source_x:
            velocity.x = -800
        else:
            velocity.x = 800
        
        in_hit_recovery = true
        $MinHitRecoveryTimer.start()
        $HurtSound.play()
