extends Area2D

var velocity := Vector2(0, 0)
var speed = 100

export var direction = -1
export var health = 400
export var damage = 25

const phase_1_health_cutoff = 250
const phase_2_health_cutoff = 125

var bullet_lifespan = 1

var phase = 0

# Pre-Boss room: Have some small virus dudes scatter away on the side

# Bossfight idea:
# At start, have bones slam down to block the door
# Virus wakes up when you shoot it
# Virus charges around arena in some cool pattern that requires some skill to dodge
# At the end of each phase, go to center, close eye, become invul and trigger an effect - reactivate after x time or if effect is defeated
# After first phase - spawn mini clones of itself for the player to fight (they float up down for a bit and then charge left-right)
# After second phase - make fireballs rain from the sky, maybe also left-right?
# After third phase - spawn minis + fireballs + make boss keep moving

# After boss dies, shake screen & start self-destruct timer


func _ready():
	if direction == 1:
		$AnimatedSprite.flip_h = true
	$AnimatedSprite.play("Closed_eye")
	float_up_down(0)


func _physics_process(delta):
	if health <= 0:
		return
		
	if phase == 0:
		pass

	global_position += velocity * delta


func float_up_down(floating_phase, float_velocity = 10, direction_change_timeout = 1.5):
	velocity.y = float_velocity
	$UpDownChangeTimer.start(direction_change_timeout); yield($UpDownChangeTimer, "timeout")
	if phase == floating_phase:
		float_up_down(floating_phase, -float_velocity, direction_change_timeout)

