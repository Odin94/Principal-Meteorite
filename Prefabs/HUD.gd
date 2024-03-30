extends CanvasLayer

const full_health_rect_color = Color(0.427451, 0.054902, 0.054902)
const empty_health_rect_color = Color(0, 0, 0)

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player").front()

func _ready():
	if is_instance_valid(player):
		_on_Player_health_changed(player.health, player.max_health)
	else:
		$HP.text = String(99)

# requires player in scene to emit health_changed linked to HUD node
func _on_Player_health_changed(health: int, max_health: int):
	re_draw_health_boxes(health, max_health)
	
	while (health > 99):
		  health -= 99
	$HP.text = String(health)

func re_draw_health_boxes(health: int, max_health: int):
	for i in range(1, 9):
		var health_rect = get_node("HPRect"+ str(i))
	
		health_rect.visible = false
		health_rect.color = empty_health_rect_color

		#warning-ignore:integer_division
		if ((health - 1) / 99 > 0):
			health_rect.color = full_health_rect_color
			health -= 99

		#warning-ignore:integer_division
		if ((max_health - 1) / 99 > 0):
			health_rect.visible = true
			max_health -= 99
