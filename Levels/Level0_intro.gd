extends CanvasLayer

var color_rect_opacity := 0.0
var is_fading_out := false

# TODO: Add heartbeat background sound
# TODO: Make skippable (just change_scene on Enter or Esc)

func _ready():
	$RichTextLabel.get_child(0).rect_scale.x = 0
	yield (get_tree().create_timer(1), "timeout")
	yield (write_text("A comet was on collision course with Earth and would have wiped out our civilization, so the UEC (United Earth Corp.) tried to blow it up before it hit us. "), "completed")
	yield (get_tree().create_timer(0.5), "timeout")

	yield (write_text("\n\nThey almost succeeded. "), "completed")
	yield (get_tree().create_timer(1), "timeout")

	yield (write_text("\n\nThey managed to change it's trajectory so it would miss Earth, but the explosion also split off several meteorites that are on track for impact. "), "completed")
	yield (get_tree().create_timer(0.5), "timeout")

	yield (write_text("\n\nThe first one of them, the *Principal Meteorite* has already reached Earth. "), "completed")
	yield (get_tree().create_timer(0.5), "timeout")

	yield (write_text("It has the size of the Burj Khalifa and obliterated an entire city on impact. But what's even worse: "), "completed")
	yield (get_tree().create_timer(0.5), "timeout")

	yield (write_text("\n\nIt's alive!"), "completed")
	yield (get_tree().create_timer(1), "timeout")

	yield (write_text("\n\nYou are Sam Erin, famous bounty hunter and explorer, sent to into the maw of the beast to investigate."), "completed")
	yield (get_tree().create_timer(0.5), "timeout")

	yield (write_text("\n\nWhat will you find inside?"), "completed")
	yield (get_tree().create_timer(2), "timeout")

	is_fading_out = true

func write_text(text: String, interval: float=0.06):
	for i in range(0, text.length()):
		$RichTextLabel.text += text[i]
		yield (get_tree().create_timer(interval), "timeout")

func _physics_process(delta):
	if is_fading_out and color_rect_opacity < 1:
		color_rect_opacity += delta * 0.5
		$ColorRect.color = Color(0, 0, 0, color_rect_opacity)

	if color_rect_opacity >= 1:
		var _x = get_tree().change_scene("res://Levels/Level1.tscn")

func _process(_delta):
	if Input.is_joy_button_pressed(0, JOY_START):
		is_fading_out = true

func _input(ev: InputEvent):
	if ev is InputEventKey and ev.scancode == KEY_ESCAPE and not ev.echo:
		is_fading_out = true


func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.play()
