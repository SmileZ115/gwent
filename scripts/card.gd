extends Area2D

var card_name = "Geralt"
var card_power = 15
var in_field = false

signal card_clicked(card)

func _ready() -> void:
	$Label.text = card_name + "\n" + str(card_power)
	
	pass

func _input(event: InputEvent) -> void:
	if in_field:
		return
	if event is InputEventMouseButton and event.pressed:
		if $ColorRect.get_rect().has_point(to_local(get_global_mouse_position())):
			card_clicked.emit(self)
