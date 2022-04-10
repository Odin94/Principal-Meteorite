extends KinematicBody2D

export (PackedScene) var Bullet

onready var shooting_cooldown = $ShootingCooldown

var velocity := Vector2(0, 0)
const speed = 300
const gravity = 45
const max_falling_speed = 1500
const jump_force = -1200

var direction = 1

var air_jump_count_max = 1
var air_jump_count = air_jump_count_max
var touched_ground_recently = true
var jump_was_pressed = false
var bouncing = false

var bullet_lifespan = 0.2
var bullet_damage = 10
var bullet_color := Color(1, 1, 1)

var in_hit_recovery = false
var invincibility_time = 0.3

var max_health = 99
var health = 99

var dead = false

signal health_changed

func _ready():
    direction = Globals.player_direction
    $AnimatedSprite.flip_h = direction == -1
    
    init_upgrades()
    
    # make sure spawn_point has the right group
    for sp in get_tree().get_nodes_in_group("spawn_point"):
        if sp.name == (Globals.coming_from_door + "-spawn_point"):
            global_position = sp.global_position
            break

func _physics_process(_delta):
    if (dead):
        return
    
    if $MinHitRecoveryTimer.is_stopped() and is_on_floor():
        in_hit_recovery = false
        set_modulate(Color(1, 1, 1, 1))
        
    if not in_hit_recovery:
        process_input()

    velocity.y += gravity
    if velocity.y > max_falling_speed:
        velocity.y = max_falling_speed
    
    # returns lowered y-velocity when colliding with floor, applies moving platform speed etc
    # Needs UP to know which way is up and which way is the floor (for eg. is_on_floor())
    velocity = move_and_slide(velocity, Vector2.UP) 

    velocity.x = lerp(velocity.x, 0, 0.25)  # lerp = linear interpolation  # weight can be constant because _physics_process delta is constant


func process_input():
    if (dead):
        return

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
        $AnimatedSprite.play("_idle")
        
    if not is_on_floor():
        $AnimatedSprite.play("jumping")
        if not Input.is_action_pressed("jump") and velocity.y < 0 and not bouncing:
            velocity.y = 0
        limit_floorless_jump_time()
    
    if is_on_floor() :
        if $BounceTimer.is_stopped():
            touched_ground_recently = true
            bouncing = false
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
        
        var bullet_offset = $AnimatedSprite.frames.get_frame("_idle", 0).get_width() * 0.9
        bullet.position.x += bullet_offset if direction == 1 else -bullet_offset
        
        bullet.set_damage(bullet_damage)
        bullet.set_direction(Vector2(direction, 0))
        bullet.limit_lifespan(bullet_lifespan)
        bullet.modulate = bullet_color
        
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


func bounce(bounce_force: int):
    $BounceTimer.start()
    bouncing = true
    velocity.y = bounce_force
    air_jump_count = 0
    touched_ground_recently = false


func get_hurt(damage: int, source_x: float = position.x, trigger_hit_recovery: bool = true):
    if (dead):
        return

    if $InvincibilityTimer.is_stopped():
        health -= damage
        emit_signal("health_changed", health, max_health)
        if health <= 0:
            die()

        set_modulate(Color(1, 0.3, 0.3, 0.3))
        $HurtSound.play()
        $InvincibilityTimer.start(invincibility_time)

        if trigger_hit_recovery:
            velocity.y = jump_force * 0.5
            if position.x <= source_x:
                velocity.x = -1200
            else:
                velocity.x = 1200

            in_hit_recovery = true
            $MinHitRecoveryTimer.start()

        else:
            $MinHitRecoveryTimer.start(invincibility_time / 2)


func die():
    dead = true
    $AnimatedSprite.play("death")
    $DeathSound.play()
    yield(get_tree().create_timer(5), "timeout")
    get_tree().change_scene("res://Levels/TitleScreen.tscn")


func get_health_upgrade():
    max_health += 99
    health = max_health
    emit_signal("health_changed", health, max_health)
    
    
func get_fire_beam_upgrade():
    bullet_lifespan = .6
    bullet_damage = 15
    bullet_color = Color(1, .7, .7)


func get_health_pickup(heal_amount: int):
    health = min(health + heal_amount, max_health)
    emit_signal("health_changed", health, max_health)
    

func save_stats():
    Globals.player_health = health


func init_upgrades():
    for upgrade in Globals.collected_health_powerups:
        max_health += 99
    
    for upgrade in Globals.collected_jump_powerups:
        air_jump_count_max += 1
        
    if Globals.collected_beam_powerups.has("FireBeamUpgrade"):
        get_fire_beam_upgrade()
    
    health = Globals.player_health
    
    yield(get_tree().create_timer(.01), "timeout")  # need to delay signal because otherwise HUD may not be initialized yet
    emit_signal("health_changed", health, max_health)
