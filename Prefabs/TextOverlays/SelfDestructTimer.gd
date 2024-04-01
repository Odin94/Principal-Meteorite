extends CanvasLayer

func update_time(new_time: float):
	var int_new_time = int(new_time)
	var minutes = int_new_time / 60
	var seconds = int_new_time % 60
	if seconds < 10:
		seconds = "0" + str(seconds)
	$RichTextLabel.text = str(minutes) + ":" + str(seconds)
