extends Node2D

export var speed = 50

onready var open_y := position.y
onready var closed_y: float = position.y + $Sprite.texture.get_height() * $Sprite.scale.y * 2

onready var move_to = Vector2(position.x, open_y)

func _ready():
	pass


func _physics_process(delta):
	if position.distance_to(move_to) != 0:
		position = position.move_toward(move_to, delta * speed)


func move_down():
	move_to = Vector2(position.x, closed_y)


func move_up():
	move_to = Vector2(position.x, open_y)
