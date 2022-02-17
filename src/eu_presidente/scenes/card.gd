extends Control

signal moving()

export var image1: StreamTexture
export var image2: StreamTexture
export var image3: StreamTexture

export var text1: String
export var text2: String
export var text3: String

onready var images_set = [image1, image2, image3]
onready var sets = [images_set]

onready var texts_set = [text1, text2, text3]

var image_idx = 0

var pressed = false
var first_press_pos = null

var enabled = false

var images = []

func _ready():
	randomize()
	images = sets[int(rand_range(0, 1))]
	
	change_image(0)
	
	$ImageContainer/Image.material.set_shader_param("size", $ImageContainer/Image.rect_size)
	
func _input(event):
	if !enabled: return        # pra mim esse comando deveria sair da função. NÃO ENTENDO!!
	
	if event is InputEventScreenDrag:
		
		# dispara um sinal de movimento
		# move a posicao da imagem para o ponto de touch
		# faz a imagem rotacionar com base na extensão do movimento no eixo x
		# desliga o botão pressed
		var dist = event.position - first_press_pos
		emit_signal("moving")
		rect_position = dist 
		rect_rotation = -(event.position.x - first_press_pos.x) * 0.025   #TESTAR TROCANDO SINAL +() E MUDANDO COEFICIENTE
		pressed = false
	
	# enquanto o mouse estiver clicado, o jogo apenas registra o ponto do clique
	# e muda a variavel pressed para true, para registrar que o mouse foi clicado
	if event is InputEventMouseButton:
		if event.pressed:
			
			# esse evento também será ligado/desligado pela função de swipe
			pressed = true
			first_press_pos = event.position
			
		# quando o botao do mouse for solto, event.pressed passará a ser Falso, acionando o else
		# como botão foi apertado, pressed = true
		# se a posição do primeiro clique foi do meio da tela pra direita, chama a função de
		# próximo. caso contrário, chama a de anterior
		else:
			if pressed:
				if event.position.x > (rect_size.x/2):     # DE ONDE ESTÁ VINDO O RECT.SIZE ???
					_on_NextBtn_pressed()
				else:
					_on_PreviousBtn_pressed()
			
			
			else:
				pressed = false
				first_press_pos = null
	
func change_image(idx):
	change_text(idx)
	for child in $MarginContainer/HBoxContainer.get_children():
		child.value = 0
	$ImageContainer/Image.texture = images[idx]
	$MarginContainer/HBoxContainer.get_child(idx).value = 100


func change_text(idx):
	$Button/MarginContainer/HBoxContainer/VBoxContainer/Label.text = texts_set[idx]
	
func _on_PreviousBtn_pressed():
	if image_idx == 0: image_idx = 0
	else: image_idx -= 1
	change_image(image_idx)

func _on_NextBtn_pressed():
	if image_idx == images.size() - 1: image_idx = images.size() - 1
	else: image_idx += 1
	change_image(image_idx)
