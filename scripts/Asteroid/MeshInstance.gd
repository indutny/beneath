extends MeshInstance

func create_surface(st: SurfaceTool,
	start: Vector3,
	width: Vector3,
	height: Vector3,
	steps: int):	
	var hsegment = width / float(steps)
	var vsegment = height / float(steps)
	
	for i in range(0, steps):
		var x = float(i) / float(steps)
		for j in range(0, steps):
			var y = float(j) / float(steps)

			var elevation = (randf() + 1) / 2
			
			var tl = start + i * hsegment + j * vsegment
			var tr = tl + hsegment
			var bl = tl + vsegment
			var br = tl + hsegment + vsegment
			
			tl *= elevation
			tr *= elevation
			bl *= elevation
			br *= elevation
			
			var utl = Vector2(x, y)
			var utr = Vector2(x + 1 / float(steps), y)
			var ubl = Vector2(x, y + 1 / float(steps))
			var ubr = Vector2(x + 1 / float(steps), y + 1 / float(steps))
			
			st.add_uv(utl)
			st.add_vertex(tl)
			st.add_uv(ubr)
			st.add_vertex(br)
			st.add_uv(utr)
			st.add_vertex(tr)
			
			st.add_uv(utl)
			st.add_vertex(tl)
			st.add_uv(ubl)
			st.add_vertex(bl)
			st.add_uv(ubr)
			st.add_vertex(br)

func _ready():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	create_surface(st, Vector3(-0.5, -0.5, 0.5), Vector3(1, 0, 0), Vector3(0, 1, 0), 10)
	create_surface(st, Vector3(0.5, -0.5, 0.5), Vector3(0, 0, -1), Vector3(0, 1, 0), 10)
	create_surface(st, Vector3(0.5, -0.5, -0.5), Vector3(-1, 0, 0), Vector3(0, 1, 0), 10)
	create_surface(st, Vector3(-0.5, -0.5, -0.5), Vector3(0, 0, 1), Vector3(0, 1, 0), 10)
	
	create_surface(st, Vector3(-0.5, -0.5, -0.5), Vector3(1, 0, 0), Vector3(0, 0, 1), 10)
	create_surface(st, Vector3(-0.5, 0.5, -0.5), Vector3(0, 0, 1), Vector3(1, 0, 0), 10)
	
	st.generate_normals()
	st.generate_tangents()
	mesh = st.commit()
	mesh.surface_set_material(0, SpatialMaterial.new())
