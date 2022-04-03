extends Control

# VARIAVEIS

# Sinais
signal finish_game

# Elementos
onready var portrait: Sprite = $CharacterContainer/Portrait # Personagem do card
onready var characterName: Label = $CharacterContainer/Name # Nome do personagem do card
onready var story: RichTextLabel = $TextContainer/Text # Texto de historia do card
onready var decisionA: Label = $DecisionTextContainer/DecisionA # Texto da decisao A
onready var decisionB: Label = $DecisionTextContainer/DecisionB # Texto da decisao B
onready var score: Control = $ScoreContainer/Score # Indicadores de score
onready var month: Label = $BottomBar/HBoxContainer/MarginContainer/Date # Mês do jogo
onready var popup: PopupPanel = $InfoPanel # Painel de informacoes
onready var info: RichTextLabel = $InfoPanel/Info # Texto de informacoes
onready var infoBtn: TextureButton = $BottomBar/HBoxContainer/MarginContainer2/InfoButton # Botao de informacoes
onready var ChangeCardSfx1: AudioStreamPlayer = $ChangeCardSfx1 # Efeito sonoro ao trocar de card
onready var ChangeCardSfx2: AudioStreamPlayer = $ChangeCardSfx2 # Efeito sonoro ao trocar de card 2
onready var ChangeCardSfx3: AudioStreamPlayer = $ChangeCardSfx3 # Efeito sonoro ao trocar de card 3
onready var SongCard: AudioStreamPlayer = $SongCard # Música do card

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

# Outras variaveis
var random_sfx = null # Usado para o efeito sonoro

# CONSTANTES
 
onready var PORTRAIT_ORIGINAL_X: float = portrait.position.x # Valor da posicao x quando o card é renderizado
const PORTRAIT_SPEED_X: int = 400 # Rapidez com que o card se move horizontalmente
const SPEED_SWIPE_MODIFIER: int = 5 # Coeficiente da rapidez quando o card sai de cena
const PORTRAIT_ANGULAR_VELOCITY: float = PI/3.33 # Velocidade angular de rotacao do card
const CARD_INTERVAL: float = 0.6 # Intervalo entre um card e outro
const SAVE_DIR: String = "user://saves/" # Diretorio do save
const SAVE_PATH: String = SAVE_DIR + "save.dat" # Local do save

# FUNCOES

# BUILT INS
# Funcoes fornecidas pelo proprio Godot (comecam com _)

func _ready():
	start_card()
	infoBtn.visible = false # Se houver informações a serem mostradas, rodar a função update_info no próprio card
	#$SongCard.play()

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
#		portrait.rotate(PORTRAIT_ANGULAR_VELOCITY * delta * -1)
		portrait.position.x -= PORTRAIT_SPEED_X * delta
	elif hover_right: 
		# portrait.rotate(PI/200) <- velocidade que testei
#		portrait.rotate(PORTRAIT_ANGULAR_VELOCITY * delta)
		portrait.position.x += PORTRAIT_SPEED_X * delta
	else:
		portrait.position.x = PORTRAIT_ORIGINAL_X 
#		portrait.rotation_degrees = 0
	# Para evitar que a imagem rotacione alem de 45 graus ou saia da tela,
	# limitamos aqui os valores possiveis para essas propriedades		
	portrait.rotation_degrees = clamp(portrait.rotation_degrees, -25, 25)
	portrait.position.x = clamp(portrait.position.x, 200, 500)


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
			change_card_sfx(random_sfx,ChangeCardSfx1,ChangeCardSfx2,ChangeCardSfx3)
			swiped_left = true
			yield(get_tree().create_timer(CARD_INTERVAL), "timeout")
			swiped_left = false
			current_card = functionA.function # Necessário registrar o card atual para a feature de save/load
			infoBtn.visible = false # Se houver informações a serem mostradas, rodar a função update_info no próprio card
			save_game()
			functionA.call_func()
			check_scores()


func _on_RightSwipeHitbox_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.pressed:
			change_card_sfx(random_sfx,ChangeCardSfx1,ChangeCardSfx2,ChangeCardSfx3)
			current_card = functionB.function # Necessário registrar o card atual para a feature de save/load
			infoBtn.visible = false # Se houver informações a serem mostradas, rodar a função update_info no próprio card
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
	characterName.text = name
	
