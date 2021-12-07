extends Area2D


const speed = 20

var direction := Vector2(0, 0)  # TODO: What does := do?
var velocity = Vector2(0, 0)


func _physics_process(delta):
    if direction != Vector2(0, 0):
        velocity = direction * speed
        
        global_position += velocity
        

func set_direction(direction):
    self.direction = direction
