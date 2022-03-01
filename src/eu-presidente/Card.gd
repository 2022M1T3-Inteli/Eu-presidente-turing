extends Control

# VARIAVEIS

# Elementos
onready var portrait: Sprite = $CharacterContainer/Portrait # Personagem do card
onready var story: RichTextLabel = $TextContainer/Text # Texto de historia do card
onready var decisionA: Label = $DecisionTextContainer/DecisionA # Texto da decisao A
onready var decisionB: Label = $DecisionTextContainer/DecisionB # Texto da decisao B
onready var score: Control = $ScoreContainer/Score # Indicadores de score
onready var month: Label = $BottomBar/HBoxContainer/MarginContainer/Date # Mês do jogo

var functionA: FuncRef = funcref(self, "card2") # Funcao da decisao A
var functionB: FuncRef = funcref(self, "card3") # Funcao da decisao B

# Flags 
var swipe_left: bool = false # Se verdadeiro, o personagem do card deve rotacionar para a esquerda
var swipe_right: bool = false # Se verdadeiro o personagem do card deve rotacionar para a direita
# Propriedades 
var portrait_original_x: int = 0 # Valor da posicao x quando o personagem do card é renderizado
var portrait_angular_velocity: float = PI/3.33 # Velocidade angular de rotacao do personagem do card


# FUNCOES

# BUILT INS
# Funcoes fornecidas pelo proprio Godot (comecam com _)

# Chamada quando o node entrar na cena pela primeira vez.
func _ready():
	portrait_original_x = portrait.position.x
	start_card()

# Chamada toda vez que o usuário der um input. 'event' é o evento em si.
func _input(_event):
	pass

# Chamada todo frame. 'delta' é o tempo (em segundos) desde o último frame.
func _process(delta):
	# Essas condicoes servem para determinar se a imagem deve se mexer para
	# a esquerda ou direita, quando o jogador mover o mouse naquela direcao
	if swipe_left:
		# portrait.rotate(-PI/200) <- velocidade que testei
		portrait.rotate(portrait_angular_velocity * delta * -1)
		portrait.position.x -= 2
	elif swipe_right: 
		# portrait.rotate(PI/200) <- velocidade que testei
		portrait.rotate(portrait_angular_velocity * delta)
		portrait.position.x += 2
	else:
		portrait.position.x = portrait_original_x 
		portrait.rotation_degrees = 0
	# Para evitar que a imagem rotacione alem de 45 graus ou saia da tela,
	# limitamos aqui os valores possiveis para essas propriedade		
	portrait.rotation_degrees = clamp(portrait.rotation_degrees, -45, 45)
	portrait.position.x = clamp(portrait.position.x, 250, 450)

# SWIPE ANIMATIONS
# Esse conjunto de funcoes serve para determinar se o jogador esta com o mouse
# a direita ou esquerda da imagem do personagem, para rodar as animacoes necessarias
func _on_LeftSwipeHitbox_mouse_entered():
	swipe_left = true
	# Espera para evitar que o evento "right mouse exited" seja executado antes
	yield(get_tree().create_timer(0.01), "timeout")
	decisionA.add_color_override("font_color", Color("333D29"))
	decisionB.add_color_override("font_color", Color8(55,55,55,40))

func _on_LeftSwipeHitbox_mouse_exited():
	swipe_left = false
	decisionA.add_color_override("font_color", Color("#000000"))
	decisionB.add_color_override("font_color", Color("#000000"))

func _on_RightSwipeHitbox_mouse_entered():
	swipe_right = true
	# Espera para evitar que o evento "left mouse exited" seja executado antes
	yield(get_tree().create_timer(0.01), "timeout")
	decisionA.add_color_override("font_color", Color8(55,55,55,40))
	decisionB.add_color_override("font_color", Color("333D29"))

func _on_RightSwipeHitbox_mouse_exited():
	swipe_right = false
	decisionA.add_color_override("font_color", Color("#000000"))
	decisionB.add_color_override("font_color", Color("#000000"))

# CLICK LISTENERS
# Esse conjunto de funcoes lida com o clique do mouse para selecionar uma das opcoes binarias
func _on_LeftSwipeHitbox_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.pressed:
			functionA.call_func()
			

func _on_RightSwipeHitbox_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.pressed:
			functionB.call_func()
			
# HELPERS
# Esse conjunto de funcoes sao auxiliares (helpers) para as (varias) funcoes de card abaixo

# Atualiza o texto da historia (narrativa) do card
func update_story(text: String) -> void:
	story.bbcode_text = "[center]" + text + "[/center]"
	