# Mostra o ícone de mais informações e atualiza o box com o texto passado
func update_info(text: String) -> void:
	infoBtn.show()
	info.bbcode_text = text
	
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
	update_story("Senhor Presidente, que bom vê-lo aqui. Estamos na véspera da eleição para Deputado. O candidato {A} propõe a defesa do meio ambiente e o candidato {B} propõe a defesa das minorias. O senhor já decidiu quem vai apoiar?") #  Narrativa do card
	update_character("Presidente da Câmara") # Personagem do Card
	# PRIMEIRA DECISAO
	decisionA.text = "Candidato {A}" # Texto da primeira decisao
	update_functionA("quociente1") # Card que sera selecionado se o jogador clicar na primeira decisao
	# SEGUNDA DECISAO
	decisionB.text = "Candidato {B}" # Texto da segunda decisao
	update_functionB("quociente1") # Card que sera selecionado se o jogador clicar na segunda decisao
	# MODIFICAR OS INDICADORES
	score.set_all(5, 5, 5) # Social, Politico, Economico - Setar Score para começar o jogo
	# score.update_social(5) # Pontos a serem adicionados/removidos do indicador social
	# score.update_economic(5) # Pontos a serem adicionados/removidos do indicador economico
	# score.update_political(5) # Pontos a serem adicionados/removidos do indiciador politico
	# MES DO JOGO
	month.text = "Fevereiro"
	# INFORMACOES ADICIONAIS
	update_info("Esse box trará mais informações úteis sobre os tópicos sendo discutidos.")

	
func quociente1():
	update_story("Uma ótima escolha, Presidente! E com relação ao suporte ao candidato durante a campanha, o senhor pretende demonstrar publicamente seu apoio, participando de programas de televisão, dividindo palanques e concedendo entrevistas?")
	update_character("Secretário")
	decisionA.text = "Sim"
	update_functionA("quociente2")
	decisionB.text = "Não"
	update_functionB("quociente3")
	month.text = "Março"
	score.update_social(2)
	score.update_political(2)
	
	
func quociente2():
	update_story("Sem dúvida, seu apoio será lembrado. Mas agora já estamos no meio do ano e precisamos discutir propagandas eleitorais. Estamos pensando em uma campanha nas redes sociais pra melhorar a popularidade do candidato. Podemos agendar uma sessão de fotos?")
	update_character("Presidente da Câmara")
	decisionA.text = "Sim"
	update_functionA("quociente4")
	decisionB.text = "Não"
	update_functionB("quociente5")
	month.text = "Junho"
	
	
func quociente3():
	update_story("Entendo, a democracia somente funciona quando os poderes são independentes. Mas agora já estamos no meio do ano e seria interessante liberar verbas para a construção de creches. O senhor concordaria em liberar essas verbas?")
	update_character("Presidente da Câmara")
	decisionA.text = "Sim"
	update_functionA("quociente4")
	decisionB.text = "Não"
	update_functionB("quociente5")
	month.text = "Junho"
	
	
func quociente4():
	update_story("Agora vamos ganhar essas eleições. Sua ajuda foi fundamental, Presidente!  Estamos na frente nas pesquisas, mas todo cuidado é pouco. Tenho ouvido falar de mobilizações para fazer boca de urna em zonas eleitorais. O senhor deseja se posicionar a respeito?")
	update_character("Secretário")
	decisionA.text = "Não se posicionar"
	update_functionA("quociente6")
	decisionB.text = "Se posicionar"
	update_functionB("quociente6")
	month.text = "Outubro"


func quociente5():
	update_story("De fato, manter sua independência é a melhor estratégia para atingir seus objetivos de melhorar nosso país. De todo modo, estamos na frente nas pesquisas, mas todo cuidado é pouco. Tenho ouvido falar de mobilizações para fazer boca de urna em zonas eleitorais. O senhor deseja se posicionar a respeito?")
	update_character("Secretário")
	decisionA.text = "Se posicionar"
	update_functionA("quociente6")
	decisionB.text = "Não se posicionar"
	update_functionB("quociente6")
	month.text = "Outubro"
	
	
