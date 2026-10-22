extends Node2D

var card_scene = preload("res://scenes/Card.tscn")
var current_state = GameState.START
var card_pool = []
var ai_cards
var screen_size: Vector2
var player_passed: bool
var ai_passed: bool

enum GameState{
	START,
	PLAYER_TURN,
	AI_TURN,
	END_TURN,
	END_GAME
}

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	card_pool = [
		create_card('Geralt', 15, 'melee'),
		create_card('Yennefer', 12, 'ranged'),
		create_card('Ciri', 10, 'melee'),
		create_card('Triss', 8, 'ranged'),
		create_card('Zoltan', 6, 'melee'),
		create_card('Radowid V', 10, 'melee'),
		create_card('Balista', 6, 'siege'),
		create_card('Ariete', 5, 'siege'),
		create_card('Carpeado', 3, 'melee'),
		create_card('Vesemir', 10, 'melee')
	]
	card_pool.shuffle()
	var player_cards = card_pool.slice(0, 5)
	ai_cards = card_pool.slice(5, 10)
	
	var total_cards = card_pool.size()
	var total_width = player_cards.size() * 90
	var x_pos = (screen_size.x / 2) - (total_width / 2)
	start_game()
	
	var i = 0
	for data in player_cards:
		var card = card_scene.instantiate()
		card.card_name = data.card_name
		card.card_power = data.card_power
		card.position = Vector2(x_pos + (i * 90), (screen_size.y - 180))
		card.card_clicked.connect(_on_card_clicked)
		$Hand.add_child(card)
		i += 1

func create_card(name: String, power: int, type: String) -> CardData:
	var data = CardData.new()
	data.card_name = name
	data.card_power = power
	data.card_type = type
	return data

func _on_card_clicked(card) -> void:
	if current_state == GameState.PLAYER_TURN:
		card.in_field = true
		$Hand.remove_child(card)
		$BattleField.add_child(card)
		var count  = $BattleField.get_child_count()
		card.position = Vector2((screen_size.x / 2) + (count - 1) * 90 - 180, screen_size.y * 0.71)
		change_turn()
		calculate_points()
		ai_turn()

func start_game():
	var rand = randi() % 2
	if rand == 1:
		current_state = GameState.PLAYER_TURN
		$Turn.text = "Players Turn"
	else:
		current_state = GameState.AI_TURN
		$Turn.text = "AI's Turn"
		ai_turn()

func ai_turn():
	if ai_cards.size() > 0:
		var rand_index = randi() % ai_cards.size()
		var chosen_card = ai_cards[rand_index]
		var card = card_scene.instantiate()
		var count = $AIBattleField.get_child_count()
		card.card_name = chosen_card.card_name
		card.card_power = chosen_card.card_power
		await get_tree().create_timer(1.0).timeout
		$AIBattleField.add_child(card)
		card.position = Vector2((screen_size.x / 2) + (count - 1) * 90 - 180, screen_size.y * 0.4)
		ai_cards.erase(chosen_card)
		calculate_points()
		change_turn()

func change_turn():
	if current_state == GameState.PLAYER_TURN:
		current_state = GameState.AI_TURN
		$Turn.text = "AI's Turn"
	else:
		current_state = GameState.PLAYER_TURN
		$Turn.text = "Players Turn"

func calculate_points() -> void:
	var total = 0
	for card  in $BattleField.get_children():
		total += card.card_power
	$Points.text = "Pontuacao: " + str(total)
	
	var ai_total = 0
	for card  in $AIBattleField.get_children():
		ai_total += card.card_power
	$AIPoints.text = "Pontuacao: " + str(ai_total)

func _on_pass_turn_pressed() -> void:
	if current_state == GameState.PLAYER_TURN:
		if player_passed != true:
			player_passed = true
			change_turn()
		else:
			pass
	else:
		change_turn()

func game_over():
	pass
