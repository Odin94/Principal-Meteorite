extends Area2D

var velocity := Vector2(0, 0)
var speed = 100

export var direction = -1
export var health = 400
export var damage = 25

const phase_1_health_cutoff = 250
const phase_2_health_cutoff = 125

var bullet_lifespan = 1

var phase = 0

var stop_floating = false

# Pre-Boss room: Have some small virus dudes scatter away on the side

# Bossfight idea:
# At start, have bones slam down to block the door
# Virus wakes up when you shoot it
# Virus charges around arena in some cool pattern that requires some skill to dodge
# At the end of each phase, go to center, close eye, become invul and trigger an effect - reactivate after x time or if effect is defeated
# After first phase - spawn mini clones of itself for the player to fight (they float up down for a bit and then charge left-right)
# After second phase - make fireballs rain from the sky, maybe also left-right?
# After third phase - spawn minis + fireballs + make boss keep moving

# After boss dies, shake screen & start self-destruct timer


func _ready():
	if direction == 1:
		$AnimatedSprite.flip_h = true
	$AnimatedSprite.play("Closed_eye")
	float_up_down(0)


func _physics_process(delta):
	if health <= 0:
		return
		
	if phase == 1:
		process_phase_1()
	elif phase == 2:
		process_phase_2()
	elif phase == 3:
		process_phase_3()

	global_position += velocity * delta

func float_up_down(floating_phase, float_velocity = 10, direction_change_timeout = 1.5):
	if stop_floating:
		velocity.y = 0
		stop_floating = false
		return

	velocity.y = float_velocity
	$UpDownChangeTimer.start(direction_change_timeout); yield($UpDownChangeTimer, "timeout")

	if phase == floating_phase:
		float_up_down(floating_phase, -float_velocity, direction_change_timeout)

func process_phase_1():
	var phase_one_y_positions = [880, 1200, 1400]
	
	if velocity.x > 0 and position.x > 2600:
		position.y = phase_one_y_positions[randi() % phase_one_y_positions.size()]
		velocity.x *= -1
	elif velocity.x < 0 and position.x < -200:
		position.y = phase_one_y_positions[randi() % phase_one_y_positions.size()]
		velocity.x *= -1


func process_phase_2():
	pass
	
	
func process_phase_3():
	pass
	

func enter_phase_1():
	if phase >= 1:
		return
	$AnimatedSprite.play("Opening_eye")
	yield($AnimatedSprite, "animation_finished")
	$AnimatedSprite.play("default")
	velocity.y = 0	
	stop_floating = true
	yield(get_tree().create_timer(1.5), "timeout")
	velocity = Vector2(0, -1000)
	yield(get_tree().create_timer(.5), "timeout")	
	phase = 1
	velocity = Vector2(1000, 0)


func enter_phase_2():
	if phase >= 2:
		return
	phase = 2


func enter_phase_3():
	if phase >= 3:
		return
	phase = 3


func _on_DamageArea_body_entered(body):
	if health <= 0 or phase == 0:
		return

	if body.name == "Player":
		body.get_hurt(damage, position.x, true)


func _on_DamageArea_area_entered(area):
	if area.name.validate_node_name().begins_with("Bullet"):
		if phase == 0:
		   enter_phase_1()
		else:
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


func die():
	$DeathSound.play()
	# TODO: Play cool death animation stuff
	set_modulate(Color(1, 1, 1, 1))
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	emit_signal("death")












