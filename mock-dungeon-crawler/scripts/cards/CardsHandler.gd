class_name CardsHandler extends Node
@onready var Card = preload("res://scripts/cards/Card.gd")  # 🔥 load your Card class

#A hashmap (dictionary)
var tag_dict = {}


func _ready():
	openCards("res://persistentData/multiplication/cards.json")


func openCards(jsonFile):
	var file = FileAccess.open(jsonFile, FileAccess.READ)
	if file:#If read succesfully
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		if data:#If we can get json data
			var cards = data["Cards"]
			print("Our deck:")
			for c in cards:
				var card = Card.new(
									c["Type"],
									c["Question"],
									str(c["Answer"]),  # 🪄 convert to string here
									c["Tags"]
								)

				for tag in card.tags:
					if not tag_dict.has(tag):
						tag_dict[tag] = []
					tag_dict[tag].append(card)

			# 🎉 Example: print all cards grouped by tag
			for tag in tag_dict.keys():
				print("Tag:", tag)
				for card in tag_dict[tag]:
					print("   ", card.string())
		else:
			print("Oops! JSON parsing failed!")
	else:
		print("Couldn't open file 😭")
