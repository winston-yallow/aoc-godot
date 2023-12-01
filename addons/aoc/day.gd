class_name Day
extends RefCounted


func solve(part: int, input: String) -> String:
	match part:
		1: return solve_first(input)
		2: return solve_second(input)
	return "ERROR"


func solve_first(input: String) -> String:
	return input


func solve_second(input: String) -> String:
	return input
