extends Control

var swipe_left = false
var swipe_right = false
onready var portrait = $CharacterContainer/Portrait
var portrait_original_x = null

# Chamada quando o node entrar na cena pela primeira vez.
func _ready():
	portrait_original_x = portrait.position.x

# Chamada toda vez que o usuário der um input. 'event' é o evento em si.
func _input(event):
	pass

# Chamada todo frame. 'delta' é o tempo (em segundos) desde o último frame.
func _process(delta):
	print(portrait.rotation_degrees)
	if swipe_left:
		portrait.rotate(-PI/200)
		portrait.position.x -= 2
	elif swipe_right: 
		portrait.rotate(PI/200)
		portrait.position.x += 2
	else:
		portrait.position.x = portrait_original_x 
		portrait.rotation_degrees = 0

	portrait.rotation_degrees = clamp(portrait.rotation_degrees, -45, 45)
	portrait.position.x = clamp(portrait.position.x, 250, 450)

func _on_LeftSwipeHitbox_mouse_entered():
	swipe_left = true
	print('entered left')
	


func _on_LeftSwipeHitbox_mouse_exited():
	swipe_left = false
	print('exit left')


func _on_RightSwipeHitbox_mouse_entered():
	swipe_right = true
	print('entered right')



func _on_RightSwipeHitbox_mouse_exited():
	swipe_right = false
	print('exit right')
