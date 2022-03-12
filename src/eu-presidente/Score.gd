extends Control


var social: int = 0
var political: int = 0
var economic: int = 0

onready var social_label: Label = $HBoxContainer/VBoxContainer/SocialScore
onready var political_label: Label = $HBoxContainer/VBoxContainer2/PoliticalScore
onready var economic_label: Label = $HBoxContainer/VBoxContainer3/EconomicScore
onready var social_modifier: Label = $HBoxContainer/VBoxContainer/SocialModifier
onready var political_modifier: Label = $HBoxContainer/VBoxContainer2/PoliticalModifier
onready var economic_modifier: Label = $HBoxContainer/VBoxContainer3/EconomicModifier

# Called when the node enters the scene tree for the first time.
func _ready():
	social_label.text = String(social)
	political_label.text = String(political)
	economic_label.text = String(economic)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Mostra o modifier temporariamente quando o score mudar
func show_modifier(label: Label, pts: int):
	if pts > 0:
		label.text = "+" + String(pts)
		label.add_color_override("font_color", Color8(0,255,0,100))
	else:
		label.text = String(pts)
		label.add_color_override("font_color", Color8(255,0,0,100))

	label.show()
	yield(get_tree().create_timer(3), "timeout")
	label.hide()
	
func update_social(pts: int):
	social += pts
	social_label.text = String(social)
	show_modifier(social_modifier, pts)
	
func update_political(pts: int):
	political += pts
	political_label.text = String(political)
	show_modifier(political_modifier, pts)

func update_economic(pts: int):
	economic += pts
	economic_label.text = String(economic)
	show_modifier(economic_modifier, pts)

func update_all(social_pts: int, political_pts: int, economic_pts: int):
	update_social(social_pts)
	update_political(political_pts)
	update_economic(economic_pts)
	
func set_all(social_pts: int, political_pts: int, economic_pts: int):
	social = social_pts
	social_label.text = String(social)
	political = political_pts
	political_label.text = String(political)
	economic = economic_pts
	economic_label.text = String(economic)
