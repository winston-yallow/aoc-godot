extends Day


const WORD_MAPPING := {
	"one": "1",
	"two": "2",
	"three": "3",
	"four": "4",
	"five": "5",
	"six": "6",
	"seven": "7",
	"eight": "8",
	"nine": "9",
}


func solve_first(input: String) -> String:
	var sum = 0
	for line in input.split("\n"):
		var number_chars := Array(line.split()).filter(is_digit)
		sum += (number_chars[0] + number_chars[-1]).to_int()
	return str(sum)


func solve_second(input: String) -> String:
	var sum = 0
	for line in input.split("\n"):
		var first := find_number(line, false)
		var last := find_number(line, true)
		sum += (first + last).to_int()
	return str(sum)


func is_digit(character: String) -> bool:
	return character.is_valid_int()


func find_number(text: String, reversed := false) -> String:
	var result := ""
	var indices := range(len(text)-1, -1, -1) if reversed else range(len(text))
	for idx in indices:
		if text[idx].is_valid_int():
			result = text[idx]
			break
		var substr := text.substr(0, idx + 1) if reversed else text.substr(idx)
		for word in WORD_MAPPING:
			var forward_match := not reversed and substr.begins_with(word)
			var backward_match := reversed and substr.ends_with(word)
			if forward_match or backward_match:
				result = WORD_MAPPING[word]
				break
		if not result.is_empty():
			break
	return result
