extends Area2D

export(PackedScene) var MiniVirus
export(PackedScene) var Giardia

signal death

var velocity := Vector2(0, 0)
var speed := 500

var move_to = null

export var direction := - 1
export var health := 400
export var damage := 25
export var center := Vector2(1200, 880)

const phase_1_health_cutoff := 220
const phase_2_health_cutoff := 125

var phase_2_all_minis_spawned := false

var bullet_lifespan := 1

var phase := 0

var stop_floating := false
onready var rng := RandomNumberGenerator.new()

onready var phase_3_shaker := Shaker.new(100.0, 15.0, 0)
onready var phase_4_shaker := Shaker.new(100.0, 15.0, 0)
var should_keep_spawning_giardia := false
var giardia_spawn_delay := 0.075

var p4_pos_i := 0
var phase_4_positions := [
	Vector2(810, 1000),
	Vector2(1600, 1300),
	Vector2(1600, 1000),
	Vector2(810, 1300),
]
var p4_is_left_right_bouncing := false
var p4_left_right_bouncing_index := 0
var p4_y_positions := [1400, 1200, 880]

var mini_viruses = []
var mini_virus_positions := [
	Vector2(625, 750),
	Vector2(1000, 700),
	Vector2(1500, 800),
	Vector2(750, 1400),
	Vector2(1200, 1125),
	Vector2(1550, 900),
	Vector2(1650, 1350),
	Vector2(900, 1250),
	Vector2(1000, 1000),
]

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
	if Globals.is_self_destructing:
		queue_free()
	else:
		randomize()
		rng.randomize()
		if direction == 1:
			$AnimatedSprite.flip_h = true
		$AnimatedSprite.play("Closed_eye")
		float_up_down(0)

func _physics_process(delta: float):
	if health <= 0:
		return
		
	if phase == 1:
		process_phase_1()
	elif phase == 2:
		process_phase_2()
	elif phase == 3:
		process_phase_3(delta)
	elif phase == 4:
		process_phase_4(delta)
	
	if move_to:
		position = position.move_toward(move_to, delta * speed)
		if position.distance_to(move_to) == 0:
			move_to = null
	else:
		global_position += velocity * delta
	
	if $AnimatedSprite.animation == "Closing_eye":
		set_modulate(lerp(get_modulate(), Color(0.5, 0.5, 0.5, 1), 1 * delta))
	elif $AnimatedSprite.animation == "Opening_eye":
		set_modulate(lerp(get_modulate(), Color(1, 1, 1, 1), 1 * delta))

func float_up_down(floating_phase, float_velocity=10, direction_change_timeout=1.5):
	if stop_floating:
		velocity.y = 0
		stop_floating = false
		return

	velocity.y = float_velocity
	$UpDownChangeTimer.start(direction_change_timeout); yield ($UpDownChangeTimer, "timeout")

	if phase == floating_phase:
		float_up_down(floating_phase, -float_velocity, direction_change_timeout)

func enter_phase_1():
	if phase >= 1 or $AnimatedSprite.animation != "Closed_eye":
		return
	
	$AnimatedSprite.play("Opening_eye")
	yield ($AnimatedSprite, "animation_finished")
	$AnimatedSprite.play("default")
	velocity.y = 0
	stop_floating = true
	yield (get_tree().create_timer(1.5), "timeout")
	velocity = Vector2(0, -1000)
	yield (get_tree().create_timer(.5), "timeout")
	phase = 1
	velocity = Vector2(1200, 0)

var p1_position_i = 0
func process_phase_1():
	var phase_one_y_positions := [880, 1200, 1400]
	
	if velocity.x > 0 and position.x > 2600:
		position.y = phase_one_y_positions[p1_position_i]
		velocity.x *= - 1
		p1_position_i += 1
		p1_position_i %= phase_one_y_positions.size()
	elif velocity.x < 0 and position.x < - 200:
		position.y = phase_one_y_positions[p1_position_i]
		velocity.x *= - 1
		p1_position_i += 1
		p1_position_i %= phase_one_y_positions.size()

func enter_phase_2():
	if phase >= 2:
		return
	phase = 2

	move_to = center
	velocity = Vector2(0, 0)
	# Wait to move to center
	yield (get_tree().create_timer(1.5), "timeout")
	$AnimatedSprite.play("Closing_eye")
	yield ($AnimatedSprite, "animation_finished")

	randomize()

	spawn_minis(0.4, 0.8)

	yield (get_tree().create_timer(10), "timeout")
	spawn_minis(1, 2)
	phase_2_all_minis_spawned = true
	# Automatically move to next phase after some time even if not all minis are killed
	# TODO: This could break enter_phase_3 (double stuff) if unfortunately timed maybe
	yield (get_tree().create_timer(90), "timeout")
	if phase == 2:
		enter_phase_3()

