extends Control

# VARIAVEIS

# Sinais
signal finish_game

# Elementos
onready var portrait: Sprite = $CharacterContainer/Portrait # Personagem do card
onready var story: RichTextLabel = $TextContainer/Text # Texto de historia do card
onready var decisionA: Label = $DecisionTextContainer/DecisionA # Texto da decisao A
onready var decisionB: Label = $DecisionTextContainer/DecisionB # Texto da decisao B
onready var score: Control = $ScoreContainer/Score # Indicadores de score
onready var month: Label = $BottomBar/HBoxContainer/MarginContainer/Date # Mês do jogo
onready var popup: PopupPanel = $InfoPanel # Painel de informacoes
onready var info: Label = $InfoPanel/Info # Texto de informacoes
onready var infoBtn: TextureButton = $BottomBar/HBoxContainer/MarginContainer2/InfoButton # Botao de informacoes

# Funcoes
var functionA: FuncRef # Funcao da decisao A, seleciona o próximo card
var functionB: FuncRef # Funcao da decisao B, seleciona o próximo card
var current_card: String # Usado para o save/load
var functionCurrent: FuncRef # Usado para o save/load

# Flags 
var hover_left: bool = false # Se verdadeiro, o personagem do card deve rotacionar para a esquerda
var hover_right: bool = false # Se verdadeiro o personagem do card deve rotacionar para a direita
var swiped_left: bool = false # Se verdadeiro, o card deve sair de cena pela esquerda
var swiped_right: bool = false # Se verdadeiro, o card deve sair de cena pela direita

# CONSTANTES
 
onready var PORTRAIT_ORIGINAL_X: float = portrait.position.x # Valor da posicao x quando o card é renderizado
const PORTRAIT_SPEED_X: int = 220 # Rapidez com que o card se move horizontalmente
const SPEED_SWIPE_MODIFIER: int = 5 # Coeficiente da rapidez quando o card sai de cena
const PORTRAIT_ANGULAR_VELOCITY: float = PI/3.33 # Velocidade angular de rotacao do card
const CARD_INTERVAL: float = 0.6 # Intervalo entre um card e outro
const SAVE_DIR: String = "user://saves/" # Diretorio do save
const SAVE_PATH: String = SAVE_DIR + "save.dat" # Local do save

# FUNCOES

# BUILT INS
# Funcoes fornecidas pelo proprio Godot (comecam com _)

# Chamada todo frame. 'delta' é o tempo (em segundos) desde o último frame.
func _process(delta):
	# Essas condicoes servem para determinar se a imagem deve ser arrastada para fora da tela
	if swiped_left:
		portrait.position.x -= PORTRAIT_SPEED_X * delta * SPEED_SWIPE_MODIFIER
		return
	if swiped_right:
		portrait.position.x += PORTRAIT_SPEED_X * delta * SPEED_SWIPE_MODIFIER
		return
	
	# Essas condicoes servem para determinar se a imagem deve se mexer para
	# a esquerda ou direita, quando o jogador mover o mouse naquela direcao
	if hover_left:
		# portrait.rotate(-PI/200) <- velocidade que testei
		portrait.rotate(PORTRAIT_ANGULAR_VELOCITY * delta * -1)
		portrait.position.x -= PORTRAIT_SPEED_X * delta
	elif hover_right: 
		# portrait.rotate(PI/200) <- velocidade que testei
		portrait.rotate(PORTRAIT_ANGULAR_VELOCITY * delta)
		portrait.position.x += PORTRAIT_SPEED_X * delta
	else:
		portrait.position.x = PORTRAIT_ORIGINAL_X 
		portrait.rotation_degrees = 0
	# Para evitar que a imagem rotacione alem de 45 graus ou saia da tela,
	# limitamos aqui os valores possiveis para essas propriedades		
	portrait.rotation_degrees = clamp(portrait.rotation_degrees, -25, 25)
	portrait.position.x = clamp(portrait.position.x, 250, 450)

# SWIPE ANIMATIONS
# Esse conjunto de funcoes serve para determinar se o jogador esta com o mouse
# a direita ou esquerda da imagem do personagem, para rodar as animacoes necessarias
func _on_LeftSwipeHitbox_mouse_entered():
	hover_left = true
	# Espera para evitar que o evento "right mouse exited" seja executado antes
	yield(get_tree().create_timer(0.01), "timeout")
	decisionA.add_color_override("font_color", Color("333D29"))
	decisionB.add_color_override("font_color", Color8(55,55,55,40))

func _on_LeftSwipeHitbox_mouse_exited():
	hover_left = false
	decisionA.add_color_override("font_color", Color("#000000"))
	decisionB.add_color_override("font_color", Color("#000000"))

