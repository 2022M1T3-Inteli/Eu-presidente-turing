extends Button

onready var selectSfx := $Select

func _ready():
	selectSfx.play() #toca o som do start


func _on_init_btn_pressed():
	get_tree().change_scene("res://placeholder2.tscn")