# Atualiza o retrato/imagem do personagem do card 
func update_character(name: String) -> void:
	var path = "res://assets/characters/%s.png" % name
	portrait.texture = load(path)
	
# Atualiza a funcao executada quando o jogador escolhe a decisao A
# Deve ser o nome de outro card que voce quer que seja escolhido quando o jogador tomar a decisao A
func update_functionA(fn_name: String) -> void:
	functionA = funcref(self, fn_name)

# Atualiza a funcao executada quando o jogador escolhe a decisao B
# Deve ser o nome de outro card que voce quer que seja escolhido quando o jogador tomar a decisao B
func update_functionB(fn_name: String) -> void:
	functionB = funcref(self, fn_name)
	
# CARDS
# Esse conjunto de funcoes contem TODOS os cards que serao usados no jogo.
# Basicamente, cada funcao dessa secao devera atualizar todas as informacoes do card.
# Para tanto, podera se valer das funcoes "helpers" acima.
# 1. Alterar a narrativa, a imagem do personagem e as decisoes
# 2. Alterar zero, um ou mais scores (politico, economico e social)
# 3. Redefinir as funcoes que serao executadas, para "linkar" os proximos cards

func start_card():
	# TEXTOS E IMAGENS
	update_story("Parabéns! Após meses de campanha, você foi eleito [b]presidente do Brasil[/b]. Você está confiante?") #  Narrativa do card
	update_character("presidente") # Personagem do Card
	# PRIMEIRA DECISAO
	decisionA.text = "Sim, claro!" # Texto da primeira decisao
	update_functionA("confident") # Card que sera selecionado se o jogador clicar na primeira decisao
	# SEGUNDA DECISAO
	decisionB.text = "Ainda não..." # Texto da segunda decisao
	update_functionB("unsure") # Card que sera selecionado se o jogador clicar na segunda decisao
	# MODIFICAR OS INDICADORES
	#score.update_social(1) # Pontos a serem adicionados/removidos do indicador social
	#score.update_economic(1) # Pontos a serem adicionados/removidos do indicador economico
	#score.update_political(1) # Pontos a serem adicionados/removidos do indiciador politico
	# MES DO JOGO
	month.text = "Janeiro"
	
func confident():
	# TEXTOS E IMAGENS
	update_story("Seu [b]Secretário[/b] se aproxima: Muito bem Sr. Presidente! Tenho certeza de que tudo irá dar certo.") #  Narrativa do card
	update_character("secretario") # Personagem do Card
	# PRIMEIRA DECISAO
	decisionA.text = "Obrigado, secretário" # Texto da primeira decisao
	update_functionA("budget") # Card que sera selecionado com a primeira decisao
	# SEGUNDA DECISAO
	decisionB.text = "Temos muito trabalho\npela frente..." # Texto da segunda decisao
	update_functionB("budget") # Card que sera selecionado com a segunda decisao

func unsure():
	# TEXTOS E IMAGENS
	update_story("Seu [b]secretário[/b] vem lhe aconselhar: Não se preocupe, Sr. presidente, eu posso lhe ajudar caso tenha alguma dúvida.") #  Narrativa do card
	update_character("secretario") # Personagem do Card
	# PRIMEIRA DECISAO
	decisionA.text = "Obrigado, secretário" # Texto da primeira decisao
	update_functionA("budget") # Card que sera selecionado com a primeira decisao
	# SEGUNDA DECISAO
	decisionB.text = "Temos muito trabalho\npela frente..." # Texto da segunda decisao
	update_functionB("budget") # Card que sera selecionado com a segunda decisao

func budget():
	update_story("[b]Ministra da Economia:[/b] Presidente, precisamos escolher - qual setor será priorizado: [i]saúde[/i] ou [i]educação[/i]?") 
	update_character("ministra_economia") # Personagem do Card
	# PRIMEIRA DECISAO
	decisionA.text = "Saúde" # Texto da primeira decisao
	update_functionA("health") # Card que sera selecionado com a primeira decisao
	# SEGUNDA DECISAO
	decisionB.text = "Educacao" # Texto da segunda decisao
	update_functionB("education") # Card que sera selecionado com a segunda decisao
	
func health():
	update_story("Ok, vamos priorizar a [b]saúde[/b] então!")
	decisionA.text = "..." 
	decisionB.text = "..." 
	month.text = "Fevereiro" 
	score.update_social(1)
	score.update_economic(-1)
	
func education():
	update_story("Ok, vamos priorizar a [b]educação[/b] então!")
	decisionA.text = "..." 
	decisionB.text = "Fevereiro" 
	score.update_social(1)
	score.update_economic(-1)

