extends MeshInstance

func _ready():
	reload()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		reload()

func reload():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# st.add_smooth_group(true)
	
	var steps = 1
	
	var u = Vector3(1.0, 0, 0)
	var v = Vector3(1.0 / 2.0, sqrt(3.0) / 2.0, 0)
	var w = Vector3(1.0 / 2.0, 1.0 / (2.0 * sqrt(3.0)), sqrt(2.0 / 3.0))
	
	var s = -(u + v + w) / 4.0
	
	for i in range(0, 2 * steps + 1):
		for j in range(0, 2 * steps + 1 - i):
			var x: float
			var y: float
			var dx: Vector3
			var dy: Vector3
			var corner: Vector3
			
			# Bottom-Left of square
			if i + j < steps:
				corner = s
				dx = u
				dy = v
				x = float(i) / float(steps)
				y = float(j) / float(steps)
			
			# Top-Right of square
			elif i <= steps and j <= steps:
				corner = s + v
				dx = w - v
				dy = u - w
				x = float(i) / float(steps)
				y = float(steps - j) / float(steps)
			# Bottom-right triangle
			elif i > steps:
				corner = s + u
				dx = -u
				dy = w - u
				x = float(i - steps) / float(steps)
				y = float(j) / float(steps)
			
			# Top-left triangle
			else:
				corner = s + v
				dx = w - v
				dy = -v
				x = float(x) / float(steps)
				y = float(j - steps) / float(steps)
				
			print(i, j, corner + dx * x + dy * y)
			st.add_vertex(corner + dx * x + dy * y)
	
	st.generate_normals()
	
	mesh = st.commit()
	mesh.surface_set_material(0, SpatialMaterial.new())
