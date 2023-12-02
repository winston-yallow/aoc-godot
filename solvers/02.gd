extends Day


class Game:
	var game_id: int
	var sets: Array[Dictionary]
	func _init(line: String) -> void:
		var split_line := line.split(":", true, 1)
		game_id = split_line[0].rsplit(" ", true, 1)[-1].to_int()
		sets = []
		for set_string in split_line[1].split(';'):
			var set_split := set_string.split(',')
			var set_dict := {}
			for item in set_split:
				var item_split := item.split(" ", false, 1)
				set_dict[item_split[-1]] = item_split[0].to_int()
			sets.append(set_dict)


func solve_first(input: String) -> String:
	var limits := {"red": 12, "green": 13, "blue": 14}
	var sum := 0
	for game in parse(input):
		var possible = true
		for subset in game.sets:
			for color in subset:
				if subset[color] > limits[color]:
					possible = false
		if possible:
			sum += game.game_id
	return str(sum)


func solve_second(input: String) -> String:
	var sum := 0
	for game in parse(input):
		var min_cubes := {}
		for subset in game.sets:
			for color in subset:
				min_cubes[color] = max(subset[color], min_cubes.get(color, 0))
		sum += min_cubes.values().reduce(func(acc, num): return acc * num, 1)
	return str(sum)


func parse(input: String) -> Array[Game]:
	var games: Array[Game] = []
	for line in input.split("\n"):
		games.append(Game.new(line))
	return games
