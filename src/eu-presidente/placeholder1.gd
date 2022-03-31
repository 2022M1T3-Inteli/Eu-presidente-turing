extends Button

onready var selextSfx := $SelectSfx

func _ready():
	selextSfx.play()

func _on_init_btn_pressed():
	get_tree().change_scene("res://placeholder2.tscn")
