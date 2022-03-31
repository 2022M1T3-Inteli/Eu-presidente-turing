extends Control

signal new_game
signal load_game

onready var continueBtn: Button = $Continue
onready var soundSFX: AudioStreamPlayer = $SoundSFX


func _on_StartGame_pressed():
	self.hide()
	emit_signal("new_game")

func _on_Continue_pressed():
	soundSFX.play()
	self.hide()
	emit_signal("load_game")

func show_continue():
	continueBtn.show()

func hide_continue():
	continueBtn.hide()
