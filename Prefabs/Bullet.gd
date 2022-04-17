extends Area2D


const speed = 15

var direction := Vector2(0, 0)
var velocity := Vector2(0, 0)
var damage := 10

var impacting = false

func _physics_process(_delta):
    if not impacting:
        if direction != Vector2(0, 0):
            velocity = direction * speed
            
            global_position += velocity


func set_direction(new_direction: Vector2):
    self.direction = new_direction


func limit_lifespan(lifespan: float):
    $Lifespan.wait_time = lifespan
    $Lifespan.start()
    

func set_damage(new_damage: int):
    self.damage = new_damage


func _on_Bullet_body_entered(body: Node2D):
    if body is TileMap or body.name == "DoorBlocker" or body.name == "StaticBody2D":
        $ImpactSound.play()
        impact()


func _on_Lifespan_timeout():
    impact()
    
    
func hit_enemy():
    impact()
    

func impact():
    if not impacting:
        impacting = true
        $AnimatedSprite.play("impact")
        yield($AnimatedSprite, "animation_finished")
        queue_free()
