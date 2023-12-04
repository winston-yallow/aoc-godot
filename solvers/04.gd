extends Day


class Card:
	var instances: int = 1
	var winning_numbers: Array[int]
	var numbers_we_have: Array[int]
	func is_match(number: int) -> bool:
		return number in winning_numbers
	func matches() -> int:
		return numbers_we_have.filter(is_match).size()


func to_int(text: String) -> int:
	return text.to_int()


func to_int_array(strings: PackedStringArray) -> Array[int]:
	# This method only exists to do some obscure type casting magic
	var result: Array[int] = []
	result.assign(Array(strings).map(to_int))
	return result


func parse(input: String) -> Array[Card]:
	var result: Array[Card] = []
	for line in input.split("\n"):
		var split := line.split(":")[1].split("|")
		var card := Card.new()
		card.winning_numbers = to_int_array(split[0].split(" ", false))
		card.numbers_we_have = to_int_array(split[1].split(" ", false))
		result.append(card)
	return result


func solve_first(input: String) -> String:
	var sum := 0
	for card in parse(input):
		var matches := card.matches()
		if matches != 0:
			@warning_ignore("narrowing_conversion")
			sum += pow(2, matches - 1)
	return str(sum)


func solve_second(input: String) -> String:
	var cards := parse(input)
	for idx in cards.size():
		var card := cards[idx]
		var matches := card.matches()
		for lookahead in range(idx + 1, idx + matches + 1):
			var future_card := cards[lookahead]
			future_card.instances += card.instances
	return str(cards.reduce(func(acc, card): return acc + card.instances, 0))
