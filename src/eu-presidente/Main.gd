extends Control

onready var card: Control = $Card
onready var startMenu: Control = $StartMenu

# Iniciar jogo, deve mostrar o Card
func new_game():
	card.start_card()
	card.show()

func continue_game():
	card.load_game()
	card.show()

func finish_game():
	card.hide()
	startMenu.show()
