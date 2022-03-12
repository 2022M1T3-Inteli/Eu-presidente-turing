extends Control

# Iniciar jogo, deve mostrar o Card
func new_game():
	$Card.start_card()
	$Card.show()

func continue_game():
	$Card.load_game()
	$Card.show()
