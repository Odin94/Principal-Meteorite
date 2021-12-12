extends Area2D


const speed = 20

var direction := Vector2(0, 0)  # TODO: What does := do?
var velocity := Vector2(0, 0)


func _physics_process(_delta):
    if direction != Vector2(0, 0):
        velocity = direction * speed
        
        global_position += velocity
        

func set_direction(new_direction: Vector2):
    self.direction = new_direction


func _on_Bullet_body_entered(body):
    if body is TileMap:
        queue_free()
