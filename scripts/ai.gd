extends RefCounted
class_name AI

var battlefield: Node2D
var card: PackedScene
var hand: Array[CardData]
var screen_size: Vector2
var ai_passed: bool = false

signal turn_ended
signal round_ended
signal points_updated

func setup(card_scene: PackedScene, ai_cards: Array[CardData], ai_battlefield: Node2D, screen: Vector2):
	card = card_scene
	hand = ai_cards
	battlefield = ai_battlefield
	screen_size = screen

func ai_turn(player_passed: bool, player_points: int) -> void:
	if ai_passed:
		if player_passed:
			round_ended.emit()
		else:
			turn_ended.emit()
		return
	if hand.size() == 0:
		ai_passed = true
		if player_passed:
			round_ended.emit()
		else:
			turn_ended.emit()
		return
	if player_passed and get_ai_points() > player_points:
		ai_passed = true
		round_ended.emit()
		return
	var rand_index = randi() % hand.size()
	var chosen_card: CardData = hand[rand_index]
	var card_instance: Card = card.instantiate() as Card
	var count = battlefield.get_child_count()
	card_instance.card_name = chosen_card.card_name
	card_instance.card_power = chosen_card.card_power
	await battlefield.get_tree().create_timer(1.0).timeout
	battlefield.add_child(card_instance)
	card_instance.position = Vector2((screen_size.x / 2) + (count - 1) * 90 - 180, screen_size.y * 0.4)
	hand.erase(chosen_card)
	points_updated.emit()
	if player_passed:
		ai_turn(player_passed, player_points)
	else:
		turn_ended.emit()

func get_ai_points() -> int:
	var total = 0
	for card in battlefield.get_children():
		total += card.card_power
	return total
