extends Camera2D

export var isShaking = false
onready var self_destruct_shaker := Shaker.new(100.0, 30.0, 0)

func _physics_process(delta):
	if isShaking:
		# Shake, but stay on the player
		var shake_offset = self_destruct_shaker.get_shake_offset(delta)
		self.offset = shake_offset
