extends Node2D

var card_scene = preload("res://scenes/Card.tscn")
var current_state: GameState = GameState.START
var card_pool: Array[CardData]
var ai_cards: Array[CardData]
var screen_size: Vector2
var player_passed: bool
var player_lives: int = 2
var ai_lives: int = 2
var round_number: int = 1
var ai: AI

enum GameState {
	START,
	PLAYER_TURN,
	AI_TURN,
	END_TURN,
	END_GAME
}

enum GameResult {
	PLAYER_WIN,
	AI_WIN,
	DRAW
}

func _ready() -> void:
	ai = AI.new()
	ai.turn_ended.connect(change_turn)
	ai.round_ended.connect(end_turn)
	ai.points_updated.connect(calculate_points)
	screen_size = get_viewport().get_visible_rect().size
	card_pool = CardData.get_pool()
	deal_cards()
	ai.setup(card_scene, ai_cards, $AIBattleField, screen_size)
	start_game()

func deal_cards() -> void:
	card_pool.shuffle()
	var player_cards: Array[CardData] = card_pool.slice(0, 10)
	ai_cards = card_pool.slice(10, 20)
	var total_width = player_cards.size() * 90
	var x_pos = (screen_size.x / 2) - (total_width / 2)
	var i = 0
	for data in player_cards:
		var card: Card = card_scene.instantiate() as Card
		card.card_name = data.card_name
		card.card_power = data.card_power
		card.position = Vector2(x_pos + (i * 90), (screen_size.y - 180))
		card.card_clicked.connect(_on_card_clicked)
		$Hand.add_child(card)
		i += 1

func _on_card_clicked(card: Card) -> void:
	if current_state == GameState.PLAYER_TURN:
		card.in_field = true
		$Hand.remove_child(card)
		$BattleField.add_child(card)
		var count = $BattleField.get_child_count()
		card.position = Vector2((screen_size.x / 2) + (count - 1) * 90 - 180, screen_size.y * 0.71)
		change_turn()
		calculate_points()

func start_game() -> void:
	var rand = randi() % 2
	if rand == 1:
		current_state = GameState.PLAYER_TURN
		$Turn.text = "Players Turn"
	else:
		current_state = GameState.AI_TURN
		$Turn.text = "AI's Turn"
		ai.ai_turn(player_passed, get_player_points())

func change_turn() -> void:
	if current_state == GameState.END_GAME:
		return
	if current_state == GameState.PLAYER_TURN:
		current_state = GameState.AI_TURN
		$Turn.text = "AI's Turn"
		ai.ai_turn(player_passed, get_player_points())
	else:
		current_state = GameState.PLAYER_TURN
		$Turn.text = "Players Turn"

func get_player_points() -> int:
	var total = 0
	for card in $BattleField.get_children():
		total += card.card_power
	return total

func calculate_points() -> void:
	$Points.text = "Pontuacao: " + str(get_player_points())
	$AIPoints.text = "Pontuacao: " + str(ai.get_ai_points())

func reset_battlefield() -> void:
	player_passed = false
	ai.ai_passed = false
	if get_player_points() > ai.get_ai_points():
		current_state = GameState.AI_TURN
		$Turn.text = "AI's Turn"
	elif ai.get_ai_points() > get_player_points():
		current_state = GameState.PLAYER_TURN
		$Turn.text = "Players Turn"
	else:
		start_game()
	for card in $BattleField.get_children():
		card.queue_free()
	for card in $AIBattleField.get_children():
		card.queue_free()
	$Points.text = "Pontuacao: 0"
	$AIPoints.text = "Pontuacao: 0"

func end_turn() -> void:
	var player_points = get_player_points()
	var ai_points = ai.get_ai_points()
	if player_points > ai_points:
		ai_lives -= 1
		if ai_lives == 0:
			game_over(GameResult.PLAYER_WIN)
			return
		reset_battlefield()
	elif ai_points > player_points:
		player_lives -= 1
		if player_lives == 0:
			game_over(GameResult.AI_WIN)
			return
		reset_battlefield()
	else:
		ai_lives -= 1
		player_lives -= 1
		if player_lives == 0 and ai_lives == 0:
			game_over(GameResult.DRAW)
			return
		elif ai_lives == 0:
			game_over(GameResult.PLAYER_WIN)
			return
		elif player_lives == 0:
			game_over(GameResult.AI_WIN)
			return
		reset_battlefield()

func _on_pass_turn_pressed() -> void:
	if current_state == GameState.PLAYER_TURN:
		player_passed = true
		if ai.ai_passed == true:
			end_turn()
		else:
			change_turn()

func game_over(result: GameResult) -> void:
	if result == GameResult.PLAYER_WIN:
		$"Game Over".text = "GAME OVER\nVOCE VENCEU"
	elif result == GameResult.AI_WIN:
		$"Game Over".text = "GAME OVER\nO OPONENTE VENCEU"
	else:
		$"Game Over".text = "GAME OVER\nEMPATE"
	current_state = GameState.END_GAME
