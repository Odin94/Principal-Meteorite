extends KinematicBody2D

export (PackedScene) var HealthDrop

var velocity := Vector2(0, 0)
const speed = 100
const gravity = 45

onready var rng = RandomNumberGenerator.new()

export var direction = -1
export var detects_cliffs = true
export var health = 30
export var damage = 10

var dead = false


func _ready():
	if direction == 1:
		$AnimatedSprite.flip_h = true
	$FloorChecker.position.x += $CollisionShape2D.shape.get_extents().x * direction
	$AnimatedSprite.play("walking")
	$FloorChecker.enabled = detects_cliffs
	
	rng.randomize()

func _physics_process(_delta):
	if dead:
		return
	
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
	if dead:
		return

	if body.name == "Player":
		body.get_hurt(damage, position.x, true)


func _on_DamageArea_area_entered(area: Area2D):
	if dead:
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
	if health <= 0:
		die()


func _on_HitEffectTimeout_timeout():
	set_modulate(Color(1, 1, 1, 1))
	velocity.x = speed * direction

func die():
	if dead:
		return
	
	dead = true
	$DeathSound.play()
	$AnimatedSprite.play("death")
	set_modulate(Color(1, 1, 1, 1))
	yield($AnimatedSprite, "animation_finished")
	
	if rng.randf_range(0, 10.0) > 8:
		var health_drop = HealthDrop.instance()
		owner.add_child(health_drop)
		health_drop.transform = global_transform
	
	queue_free()
