extends Node2D

const min_height = -20
const max_height = 0
var target_height = min_height

func _ready():
	if Globals.collected_jump_powerups.has(self.name):
		queue_free()

func _physics_process(_delta):
	$Area2D/Sprite.position.y = lerp($Area2D/Sprite.position.y, target_height, .03)
	if $Area2D/Sprite.position.y >= (max_height - 0.5):
		target_height = min_height
	elif $Area2D/Sprite.position.y <= (min_height + 0.5):
		target_height = max_height

func _on_Area2D_body_entered(body: Node2D):
	if body.name == "Player":
		body.air_jump_count_max += 1
		$PauseTimer.start()
		$PickUpSound.play()
		$PickUpText.visible = true
		get_tree().paused = true
		Globals.collected_jump_powerups.append(self.name)

func _on_PauseTimer_timeout():
	get_tree().paused = false
	queue_free()

