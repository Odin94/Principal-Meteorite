extends KinematicBody2D

export (PackedScene) var SquidBullet

var velocity := Vector2(0, 0)
var speed = 100
var gravity = 0

export var direction = -1
export var health = 400
export var damage = 25

const phase_1_health_cutoff = 250
const phase_2_health_cutoff = 125

var bullet_lifespan = 1

var trigger_distance = 180
var phase = 0

signal death

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	if direction == 1:
		$AnimatedSprite.flip_h = true
	$AnimatedSprite.play("sleeping")
	float_up_down(0)


func _physics_process(_delta):
	if health <= 0:
		return
		
	if phase == 0:
		process_phase_0()
	if phase == 1:
		process_phase_1()
	elif phase == 2:
		process_phase_2()
	elif phase == 3:
		process_phase_3()

	if phase != 0:
		if $HitEffectTimeout.is_stopped():
			if is_on_wall():
				change_direction()
			velocity.x = speed * direction

	velocity = move_and_slide(velocity, Vector2.UP)


func float_up_down(floating_phase, float_velocity = 30, direction_change_timeout = 2):
	velocity.y = float_velocity
	$UpDownChangeTimer.start(direction_change_timeout); yield($UpDownChangeTimer, "timeout")
	if phase == floating_phase:
		float_up_down(floating_phase, -float_velocity, direction_change_timeout)

func process_phase_0():
	if position.distance_to(player.position) < trigger_distance and phase < 1:
		velocity = Vector2(0, 0)
		$AnimatedSprite.play("_idle")
		$ScreamSound.play()
		yield(get_tree().create_timer(2), "timeout")
		enter_phase_1()


func process_phase_1():
	shoot()


func process_phase_2():
	shoot(2)
	
func process_phase_3():
	shoot(8)
	
func enter_phase_1():
	if phase >= 1:
		return
	velocity.y = 0    
	phase = 1
	$AnimatedSprite.play("moving")
	velocity = Vector2(0, 0)


func enter_phase_2():
	if phase >= 2:
		return
	phase = 2
	velocity = Vector2(0, 0)
	speed = 200
	$ScreamSound.play()
	float_up_down(phase, 60, 4)


func enter_phase_3():
	if phase >= 3:
		return
	phase = 3
	velocity = Vector2(0, 0)
	speed = 300
	$ScreamSound.play()
	float_up_down(phase, 100, 3)


func shoot(bullet_count = 1):
	if $ShootingCooldown.is_stopped():
		$ShootingCooldown.start()
		spawn_bullet(bullet_count)


func spawn_bullet(total = 1, i = 1):
	var bullet = SquidBullet.instance()
	
	owner.add_child(bullet)
	$ShootSound.play()
	bullet.transform = global_transform
	
	var bullet_offset = $AnimatedSprite.frames.get_frame("_idle", 0).get_width() * 0.9
	bullet.position.x += bullet_offset if direction == 1 else -bullet_offset
	
	bullet.set_damage(damage)
	bullet.set_direction(bullet.position.direction_to(player.global_position))
	bullet.limit_lifespan(bullet_lifespan)
	bullet.scale = Vector2(4, 4)
	
	yield(get_tree().create_timer(.1), "timeout")
	if (i < total):
		spawn_bullet(total, i + 1)


func change_direction():
	if $TurnAroundCooldown.is_stopped():
		direction *= -1
		
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
		$TurnAroundCooldown.start()


func _on_DamageArea_body_entered(body: Node2D):
	if health <= 0 or phase == 0:
		return

	if body.name == "Player":
		body.get_hurt(damage, position.x, true)


func _on_DamageArea_area_entered(area: Area2D):
	if phase == 0 or health <= 0:
	   return
	 
	if area.name.validate_node_name().begins_with("Bullet"):
		get_hurt(area.damage)
		area.hit_enemy()


func get_hurt(incoming_damage: int):
	$HurtSound.play()
	set_modulate(Color(1, 0.3, 0.3, 0.3))
	velocity.x = 0
	$HitEffectTimeout.start(.1)
	health -= incoming_damage
	
	if health <= phase_1_health_cutoff:
		enter_phase_2()
	if health <= phase_2_health_cutoff:
		enter_phase_3()
	if health <= 0:
		die()


func _on_HitEffectTimeout_timeout():
	set_modulate(Color(1, 1, 1, 1))
	velocity.x = speed * direction


func die():
	$DeathSound.play()
	# TODO: Play cool death animation stuff
	set_modulate(Color(1, 1, 1, 1))
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	give_player_upgrades()
	emit_signal("death")
	
	
func give_player_upgrades():
	player.air_jump_count_max += 3
	Globals.collected_jump_powerups.append_array(["squidJump1", "squidJump2", "squidJump3"])
	$PauseTimer.start()
	$PickUpSound.play()
	$PickUpText.visible = true
	get_tree().paused = true


func _on_PauseTimer_timeout():
	get_tree().paused = false
	queue_free()
