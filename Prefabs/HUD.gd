extends CanvasLayer

const full_health_rect_color = Color(0.427451, 0.054902, 0.054902)
const empty_health_rect_color = Color(0, 0, 0)

func _ready():
    $HP.text = String(99)


# requires player in scene to emit health_changed linked to HUD node
func _on_Player_health_changed(health: int, max_health: int):
    re_draw_health_boxes(health, max_health)
        
    while (health > 99):
          health -= 99
    $HP.text = String(health)


func re_draw_health_boxes(health: int, max_health: int):
    for i in range(1, 2):
        var health_rect = get_node("HPRect" + str(i))
    
        health_rect.visible = false
        health_rect.color = empty_health_rect_color

        #warning-ignore:integer_division        
        if (health / 99 > 0):
            health_rect.color = full_health_rect_color
            health /= 99

        #warning-ignore:integer_division        
        if (max_health / 99 > 0):
            health_rect.visible = true
            max_health /= 99
