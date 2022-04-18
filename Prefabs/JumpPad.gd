extends Node2D

var enabled = true
export var bounce_force = -5500


func _on_Area2D_body_entered(body):
    if body.name == "Player" and enabled:
        enabled = false
        $CooldownTimer.start()
        $JumpSound.play()
        $AnimatedSprite.play("bounce")
        body.bounce(bounce_force)


func _on_CooldownTimer_timeout():
    enabled = true


func _on_AnimatedSprite_animation_finished():
    if $AnimatedSprite.animation == "bounce":
        $AnimatedSprite.play("_idle")
