extends Node

static var levels: Array = []
static var seed
static var start_speed
static var goal_speed


func _ready():
	load_levels("res://dungeons.json")  # path to your JSON file
	print("Loaded %d levels" % levels.size())

static func load_levels(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Failed to open JSON file!")
		return
	
	var content = file.get_as_text()
	file.close()

	var result = JSON.parse_string(content)
	if not result:
		print("Failed to parse JSON")
		return
	
	var json_data = result
	
	# Seed or timing info
	seed = json_data.get("seed", 0)
	start_speed = json_data.get("starting_answer_speed_sec", 10)
	goal_speed = json_data.get("goal_answer_speed_sec", 2)
	
	
	var emptyArray: Array[String] = []
	var json_cards = json_data.get("themed_cards", emptyArray)
	var typed_cards: Array[String] = []
	for c in json_cards:
		typed_cards.append(str(c))  # ensure every element is a string
	
	# Load dungeons
	for dungeon in json_data.get("dungeons", []):
		var lvl = Level.new(
			dungeon.get("name", "Unknown Dungeon"),
			dungeon.get("theme", "Unknown Theme"),
			Level.LevelType.STANDARD,
			dungeon.get("boss_name", ""),
			start_speed,  # or any logic to set time_to_answer_sec
			typed_cards
		)
		levels.append(lvl)
		
		# Add extra drill levels if needed
		for i in range(dungeon.get("themed_drill_levels", 0)):
			var drill_lvl = Level.new(
				dungeon.get("name") + " Drill " + str(i+1),
				dungeon.get("theme"),
				Level.LevelType.STANDARD,
				"",
				start_speed,
				dungeon.get("themed_cards", [])
			)
			levels.append(drill_lvl)
	
	# Load final dungeon
	var final = json_data.get("final_dungeon", null)
	if final:
		var final_level = Level.new(
			final.get("name", "Final Dungeon"),
			final.get("theme", "Unknown"),
			Level.LevelType.BOSS,
			final.get("boss_name", "The Final Boss"),
			start_speed,
			[]  # final dungeon may not have themed cards
		)
		levels.append(final_level)
