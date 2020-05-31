extends Node

func random_normal(mean, stddev):
	var U1 = randf()
	var U2 = randf()
	
	return sqrt(-2 * log(U1)) * cos(2 * PI * U2) * stddev + mean
