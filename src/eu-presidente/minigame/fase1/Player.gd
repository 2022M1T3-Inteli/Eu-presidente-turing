extends KinematicBody2D

# O script a seguir foi gerado ao seguirmos a excelente série de video tutoriais 
# do desenvolvedor "HeartBeast": "Make an Action RPG in Godot 3.2", 
# disponível em https://www.youtube.com/watch?v=mAbG8Oi-SvQ

const ACCELERATION = 1000 # Aceleracao do avatar
const MAX_SPEED = 200 # Velocidade maxima do avatar
const FRICTION = 1000 # Friccao do avatar

var velocity = Vector2.ZERO # Inicializar vetor

onready var animationPlayer = $AnimationPlayer # Animacoes do avatar
onready var animationTree = $AnimationTree # Maquina de estados
onready var animationState = animationTree.get("parameters/playback") # Estado

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)