func quociente6():
	update_story("Acredito ter sido a postura adequada, Presidente, mas infelizmente nosso candidato perdeu por causa do quociente eleitoral, embora tenha recebido a maioria dos votos. \n\n[b](Se quiser saber o que é o quociente eleitoral, clique no ícone no canto inferior direito da tela)[/b]")
	update_character("Secretário")
	decisionA.text = "Vamos proteger os direitos fundamentais"
	update_functionA("orctet1")
	decisionB.text = "OK"
	update_functionB("orctet1")
	month.text = "Dia seguinte as eleições"
	update_info("""
O quociente eleitoral ("QE") é o valor obtido a partir da seguinte fórmula: 

[i]QE = número de votos válidos (todos os votos menos os em branco e os votos nulos) / número de vagas[/i].

Ele serve para definir o mínimo de votos que os partidos precisam para ter direito a ocupar as vagas nas eleições proporcionais: câmara dos deputados, Câmaras de Vereadores, Assembléias legislativas dos estados e Câmara Legislativa do Distrito Federal.

[b]Um Exemplo prático:[/b]

Partido/coligação | Votos nominais + votos de legenda
Partido A 		| 4.900
Partido B 		| 3.350
Partido C 		| 550
Votos em branco | 300 (não contam)
Votos nulos | 250 (não contam)
Vagas a preencher 	| 9
Total de votos válidos | 3.800

QE = 8.800 / 9 = 977,77... => [b]QE = 977[/b]

Logo, apenas os partidos A e B conseguiram atingir o quociente eleitoral e terão direito a preencher as vagas disponíveis.

Fonte: Tribunal Superior Eleitoral ("TSE")
""")

func orctet1():
	update_story("Presidente, é hora de definir a Lei de Diretrizes Orçamentárias para o próximo ano. Será necessário decidir as prioridades de investimento e as principais áreas de desenvolvimento")
	update_character("Secretário")
	decisionA.text = "Pra que fazer isso?"
	update_functionA("orctet2")
	decisionB.text = "É muito difícil?"
	update_functionB("orctet2")
	month.text = "Fevereiro, ano 2"
	
	
func orctet2():
	update_story("É necessário aplicar os recursos dos impostos em serviços públicos e isso dá bastante trabalho. Minha equipe técnica informou que o Plano Plurianual prevê 35% do orçamento para educação e saúde. Podemos direcionar essas verbas conforme previsto?")
	update_character("Min. Economia")
	decisionA.text = "Investir em educação e saúde."
	update_functionA("orctet3a")
	decisionB.text = "Vou consultar o Presidente da Câmara."
	update_functionB("orctet3b")
	month.text = "Abril, ano 2"
	
	
func orctet3a():
	update_story("O PPA foi elaborado em conjunto pela equipe técnica do Congresso e da Presidência. Caso não seja seguido sem motivo justificado, o senhor pode incorrer em penalidades por descumprimento de lei. Como o senhor irá proceder?")
	update_character("Presidente da Câmara")
	decisionA.text = "Seguir PPA"
	update_functionA("orctet4a")
	decisionB.text = "Descumprir a Lei"
	update_functionB("orctet4b")
	month.text = "Julho, ano 2"
	score.update_social(2)
	score.update_political(1)
	
	
func orctet3b():
	update_story("O PPA foi elaborado em conjunto pela equipe técnica do Congresso e da Presidência. Caso não seja seguido sem motivo justificado, o senhor pode incorrer em penalidades por descumprimento de lei. Como o senhor irá proceder?")
	update_character("Presidente da Câmara")
	decisionA.text = "Seguir PPA"
	update_functionA("orctet4a")
	decisionB.text = "Descumprir a Lei"
	update_functionB("orctet4b")
	month.text = "Julho, ano 2"
	
	
