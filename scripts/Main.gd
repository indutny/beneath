extends Spatial

# TODO(indutny): persist this
var tick: int = 0

var buffered_time: float = 0

func _process(delta):
	buffered_time += delta
	while buffered_time >= 1:
		buffered_time -= 1
		tick += 1
		for station in $Universe/Stations.get_children():
			station.process_tick(tick)
