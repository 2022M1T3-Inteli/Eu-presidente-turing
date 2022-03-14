extends Control

onready var card: Control = $Card
onready var startMenu: Control = $StartMenu

func _ready():
	# Mostra o botão de continuar se o save foi carregado e o jogo não acabou
	if card.load_game() && !card.is_game_over():
		startMenu.show_continue()

# Iniciar jogo, deve mostrar o Card inicial
func new_game():
	card.start_card()
	card.show()

# Continuar jogo, deve mostrar o card carregado com o "_ready"
func continue_game():
	card.show()

# Terminar jogo, deve esconder o card e o botão de continuar
func finish_game():
	card.hide()
	startMenu.show()
	startMenu.hide_continue()
