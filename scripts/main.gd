extends Node2D

var card_scene = preload("res://scenes/Card.tscn")
var current_state = GameState.START
var card_pool = []
var ai_cards
var screen_size: Vector2
var player_passed: bool
var ai_passed: bool
var player_lives: int = 2
var ai_lives: int = 2
var round_number: int = 1

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
	
	deal_cards()
	start_game()

func create_card(name: String, power: int, type: String) -> CardData:
	var data = CardData.new()
	data.card_name = name
	data.card_power = power
	data.card_type = type
	return data

func deal_cards():
	card_pool.shuffle()
	var player_cards = card_pool.slice(0, 5)
	ai_cards = card_pool.slice(5, 10)
	var total_cards = card_pool.size()
	var total_width = player_cards.size() * 90
	var x_pos = (screen_size.x / 2) - (total_width / 2)
	
	var i = 0
	for data in player_cards:
		var card = card_scene.instantiate()
		card.card_name = data.card_name
		card.card_power = data.card_power
		card.position = Vector2(x_pos + (i * 90), (screen_size.y - 180))
		card.card_clicked.connect(_on_card_clicked)
		$Hand.add_child(card)
		i += 1

func _on_card_clicked(card) -> void:
	if current_state == GameState.PLAYER_TURN:
		card.in_field = true
		$Hand.remove_child(card)
		$BattleField.add_child(card)
		var count  = $BattleField.get_child_count()
		card.position = Vector2((screen_size.x / 2) + (count - 1) * 90 - 180, screen_size.y * 0.71)
		change_turn()
		calculate_points()

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
	print("ai_turn chamado | ai_passed: ", ai_passed, " | player_passed: ", player_passed)
	if ai_passed:
		if player_passed:
			end_turn()
		else:
			change_turn()
		return
	if ai_cards.size() ==0:
		ai_passed = true
		if player_passed:
			end_turn()
		else:
			change_turn()
		return
	if player_passed and get_ai_points() > get_player_points():
		ai_passed = true
		end_turn()
		return
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
		if player_passed:
			ai_turn()
		else:
			change_turn()

func change_turn():
	if current_state == GameState.END_GAME:
		return
	if current_state == GameState.PLAYER_TURN:
		current_state = GameState.AI_TURN
		$Turn.text = "AI's Turn"
		ai_turn()
	else:
		current_state = GameState.PLAYER_TURN
		$Turn.text = "Players Turn"

func get_player_points() -> int:
	var total = 0
	for card in $BattleField.get_children():
		total += card.card_power
	return total

func get_ai_points() -> int:
	var total = 0
	for card in $AIBattleField.get_children():
		total += card.card_power
	return total

func calculate_points() -> void:
	$Points.text = "Pontuacao: " + str(get_player_points())
	$AIPoints.text = "Pontuacao: " + str(get_ai_points())

func reset_battlefield():
	player_passed = false
	ai_passed = false
	if get_player_points() > get_ai_points():
		current_state = GameState.PLAYER_TURN
		$Turn.text = "Players Turn"
	elif get_ai_points() > get_player_points():
		current_state = GameState.AI_TURN
		$Turn.text = "AI's Turn"
	else:
		start_game()
	for card in $BattleField.get_children():
		card.queue_free()
	for card in $AIBattleField.get_children():
		card.queue_free()
	for card in $Hand.get_children():
		card.queue_free()
	$Points.text = "Pontuacao: 0"
	$AIPoints.text = "Pontuacao: 0"
	deal_cards()

func end_turn():
	var player_points = get_player_points()
	var ai_points = get_ai_points()
	if player_points > ai_points:
		ai_lives -= 1
		if ai_lives == 0:
			game_over(true)
			return
		reset_battlefield()
	elif ai_points > player_points:
		player_lives -= 1
		if player_lives == 0:
			game_over(false)
			return
		reset_battlefield()
	else:
		ai_lives -=1
		player_lives -= 1
		if player_lives == 0 and ai_lives == 0:
			game_over(null)
			return
		elif ai_lives == 0:
			game_over(true)
			return
		elif player_lives == 0:
			game_over(false)
			return
		reset_battlefield()

func _on_pass_turn_pressed() -> void:
	print("pass pressionado | player_passed: ", player_passed, " | ai_passed: ", ai_passed)
	if current_state == GameState.PLAYER_TURN:
		player_passed = true
		if ai_passed == true:
			end_turn()
		else:
			change_turn()

func game_over(result) -> void:
	if result == true:
		$"Game Over".text = "GAME OVER\nVOCE VENCEU"
	elif result == false:
		$"Game Over".text = "GAME OVER\nO OPONENTE VENCEU"
	else:
		$"Game Over".text = "GAME OVER\nEMPATE"
	current_state = GameState.END_GAME
