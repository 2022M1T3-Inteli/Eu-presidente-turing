extends CanvasLayer

const CHAR_READ_RATE = 0.05

onready var texto_container = $caixaDeTexto
onready var iniciar = $caixaDeTexto/MarginContainer/HBoxContainer/asterisco
onready var finalizar = $caixaDeTexto/MarginContainer/HBoxContainer/proximo
onready var texto = $caixaDeTexto/MarginContainer/HBoxContainer/texto

enum State {
	PRONTO,
	LENDO,
	TERMINADO,
}

var estado_atual = State.TERMINADO
var texto_fila = []

func _ready():
	hide_textbox()
	fila_texto("SECRETÁRIO: Olá Presidente, ainda bem que te encontrei...")
	fila_texto("...o senhor precisa se decidir sobre a votação para Deputado!")
	fila_texto("PRESIDENTE: Como assim? Onde estou?")
	fila_texto("SECRETÁRIO: Você está em Brasília, Presidente!")
	fila_texto("Amanhã é a eleição para Deputado e o senhor ainda não definiu seu candidato.")
	fila_texto("Você precisa falar com o Presidente da Câmara agora e se decidir...")
	fila_texto("Apenas lembrando, o Congresso fica no centro da Praça dos Poderes")
	fila_texto("Sugiro que o senhor se encaminhe para lá o quanto antes")

func _process(delta):
	match estado_atual:
		State.PRONTO:
			if !texto_fila.empty():
				mostrar_texto()
		State.LENDO:
			if Input.is_action_just_pressed("ui_accept"):
				texto.percent_visible = 1.0
				$Tween.remove_all()
				finalizar.text = "v"
				mudar_estado(State.TERMINADO)
		State.TERMINADO:
			if Input.is_action_just_pressed("ui_accept"):
				mudar_estado(State.PRONTO)
				hide_textbox()

func fila_texto(proximo_texto):
	texto_fila.push_back(proximo_texto)

func hide_textbox():
	iniciar.text = ""
	finalizar.text = ""
	texto.text = ""
	texto_container.hide()
	
func show_textbox():
	iniciar.text = "*"
	texto_container.show()
	
func mostrar_texto():
	var proximo_texto = texto_fila.pop_front()
	texto.text = proximo_texto
	texto.percent_visible = 0.0
	mudar_estado(State.LENDO)
	show_textbox()
	$Tween.interpolate_property(texto, "percent_visible", 0.0, 1.0, len(proximo_texto) * CHAR_READ_RATE, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func mudar_estado(proximo_estado):
	estado_atual = proximo_estado
