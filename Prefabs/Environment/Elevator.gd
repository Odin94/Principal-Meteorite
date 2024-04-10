extends Node2D

export var target_position: Vector2
export var idle_position: Vector2 = self.position

var max_speed := 350
var current_speed := 0.0
var accel := 450

onready var from = idle_position
onready var to = idle_position


func _physics_process(delta):
	if (self.position.distance_to(to) > 20):
		current_speed = min(current_speed + (accel * delta), max_speed)
		
		var direction = self.position.direction_to(to)
		
		var velocity = direction * current_speed
		global_position += velocity * delta


func _on_StepOnArea_body_entered(body):
	if body.name == "Player":
		current_speed = 0
		to = target_position


func _on_StepOnArea_body_exited(body):
	if body.name == "Player":
		current_speed = 0
		to = idle_position
