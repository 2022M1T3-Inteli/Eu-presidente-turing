extends Control

signal start_game

#func _ready():
#	pass

#func _process(delta):
#	pass

# Emitir sinal para o "Main" quando o player quiser iniciar um novo jogo
func _on_StartGame_pressed():
	self.hide() # Esconde o menu inicial
	emit_signal("start_game") 


func _on_Minigame_pressed():
	get_tree().change_scene("res://minigame/World.tscn")
