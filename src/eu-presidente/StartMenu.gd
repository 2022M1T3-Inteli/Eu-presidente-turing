extends Control

signal load_game
signal start_game

onready var continueBtn: Button = $Continue

const SAVE_DIR: String = "user://saves/" # Diretorio do save
const SAVE_PATH: String = SAVE_DIR + "save.dat" # Local do save

func _ready():
	continueBtn.hide()
	# Mostra o botão de continuar se existir um arquivo de save com pontuação válida
	var file = File.new()
	if file.file_exists(SAVE_PATH) && !get_node("/root/Global").is_game_over:
		continueBtn.show()

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