func spawn_minis(min_time: float, max_time: float):
	mini_virus_positions.shuffle()
	for position in mini_virus_positions:
		var mini_virus = MiniVirus.instance()
		owner.add_child(mini_virus)
		mini_virus.position = position
		mini_viruses.append(mini_virus)
		yield (get_tree().create_timer(rng.randf_range(min_time, max_time)), "timeout")

func process_phase_2():
	var all_minis_dead = true
	for mini in mini_viruses:
		if is_instance_valid(mini):
			all_minis_dead = false
	
	if phase_2_all_minis_spawned and all_minis_dead:
		enter_phase_3()

func enter_phase_3():
	if phase >= 3:
		return
	phase = 3
	
	$AnimatedSprite.play("Opening_eye")
	yield ($AnimatedSprite, "animation_finished")
	$AnimatedSprite.play("default")
	
	giardia_spawn_delay = 0.075
	should_keep_spawning_giardia = true
	spawn_giardia()
	
	yield (get_tree().create_timer(20), "timeout")
	should_keep_spawning_giardia = false
	enter_phase_4()

func process_phase_3(delta: float):
	# Shake, but stay in the center
	var shake_offset = phase_3_shaker.get_shake_offset(delta)
	self.position += shake_offset
	self.position = position.move_toward(center, delta * 200)

func enter_phase_4():
	if phase >= 4:
		return
	phase = 4
	
	move_to = center
	velocity = Vector2(0, 0)
	# Wait to move to center
	yield (get_tree().create_timer(1.5), "timeout")
	$AnimatedSprite.play("Closing_eye")
	yield ($AnimatedSprite, "animation_finished")
	
	# start spawning giardia again
	giardia_spawn_delay = 0.6
	should_keep_spawning_giardia = true
	spawn_giardia()
	
	# start spawning adds	
	spawn_minis(5, 10)
	spawn_minis(5, 10)

func process_phase_4(delta: float):
	if p4_is_left_right_bouncing:
		if p4_left_right_bouncing_index == p4_y_positions.size():
			p4_is_left_right_bouncing = false
			velocity = Vector2(0, 0)

		if velocity.x > 0 and position.x > 2600:
			position.y = p4_y_positions[p4_left_right_bouncing_index]
			velocity.x *= - 1
			p4_left_right_bouncing_index += 1
		elif velocity.x < 0 and position.x < - 200:
			position.y = p4_y_positions[p4_left_right_bouncing_index]
			velocity.x *= - 1
			p4_left_right_bouncing_index += 1
	else:
		var p4_move_to = phase_4_positions[p4_pos_i]
		print("moving to", p4_move_to)
		print(position)
		self.position = position.move_toward(p4_move_to, delta * 2000)
		if abs(position.distance_to(p4_move_to)) < 50:
			var shake_offset = phase_4_shaker.get_shake_offset(delta)
			self.position += shake_offset
			self.position = position.move_toward(center, delta * 200)
			if $Phase4VibrateTimer.is_stopped():
				$Phase4VibrateTimer.start()

func spawn_giardia():
	var spawn_y = 200
	# random between 400 and 1600
	var spawn_x = randi() % 1201 + 400
	
	var giardia = Giardia.instance()
	owner.add_child(giardia)
	giardia.position = Vector2(spawn_x, spawn_y)
	yield (get_tree().create_timer(giardia_spawn_delay), "timeout")
	
	if should_keep_spawning_giardia:
		spawn_giardia()

func _on_DamageArea_body_entered(body):
	if health <= 0 or phase in [0, 2]:
		return

	if body.name == "Player":
		body.get_hurt(damage, position.x, true)

func _on_DamageArea_area_entered(area):
	if health <= 0:
		return
	if area.name.validate_node_name().begins_with("Bullet"):
		if phase == 0:
		   enter_phase_1()
		   area.hit_enemy()
		elif phase in [0, 2, 3]:
			return
		else:
			get_hurt(area.damage)
			area.hit_enemy()

func _on_HitEffectTimeout_timeout():
	set_modulate(Color(1, 1, 1, 1))

func get_hurt(incoming_damage: int):
	$HurtSound.play()
	set_modulate(Color(1, 0.3, 0.3, 0.3))
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
	$AnimatedSprite.scale = Vector2(9, 9)
	for mini in mini_viruses:
		if is_instance_valid(mini):
			mini.die()
	$DeathSound.play()
	yield ($AnimatedSprite, "animation_finished")
	$DeathSound.play()
	yield ($AnimatedSprite, "animation_finished")
	emit_signal("death")
	queue_free()

func _on_Phase4VibrateTimer_timeout():
	p4_pos_i += 1
	if p4_pos_i >= phase_4_positions.size():
		p4_pos_i = p4_pos_i % phase_4_positions.size()
		# Run off the screen and start bouncing left-right
		p4_is_left_right_bouncing = true
		p4_left_right_bouncing_index = 0
		velocity = Vector2(1000, 0)
