extends Node

const speed = 100

var pos0 = false
var pos1 = true
var pos2 = false
var pos3 = false

func _ready():
	$first_npc/KinematicBody2D.position = $first_npc/Position2D.position
	
func _process(delta):
	
	var path
	
	if pos1:
		path = $first_npc/Position2D2
		mov_pos(path)
	elif pos2:
		path = $first_npc/Position2D3
		mov_pos(path)
	elif pos3:
		path = $first_npc/Position2D4
		mov_pos(path)
	elif pos0:
		pos0 = false
		pos1 = true
		

func mov_pos(path):
	
	var velocity = Vector2.ZERO
	var delta_x = abs($first_npc/KinematicBody2D.position.x) - abs(path.position.x)
	var delta_y = abs($first_npc/KinematicBody2D.position.y) - abs(path.position.y)
	
	if $first_npc/KinematicBody2D.position.x < path.position.x:
		velocity.x += 1
	if $first_npc/KinematicBody2D.position.x > path.position.x:
		velocity.x -= 1
	if $first_npc/KinematicBody2D.position.y < path.position.y:
		velocity.y += 1
	if $first_npc/KinematicBody2D.position.y > path.position.y:
		velocity.y -= 1
	if delta_x <= 20 and delta_y <= 20:
		switch_path(path)

	$first_npc/KinematicBody2D.move_and_slide(velocity.normalized() * speed)
	player_animation(path, velocity)
	
func switch_path(path):
	if path == $first_npc/Position2D2:
		pos1 = false
		pos2 = true
		
	elif path == $first_npc/Position2D3:
		pos2 = false
		pos3 = true
	
	elif path == $first_npc/Position2D4:
		$first_npc/KinematicBody2D.position = $first_npc/Position2D.position
		pos3 = false
		pos0 = true
		
		
func player_animation(path, velocity):
	
	if path == $first_npc/Position2D2 or path == $first_npc/Position2D4:
		$first_npc/KinematicBody2D/AnimatedSprite.play("walk_left")
	elif path == $first_npc/Position2D3:
		$first_npc/KinematicBody2D/AnimatedSprite.play("walk_up")
			
	
func _on_Area2D_body_entered(body):
	$fox.play("looking")


func _on_Area2D2_body_entered(body):
	$fox.play("idle")


func _on_Area2D3_body_entered(body):
	$fox.play("sleeping")
