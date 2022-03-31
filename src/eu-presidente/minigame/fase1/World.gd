extends Node2D

signal first_npc_stop
signal first_npc_start

var contador = 0

const caixa_dialogo_first_npc = preload("res://minigame/fase1/caixa_texto.tscn")

onready var global = get_node("/root/Global")

func _ready():
	$WorldSong.play()
	
	var timer_instructions1 = Timer.new()
	timer_instructions1.one_shot = true
	timer_instructions1.wait_time = 5
	timer_instructions1.connect("timeout", self, "on_timer_instructions1_timeout")
	add_child(timer_instructions1)
	timer_instructions1.start()


func _process(delta):
	
	if $npcs/first_npc/KinematicBody2D.position.x - 150 <= $npcs/Player.position.x and \
	   $npcs/first_npc/KinematicBody2D.position.x + 150 >= $npcs/Player.position.x and \
	   $npcs/first_npc/KinematicBody2D.position.y + 150 >= $npcs/Player.position.y and \
	   $npcs/first_npc/KinematicBody2D.position.y - 150 <= $npcs/Player.position.y:
		if contador == 0:
			call_dialog_box()
			emit_signal("first_npc_stop")
			contador += 1
	else:
		emit_signal("first_npc_start")
		contador == 0

func call_dialog_box():
	var dialogo = caixa_dialogo_first_npc.instance()
	self.add_child(dialogo)

func on_timer_instructions1_timeout():
	$"Instructions 1".visible = false
	$"Instructions 2".visible = true
	
	var timer_instructions2 = Timer.new()
	timer_instructions2.one_shot = true
	timer_instructions2.wait_time = 5
	timer_instructions2.connect("timeout", self, "on_timer_instructions2_timeout")
	add_child(timer_instructions2)
	timer_instructions2.start()

func on_timer_instructions2_timeout():
	$"Instructions 2".visible = false
	$"Instructions 3".visible = true
	
	var timer_instructions3 = Timer.new()
	timer_instructions3.one_shot = true
	timer_instructions3.wait_time = 5
	timer_instructions3.connect("timeout", self, "on_timer_instructions3_timeout")
	add_child(timer_instructions3)
	timer_instructions3.start()

func on_timer_instructions3_timeout():
	$"Instructions 3".visible = false

func _on_Area2D_body_entered(body):
	$Buildings/AnimatedSprite.play()

func _on_AnimatedSprite_animation_finished():
	$Buildings/AnimatedSprite.stop()
	$Buildings/AnimatedSprite.frame = 3

func _on_card_congresso_body_entered(body):
	get_tree().change_scene("res://Main.tscn")

func _on_entrada_congresso_body_exited(body):
	$Buildings/AnimatedSprite.frame = 0

func _on_StaticBody2D_esq_path1_body_entered(body):
	body.position = $border_collisions/Position2D_esq_path1.position

func _on_StaticBody2D_esq_path2_body_entered(body):
	body.position = $border_collisions/Position2D_esq_path2.position

func _on_Area2D_dir_path1_body_entered(body):
	body.position = $border_collisions/Position2D_dir_path1.position

func _on_Area2D_dir_path2_body_entered(body):
	body.position = $border_collisions/Position2D_dir_path2.position
