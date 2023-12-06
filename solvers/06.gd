extends Day


func array_from_line(line: String) -> Array[int]:
	var result: Array[int] = []
	var strings := Array(line.split(":")[1].split(" ", false))
	var integers := strings.map(func(i: String) -> int: return i.to_int())
	result.append_array(integers)
	return result


func number_from_line(line: String) -> int:
	var numbers := line.split(":")[1].replace(" ", "")
	return numbers.to_int()


func calc_minimum_holdtime(time: int, min_distance: int) -> int:
	return floor(0.5 * (time - sqrt(pow(time, 2) - 4 * min_distance))) + 1


func calc_maximum_holdtime(time: int, min_distance: int) -> int:
	return ceil(0.5 * (time + sqrt(pow(time, 2) - 4 * min_distance))) - 1


func solve_first(input: String) -> String:
	var times := array_from_line(input.split("\n")[0])
	var distances := array_from_line(input.split("\n")[1])
	var total := 1
	for idx in times.size():
		var time := times[idx]
		var distance := distances[idx]
		var hold_min := calc_minimum_holdtime(time, distance)
		var hold_max := calc_maximum_holdtime(time, distance)
		var diff := hold_max - hold_min + 1
		total *= diff
	return str(total)


func solve_second(input: String) -> String:
	var time := number_from_line(input.split("\n")[0])
	var distance := number_from_line(input.split("\n")[1])
	var hold_min := calc_minimum_holdtime(time, distance)
	var hold_max := calc_maximum_holdtime(time, distance)
	var diff := hold_max - hold_min + 1
	return str(diff)
