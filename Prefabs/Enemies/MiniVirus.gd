extends Area2D

export (PackedScene) var HealthDrop

var velocity := Vector2(0, 0)
var speed = 100

export var health = 40
export var damage = 10

var fully_spawned = false

var dead = false
onready var rng = RandomNumberGenerator.new()
onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

# Called when the node enters the scene tree for the first time.
func _ready():
	set_modulate(Color(0, 0, 0, 1))
	$SpawnInTimer.start()


func _physics_process(delta):
	if not fully_spawned:
		set_modulate(lerp(get_modulate(), Color(1, 1, 1, 1), 1.5 * delta))
		return

	if health <= 0:
		return

	var direction = self.position.direction_to(player.global_position)
	velocity = direction * speed

	global_position += velocity * delta


func _on_DamageArea_body_entered(body):
	if health <= 0 or not fully_spawned:
		return

	if body.name == "Player":
		body.get_hurt(damage, position.x, true)


func _on_DamageArea_area_entered(area):
	if not fully_spawned or dead:
		return

	if area.name.validate_node_name().begins_with("Bullet"):
		get_hurt(area.damage)
		area.hit_enemy()


func get_hurt(incoming_damage: int):
	$HurtSound.play()
	set_modulate(Color(1, 0.3, 0.3, 0.3))
	$HitEffectTimeout.start(.1)
	health -= incoming_damage
	
	if health <= 0:
		die()


func _on_HitEffectTimeout_timeout():
	set_modulate(Color(1, 1, 1, 1))


func die():
	if dead:
		return
	
	dead = true
	$DeathSound.play()
	$AnimatedSprite.play("death")
	self.scale = Vector2(1, 1)
	set_modulate(Color(1, 1, 1, 1))
	yield($AnimatedSprite, "animation_finished")
	
	if rng.randf_range(0, 10.0) > 8:
		var health_drop = HealthDrop.instance()
		owner.add_child(health_drop)
		health_drop.transform = global_transform
	
	queue_free()


func _on_SpawnInTimer_timeout():
	fully_spawned = true
	set_modulate(Color(1, 1, 1, 1))
