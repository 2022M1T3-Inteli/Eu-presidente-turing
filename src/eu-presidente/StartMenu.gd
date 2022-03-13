extends Control

signal load_game
signal start_game

onready var continueBtn: Button = $Continue
		
# Emitir sinal para o "Main" quando o player quiser iniciar um novo jogo
func _on_StartGame_pressed():
	self.hide() # Esconde o menu inicial
	emit_signal("start_game") 

func _on_Minigame_pressed():
	if get_tree().change_scene("res://minigame/World.tscn") != OK:
		print ("An unexpected error occured when trying to switch to the minigame scene")

func _on_Continue_pressed():
	self.hide() # Esconde o menu inicial
	emit_signal("load_game")
	
func show_continue():
	continueBtn.show()
	
func hide_continue():
	continueBtn.hide()
