extends CanvasLayer
const CardsHandler = preload("uid://e7w6qsc3hve7")
const LevelsHandler = preload("uid://c37rolgf3jd07")

func _ready():
	CardsHandler.openCards("res://persistentData/multiplication/cards.json")
	LevelsHandler.load_levels("res://persistentData/multiplication/level.json")
	#print("")
	#for i in range(0,100):
		#print(CardsHandler.randomCard("5s").toString())
	#
	
