extends Resource
class_name CardData

@export var card_name: String = ""
@export var card_power: int = 0
@export var card_type: String = "melee"

static func create_card(name: String, power: int, type: String) -> CardData:
	var data = CardData.new()
	data.card_name = name
	data.card_power = power
	data.card_type = type
	return data

static func get_pool() -> Array[CardData]:
	var pool: Array[CardData] = [
		create_card('Geralt', 15, 'melee'),
		create_card('Yennefer', 7, 'ranged'),
		create_card('Ciri', 15, 'melee'),
		create_card('Triss', 7, 'melee'),
		create_card('Zoltan', 5, 'melee'),
		create_card('Radowid V', 10, 'melee'),
		create_card('Ballista', 6, 'siege'),
		create_card('Ariete', 5, 'siege'),
		create_card('Carpeado', 3, 'melee'),
		create_card('Vesemir', 6, 'melee'),
		create_card('Dandelion', 2, 'ranged'),
		create_card('Emiel Regis', 5, 'melee'),
		create_card('Villentretenmerth', 7, 'melee'),
		create_card('Foltest', 10, 'melee'),
		create_card('Vernon Roche', 10, 'melee'),
		create_card('John Natalis', 10, 'melee'),
		create_card('Philippa Eilhart', 7, 'ranged'),
		create_card('Sigismund Dijkstra', 4, 'melee'),
		create_card('Thaler', 1, 'melee'),
		create_card('Blue Stripes Comm.', 4, 'melee'),
		create_card('Crinfrid Reaver', 5, 'ranged'),
		create_card('Catapult', 8, 'siege'),
		create_card('Siege Tower', 6, 'siege'),
		create_card('Poor F. Infantry', 1, 'melee')
	]
	return pool
