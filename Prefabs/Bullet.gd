extends KinematicBody2D


const speed = 15

var direction := Vector2(0, 0)
var velocity := Vector2(0, 0)


func _physics_process(_delta):
    if direction != Vector2(0, 0):
        velocity = direction * speed
        
        global_position += velocity
    
    
func set_direction(new_direction: Vector2):
    self.direction = new_direction


func limit_lifespan(lifespan: float):
    $Lifespan.wait_time = lifespan
    $Lifespan.start()


func _on_Bullet_body_entered(body):
    if body is TileMap:
      queue_free()


func _on_Lifespan_timeout():
    queue_free()
    
    
func hit_enemy():
    queue_free()
