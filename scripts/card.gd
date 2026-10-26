extends Area2D
class_name Card

var card_name: String = "Geralt"
var card_power: int = 15
var in_field: bool = false

signal card_clicked(card: Card)

func _ready() -> void:
	$Label.text = card_name + "\n" + str(card_power)

func _input(event: InputEvent) -> void:
	if in_field:
		return
	if event is InputEventMouseButton and event.pressed:
		if $ColorRect.get_rect().has_point(to_local(get_global_mouse_position())):
			card_clicked.emit(self)
