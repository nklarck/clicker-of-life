extends Node

func number_format(number: float) -> String:
	if number <1_001.0:
		return "%.1f" % (float(number))
	elif number <1_000_000.0:
		return "%.3f" % (number/1_000.0) + "K"
	elif number <1_000_000_000.0:
		return "%.3f" % (number/1_000_000.0) + "M"
	elif number <1_000_000_000_000.0:
		return "%.3f" % (number/1_000_000_000.0) + "B"
	else:
		return "%.3f" % (number/1_000_000_000_000.0) + "T"
