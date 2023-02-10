extends Node2D

export(int) var targetX = 0
export(int) var targetY = 0

func _on_Area2D_body_entered(body: Node2D):
	if body.name == "Player":
		body.set_position(Vector2(targetX, targetY))