func orctet4a():
	update_story("O Congresso debateu e votou o Lei de Diretrizes Orçamentárias, sendo necessário agora definir o orçamento. A prioridade é saúde e educação, mas os servidores públicos estão pedindo aumento. Não será possível fazer os dois sem descumprir o “Teto de Gastos”. Como vamos destinar os recursos públicos?")
	update_character("Secretário")
	decisionA.text = "Saúde e educação"
	update_functionA("orctet5")
	decisionB.text = "Servidores públicos"
	update_functionB("orctet5")
	month.text = "Novembro, ano 2"
	score.update_social(1)
	
	
func orctet4b():
	update_story("O Congresso debateu e votou o Lei de Diretrizes Orçamentárias, sendo necessário agora definir o orçamento. A prioridade é saúde e educação, mas os servidores públicos estão pedindo aumento. Não será possível fazer os dois sem descumprir o “Teto de Gastos”. Como vamos destinar os recursos públicos?")
	update_character("Secretário")
	decisionA.text = "Saúde e educação"
	update_functionA("orctet5")
	decisionB.text = "Servidores públicos"
	update_functionB("orctet5")
	month.text = "Novembro, ano 2"
	score.update_political(-4)
	score.update_economic(-3)
	score.update_social(-3)
	
	
func orctet5():
	update_story("Parabéns senhor Presidente. Seguir o que estava estabelecido e não ceder à pressões é característica de grandes líderes. Agora que o orçamento está definido, o Congresso está discutindo uma PEC do voto impresso enquanto o Judiciário voltou a debater direitos fundamentais. Qual assunto o senhor prefere enfrentar primeiro")
	update_character("Secretário")
	decisionA.text = "PEC"
	update_functionA("pec1")
	decisionB.text = ("Direitos Fundamentais")
	update_functionB("pec1")
	month.text = "Dezembro, ano 2"
	
	
func pec1():
	update_story("No congresso nacional estão falando em uma PEC dos Jogos eletrônicos, isso altera a lei que taxa impostos sobre os jogos.")
	update_character("Secretário")
	decisionA.text = "Mas para que estão querendo fazer isso."
	update_functionA("pec2")
	decisionB.text = "Nossa, deve ser importante."
	update_functionB("pec2")
	month.text = "Fevereiro, ano 3"
	
	
func pec2():
	update_story("Essa PEC favorece a indústria nacional e torna alguns jogos brasileiros mais competitivos no Brasil e no mundo.")
	update_character("Secretário")
	decisionA.text = "Preciso conversar com o presidente do congresso."
	update_functionA("pec3")
	decisionB.text = "Não posso opinar nas decisões do legislativo. Eu acho que vou ficar quieto."
	update_functionB("pec3")
	month.text = "Março, ano 3"
	
	
func pec3():
	update_story("Presidente soube que você quer conversar comigo. Se for sobre a PEC o senado está a favor dessa ideia mas a população não gostou muito, parte da população já apelidou de PEC man.")
	update_character("Presidente da Câmara")
	decisionA.text = "Não quero  me posicionar"
	update_functionA("pec4")
	decisionB.text = ("Preciso me posicionar")
	update_functionB("pec4")
	month.text = "Abril, ano 3"
	score.update_political(2)
	
	
	
func pec4():
	update_story("Senhor presidente se for aprovada os impostos em cima de jogos aumentarão muito, se a indústria brasileira não for capaz de atender a população ela ficará revoltada, mas se a gente der conta nossa economia ira se fortalecer.")
	update_character("Min. Economia")
	decisionA.text = "Entendi, acho que vai ser simples decidir"
	update_functionA("pec5")
	decisionB.text = "Será muito difícil decidir."
	update_functionB("pec5")
	month.text = "Maio, ano 3"
	
	
func pec5():
	update_story("Qual será sua posição sobre a PEC dos Jogos Eletrônicos?")
	update_character("Secretário")
	decisionA.text = "A favor da PEC"
	update_functionA("pec6")
	decisionB.text = "Contra PEC"
	update_functionB("pec6")
	month.text = "Junho, ano 3"
	
	
func pec6():
	update_story("Foi bom o senhor se posicionar.Essa PEC estáva em processo de votação final, e foi aprovada! ")
	update_character("Presidente da Câmara")
	decisionA.text = "Esperava esse resultado."
	update_functionA("mpdec1")
	decisionB.text = "Não esperava esse resultado."
	update_functionB("mpdec1")
	month.text = "Julho, ano 3"
	
	
