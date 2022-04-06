extends Control

onready var card: Control = $Card
onready var startMenu: Control = $StartMenu
onready var musicaInicial := $Music

onready var global = get_node("/root/Global")


func _ready():
	if global.is_first_load:
		startMenu.show()
		card.hide()
		global.is_first_load = false
	# Mostra o botão de continuar se o save foi carregado e o jogo não acabou
	if card.load_game() && !card.is_game_over():
		startMenu.show_continue()

func _process(delta):
	if !musicaInicial.playing && global.is_on_menu:
		musicaInicial.play()
	elif musicaInicial.playing && !global.is_on_menu:
		musicaInicial.stop()

# Iniciar jogo, deve mostrar o Card inicial
func new_game():
	global.is_on_menu = false
	startMenu.hide()
	var save = File.new()
	if save.file_exists("user://saves/save.dat"):
		#Delete savegame
		var dir = Directory.new()
		dir.remove("user://saves/save.dat")
	card.start_card()
	get_tree().change_scene("res://placeholder1.tscn")

# Continuar jogo, deve mostrar o card carregado com o "_ready"
func continue_game():
	global.is_on_menu = false
	startMenu.hide()
	card.show()

# Terminar jogo, deve esconder o card e o botão de continuar
func finish_game():
	global.is_on_menu = true
	card.hide()
	startMenu.show()
	startMenu.hide_continue()

