extends Control

signal load_game

onready var continueBtn: Button = $Continue


func _on_StartGame_pressed():
	get_tree().change_scene("res://placeholder1.tscn")


#TODO: implementar
func _on_Continue_pressed():
	self.hide()
	emit_signal("load_game")


#TODO: implementar
func show_continue():
	continueBtn.show()

#TODO: implementar
func hide_continue():
	continueBtn.hide()