func mpdec1():
	update_story("Senhor presidente, a PEC passou pelo Congresso nacional. Mas indústrias precisam de equipamentos para produzir seus jogos")
	update_character("Secretário")
	decisionA.text = "Nossa, não pensei nisso"
	update_functionA("mpdec2")
	decisionB.text = "Verdade, você tem razão."
	update_functionB("mpdec2")
	month.text = "Agosto, ano 3"
	
func mpdec2():
	update_story("Eu acho que o meio para solucionar esse problema pode ser por meio de uma MP ou Decreto.")
	update_character("Secretário")
	decisionA.text = "Por que?"
	update_functionA("mpdec3")
	decisionB.text = "Sério?"
	update_functionB("mpdec3")
	month.text = "Setembro, ano 3"
	
	
func mpdec3():
	update_story("MP( medida provisória) você pode fazer e publicar como a mesma força de lei e decreto apenas irá complementar o que está na lei.")
	update_character("Secretário")
	decisionA.text = "Isso pode ser útil."
	update_functionA("mpdec4")
	decisionB.text = "Será mesmo que pode ser útil?"
	update_functionB("mpdec4")
	month.text = "Outubro, ano 3"
	
	
func mpdec4():
	update_story(" Uma MP pode ser muito útil, claro que você não pode colocar qualquer coisa! um exemplo são as cláusulas pétras, leis relacionadas aos direitos fundamentais de nossa democracia.")
	update_character("Secretário")
	decisionA.text = "Escolho emitir uma MP."
	update_functionA("mpdec5")
	decisionB.text = "Me fale mais sobre os decretos"
	update_functionB("mpdec5")
	month.text = "Novembro, ano 3"
	
	
func mpdec5():
	update_story("O decreto é semelhante à MP, ele possui força de uma lei e pode complementar a sua decisão. Agora o senhor precisa decidir!")
	update_character("Secretário")
	decisionA.text = " Emitir uma MP e um Decreto"
	update_functionA("mpdec6")
	decisionB.text = "Aumentar o investimento na economia"
	update_functionB("mpdec6")
	month.text = "Dezembro, ano 3 "
	
	
func mpdec6():
	update_story("Parabéns presidente! Foram publicadas uma MP e um Decreto e agora a indústria brasileira podem comprar equipamento de fora, mas produzir jogos brasileiros!")
	update_character("Secretário")
	decisionA.text = "Fizemos um ótimo trabalho"
	update_functionA("game_won")
	decisionB.text = "Isso aí, estou satisfeito."
	update_functionB("game_won")
	month.text = "Dezembro, ano 3"
	
func game_won():
	update_story("Parabéns! Você concluiu seu mandato com sucesso.")
	update_character("Secretário")
	decisionA.text = "Parabéns!"
	update_functionA("goto_start_menu")
	decisionB.text = "Vamos para a próxima!"
	update_functionB("goto_start_menu")
	month.text = "Dezembro, ano 4"
	
func lose_points():
	score.update_political(-10)
	score.update_social(-10)
	score.update_economic(-10)

func minigame_level_2():
	if get_tree().change_scene("res://minigame/fase2/World.tscn") != OK:
		print ("An unexpected error occured when trying to switch scenes")
	
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
	update_character("Presidente") # Personagem do Card
	# PRIMEIRA DECISAO
	decisionA.text = "Voltar ao menu inicial" # Texto da primeira decisao
	update_functionA("goto_start_menu") # Card que sera selecionado se o jogador clicar na primeira decisao
	# SEGUNDA DECISAO
	decisionB.text = "Voltar ao menu inicial" # Texto da segunda decisao
	update_functionB("goto_start_menu") # Card que sera selecionado se o jogador clicar na segunda decisao
	
func goto_start_menu():
	current_card = "start_card"
	save_game()
	emit_signal("finish_game")

# Função para randomizar o efeito sonoro após selecionar um card
func change_card_sfx(random,sound1,sound2,sound3):
	random = [sound1, sound2, sound3]
	random = random[randi() % random.size()]
	random.play()

