extends Node2D

export var lifetime := 100
export var speed := 5
export var direction := Vector2(0, 1)


var current_lifetime := 0
var damage := 20
var velocity := Vector2(0, 0)


func _physics_process(delta: float):
	current_lifetime += delta
	if current_lifetime > lifetime:
		queue_free()
		
	if direction != Vector2(0, 0):
		velocity = direction * speed
		global_position += velocity


func _on_Giardia_body_entered(body):
	if body.name == "Player":
		$ImpactSound.play()
		body.get_hurt(damage, position.x, true)
