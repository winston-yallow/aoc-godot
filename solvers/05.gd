extends Day


class Almanac extends RefCounted:
	var _seeds := PackedInt64Array()
	var _destinations: Array[PackedInt64Array] = []
	var _sources: Array[PackedInt64Array] = []
	var _lengths: Array[PackedInt64Array] = []
	
	func _init(input: String) -> void:
		var first_split := input.split("\n", false, 1)
		
		var seed_strings := Array(first_split[0].split(":")[1].split(" ", false))
		_seeds = PackedInt64Array(seed_strings.map(func(i): return i.to_int()))
		
		var mapping_idx := -1
		var mapping_lines := first_split[1].split("\n", false)
		for line in mapping_lines:
			if ":" in line:
				mapping_idx += 1
				_destinations.append(PackedInt64Array())
				_sources.append(PackedInt64Array())
				_lengths.append(PackedInt64Array())
			else:
				var items := line.split(" ", false)
				_destinations[mapping_idx].append(items[0].to_int())
				_sources[mapping_idx].append(items[1].to_int())
				_lengths[mapping_idx].append(items[2].to_int())
	
	func mappings_count() -> int:
		return _destinations.size()
	
	func get_mapped_value(mapping_idx: int, input_value: int) -> int:
		for idx in _destinations[mapping_idx].size():
			var source := _sources[mapping_idx][idx]
			var length := _lengths[mapping_idx][idx]
			if input_value >= source and input_value < source + length:
				return _destinations[mapping_idx][idx] + (input_value - source)
		return input_value
	
	func get_unmapped_value(mapping_idx: int, value: int) -> int:
		for idx in _destinations[mapping_idx].size():
			var dest := _destinations[mapping_idx][idx]
			var length := _lengths[mapping_idx][idx]
			if value >= dest and value < dest + length:
				return _sources[mapping_idx][idx] + (value - dest)
		return value
	
	func get_seeds() -> PackedInt64Array:
		return _seeds


func solve_first(input: String) -> String:
	var almanac := Almanac.new(input)
	var lowest := -1
	for value in almanac.get_seeds():
		for mapping_idx in almanac.mappings_count():
			value = almanac.get_mapped_value(mapping_idx, value)
		if lowest == -1 or lowest > value:
			lowest = value
	return str(lowest)


func solve_second(input: String) -> String:
	# This will run for a long time and is basically a brute force approach.
	# I do run over this in reverse though, so I iterate the locations starting
	# from 0. This way I don't need to check all input seeds to find the nearest
	# location. It seems to be a bit faster, but not by a lot. This probably
	# also depends on the input data. The smaller the solution is, the faster
	# this will run.
	
	var almanac := Almanac.new(input)
	var seeds := almanac.get_seeds()
	
	var reversed_mappings := range(almanac.mappings_count())
	reversed_mappings.reverse()
	
	var location := 0
	while location < 9223372036854775806:
		var value := location
		for mapping_idx in reversed_mappings:
			value = almanac.get_unmapped_value(mapping_idx, value)
		for idx in range(0, seeds.size(), 2):
			var first := seeds[idx]
			var last := seeds[idx] + seeds[idx+1] - 1
			if value >= first and value <= last:
				return str(location)
		location += 1
	
	return "No solution found"
