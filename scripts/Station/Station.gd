extends StaticBody
class_name SpatialStation

# Universe object
var dual: Station

export(float, 0, 10) var max_docking_velocity = 0.2
export(float, 0, 20) var platform_width = 10.0
export(float, 0, 3) var orientation_tolerance = PI / 8.0
export(float, 0, 3) var angle_tolerance = PI / 12.0

var dock

func _ready():
	dock = $OpenDock

func set_player_pos(_player_pos):
	pass
