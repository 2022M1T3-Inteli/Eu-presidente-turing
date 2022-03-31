extends Control

signal new_game
signal load_game

onready var continueBtn: Button = $Continue
onready var presidentinho := $presidentinho
onready var animacao := $presidentinho/AnimatedSprite

var time = 0
var pos = Vector2(360, -75)
var velo = Vector2(0,1)
var stop = Vector2(0,0)

func _ready():
	presidentinho.position = pos


func _physics_process(delta): # Animação do personagem no menu inicial
	time += delta
	if time <= 13:
		animacao.play("walking_down")
		presidentinho.move_and_collide(velo)
	else:
		animacao.stop()


func _on_StartGame_pressed():
	self.hide()
	emit_signal("new_game")

func _on_Continue_pressed():
	self.hide()
	emit_signal("load_game")

func show_continue():
	continueBtn.show()

func hide_continue():
	continueBtn.hide()
