extends Node2D

#const CARD = preload("res://Card.tscn")
func _ready():
	$WorldSong.play()

func _process(delta):
	pass


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
