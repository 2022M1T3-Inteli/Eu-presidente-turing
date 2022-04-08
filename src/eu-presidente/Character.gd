extends Node2D

signal left_swipe
signal right_swipe

func _on_RightSwipeHitbox_mouse_entered():
	print('right entered')
	emit_signal("right_swipe")

func _on_RightSwipeHitbox_mouse_exited():
	print('right exit')

func _on_LeftSwipeHitbox_mouse_entered():
	print('left entered')
	emit_signal("left_swipe")

func _on_LeftSwipeHitbox_mouse_exited():
	print('left exit')