func _on_RightSwipeHitbox_mouse_entered():
	hover_right = true
	# Espera para evitar que o evento "left mouse exited" seja executado antes
	yield(get_tree().create_timer(0.01), "timeout")
	decisionA.add_color_override("font_color", Color8(55,55,55,40))
	decisionB.add_color_override("font_color", Color("333D29"))

func _on_RightSwipeHitbox_mouse_exited():
	hover_right = false
	decisionA.add_color_override("font_color", Color("#000000"))
	decisionB.add_color_override("font_color", Color("#000000"))

# CLICK LISTENERS
# Esse conjunto de funcoes lida com o clique do mouse para selecionar uma das opcoes binarias
func _on_LeftSwipeHitbox_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.pressed:
			swiped_left = true
			yield(get_tree().create_timer(CARD_INTERVAL), "timeout")
			swiped_left = false
			current_card = functionA.function
			save_game()
			functionA.call_func()
			check_scores()

func _on_RightSwipeHitbox_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.pressed:
			current_card = functionB.function
			save_game()
			swiped_right = true
			yield(get_tree().create_timer(CARD_INTERVAL), "timeout")
			swiped_right = false
			functionB.call_func()
			check_scores()

# Essa funcao lida com o clique para mostrar ou esconder o popup de "mais informações"
func _on_InfoButton_pressed():
	popup.visible = !popup.visible

# SAVE/LOAD
# Funcoes para salvar ou carregar o jogo (fonte: https://www.youtube.com/watch?v=d0B770ZM8Ic)
func save_game():
	var data = {
		"current_card": current_card,
		"social": score.social,
		"political": score.political,
		"economic": score.economic,
	}
	
	# Criar Diretorio se não existe
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	var file = File.new()
	var error = file.open(SAVE_PATH, File.WRITE)
	if error == OK:
		file.store_var(data)
		file.close()

# Carrega o jogo, retorna "True" se o save foi carregado corretamente, "False" se não foi
func load_game():
	var file = File.new()
	# Verificar se o arquivo de save existe
	if file.file_exists(SAVE_PATH):
		var error = file.open(SAVE_PATH, File.READ)
		if error == OK:
			var player_data = file.get_var()
			file.close()
			score.set_all(player_data.social, player_data.political, player_data.economic)
			functionCurrent = funcref(self, player_data.current_card)
			functionCurrent.call_func()
			return true # Load carregado corretamente
	return false # Erro no load

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
	score.set_all(5, 5, 5) # Social, Politico, Economico - Setar Score para começar o jogo
	# score.update_social(5) # Pontos a serem adicionados/removidos do indicador social
	# score.update_economic(5) # Pontos a serem adicionados/removidos do indicador economico
	# score.update_political(5) # Pontos a serem adicionados/removidos do indiciador politico
	# MES DO JOGO
	month.text = "Janeiro"
	# INFORMACOES ADICIONAIS
	# info.text = ""
	infoBtn.visible = true
	
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
	infoBtn.visible = false

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
	update_character("ministra_economia") # Personagem do Card
	decisionA.text = "..." 
	update_functionA("health") # Card que sera selecionado com a primeira decisao
	decisionB.text = "..." 
	update_functionB("health") # Card que sera selecionado com a primeira decisao
	month.text = "Fevereiro" 
	score.update_social(1)
	score.update_economic(-1)
	
func education():
	update_story("Ok, vamos priorizar a [b]educação[/b] então!")
	decisionA.text = "..." 
	decisionB.text = "..." 
	score.update_political(-1)
	score.update_economic(1)


# LOW SCORE OR GAME OVER CHECKS
# Funcoes para checar se a pontuacao do jogador esta baixa ou se ele perdeu o jogo
func check_scores():
	if is_game_over():
		game_over()
		return true
	else:
		return false

func is_game_over():
	return (score.social <= 0) || (score.political <= 0) || (score.economic <= 0)
		
func is_low_political():
	pass
	
func is_low_economic():
	pass
	
func is_low_social():
	pass

		
# TRIGGERED CARDS
# Esses cards são ativados automaticamente caso o jogador tenha uma pontuação baixa

func game_over():
	# TEXTOS E IMAGENS
	update_story("Presidente, infelizmente um dos seus indicadores ficou abaixo de 0 e você sofreu um processo de [b]impeachment[/b]. Tente novamente!") #  Narrativa do card
	update_character("presidente") # Personagem do Card
	# PRIMEIRA DECISAO
	decisionA.text = "Voltar ao menu inicial" # Texto da primeira decisao
	update_functionA("goto_start_menu") # Card que sera selecionado se o jogador clicar na primeira decisao
	# SEGUNDA DECISAO
	decisionB.text = "Voltar ao menu inicial" # Texto da segunda decisao
	update_functionB("goto_start_menu") # Card que sera selecionado se o jogador clicar na segunda decisao
	# INFORMACOES ADICIONAIS
	infoBtn.visible = true
	
func goto_start_menu():
	emit_signal("finish_game")

