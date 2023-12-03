extends Day
# Yes, this is absolutely over engineered. But I had fun!


class PartReference extends RefCounted:
	var line: int
	var position: int
	var length: int
	var text: String


class EngineParts extends RefCounted:
	var _width: int
	var _width_with_newline: int
	var _input: String
	
	enum DIR { LEFT = -1, BOTH = 0, RIGHT = +1 }
	
	func _init(input: String) -> void:
		_width = input.find("\n")
		_width_with_newline = _width + 1
		_input = input
	
	func get_char(line: int, pos: int) -> String:
		var index = (line * _width_with_newline) + pos
		if pos >= 0 and pos < _width and index >= 0 and index < _input.length():
			return _input[index]
		return ""
	
	func get_numbers(line: int, pos: int, dir: DIR) -> String:
		var index = (line * _width_with_newline) + pos
		
		# Early exit for out of bounds
		if pos < 0 or pos >= _width or index < 0 or index >= _input.length():
			return ""
		
		# Early exist if the requested position is not a number
		if not _input[index].is_valid_int():
			return ""
		
		var numbers := _input[index]
		if dir <= 0:
			var left_index = index - 1
			while left_index >= 0:
				if not _input[left_index].is_valid_int():
					break
				numbers = _input[left_index] + numbers
				left_index -= 1
		if dir >= 0:
			var right_index = index + 1
			while right_index < _input.length():
				if not _input[right_index].is_valid_int():
					break
				numbers += _input[right_index]
				right_index += 1
		
		return numbers
	
	func parts() -> PartIterator:
		return PartIterator.new(self)
	
	func gears() -> GearIterator:
		return GearIterator.new(self)


class PartIterator extends RefCounted:
	var _cursor: int
	var _engine_parts: EngineParts
	
	func _init(engine_parts: EngineParts) -> void:
		_engine_parts = engine_parts
	
	func _advance_to_next_number() -> void:
		while _cursor < _engine_parts._input.length():
			if _engine_parts._input[_cursor].is_valid_int():
				break
			_cursor += 1
	
	func _iter_init(_arg) -> bool:
		_advance_to_next_number()
		return _cursor < _engine_parts._input.length()
	
	func _iter_next(_arg) -> bool:
		_advance_to_next_number()
		return _cursor < _engine_parts._input.length()
	
	func _iter_get(_arg) -> PartReference:
		var numbers := ""
		var part := PartReference.new()
		@warning_ignore("integer_division")
		part.line = _cursor / _engine_parts._width_with_newline
		var pos_offset := part.line * _engine_parts._width_with_newline
		part.position = _cursor - pos_offset
		part.length = 0
		while _cursor < _engine_parts._input.length() and _engine_parts._input[_cursor].is_valid_int():
			part.length += 1
			numbers += _engine_parts._input[_cursor]
			_cursor += 1
		part.text = numbers
		return part


class GearIterator extends RefCounted:
	var _cursor: int
	var _engine_parts: EngineParts
	
	func _init(engine_parts: EngineParts) -> void:
		_engine_parts = engine_parts
	
	func _advance_to_next_gear() -> void:
		while _cursor < _engine_parts._input.length():
			if _engine_parts._input[_cursor] == "*":
				break
			_cursor += 1
	
	func _iter_init(_arg) -> bool:
		_advance_to_next_gear()
		return _cursor < _engine_parts._input.length()
	
	func _iter_next(_arg) -> bool:
		_advance_to_next_gear()
		return _cursor < _engine_parts._input.length()
	
	func _iter_get(_arg) -> PartReference:
		var part := PartReference.new()
		@warning_ignore("integer_division")
		part.line = _cursor / _engine_parts._width_with_newline
		var pos_offset := part.line * _engine_parts._width_with_newline
		part.position = _cursor - pos_offset
		part.length = 0
		part.text = "*"
		_cursor += 1
		return part


func solve_first(input: String) -> String:
	var sum := 0
	var engine_parts := EngineParts.new(input)
	for part in engine_parts.parts():
		var is_part := false
		for line in range(part.line - 1, part.line + 2):
			for pos in range(part.position - 1, part.position + part.length + 1):
				var c := engine_parts.get_char(line, pos)
				if not c.is_valid_int() and c != "." and not c.is_empty():
					is_part = true
					break
			if is_part: break
		if is_part:
			sum += part.text.to_int()
	return str(sum)


func solve_second(input: String) -> String:
	var sum := 0
	var engine_parts := EngineParts.new(input)
	for gear in engine_parts.gears():
		var numbers: Array[String] = []
		for line in range(gear.line - 1, gear.line + 2):
			var middle := engine_parts.get_numbers(line, gear.position, EngineParts.DIR.BOTH)
			if not middle.is_empty():
				numbers.append(middle)
				continue  # there can't be two distinct numbers if the center one exists
			var left := engine_parts.get_numbers(line, gear.position - 1, EngineParts.DIR.LEFT)
			if not left.is_empty():
				numbers.append(left)
			var right := engine_parts.get_numbers(line, gear.position + 1, EngineParts.DIR.RIGHT)
			if not right.is_empty():
				numbers.append(right)
		if numbers.size() == 2:
			sum += numbers[0].to_int() * numbers[1].to_int()
	return str(sum)
