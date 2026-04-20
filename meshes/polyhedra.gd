class_name Polyhedra extends RefCounted

# Procedural mesh builders for the Geometry Quest aesthetic.
# All functions are static; all return fresh ArrayMesh instances with
# per-face duplicated vertices for sharp normals.
#
# Bible reference: SPEC.md §20.2.


static func tetrahedron(edge: float = 1.0) -> ArrayMesh:
	# Regular tetrahedron — 4 alternating corners of a cube.
	var s: float = edge / (2.0 * sqrt(2.0))
	var v: Array[Vector3] = [
		Vector3(1, 1, 1) * s,
		Vector3(1, -1, -1) * s,
		Vector3(-1, 1, -1) * s,
		Vector3(-1, -1, 1) * s,
	]
	# CCW outward faces: each face is opposite one vertex.
	var tris: Array = [
		[v[1], v[3], v[2]],  # opposite v0
		[v[0], v[2], v[3]],  # opposite v1
		[v[0], v[3], v[1]],  # opposite v2
		[v[0], v[1], v[2]],  # opposite v3
	]
	return _from_triangles(tris)


static func cube(size: float = 1.0) -> ArrayMesh:
	var h: float = size * 0.5
	var v: Array[Vector3] = [
		Vector3(-h, -h, -h), Vector3( h, -h, -h),
		Vector3( h,  h, -h), Vector3(-h,  h, -h),
		Vector3(-h, -h,  h), Vector3( h, -h,  h),
		Vector3( h,  h,  h), Vector3(-h,  h,  h),
	]
	# CCW outward per face.
	var tris: Array = [
		# -Z (front of Godot default)
		[v[0], v[2], v[1]], [v[0], v[3], v[2]],
		# +Z
		[v[5], v[6], v[4]], [v[6], v[7], v[4]],
		# -X
		[v[4], v[3], v[0]], [v[4], v[7], v[3]],
		# +X
		[v[1], v[2], v[5]], [v[2], v[6], v[5]],
		# -Y
		[v[0], v[1], v[5]], [v[0], v[5], v[4]],
		# +Y
		[v[3], v[7], v[2]], [v[7], v[6], v[2]],
	]
	return _from_triangles(tris)


static func square_pyramid(base: float = 1.0, height: float = 1.0) -> ArrayMesh:
	# Used as the corruption motif per SPEC §20 / bible §3 4-sided.
	var h: float = base * 0.5
	var apex: Vector3 = Vector3(0, height, 0)
	var b: Array[Vector3] = [
		Vector3(-h, 0, -h), Vector3( h, 0, -h),
		Vector3( h, 0,  h), Vector3(-h, 0,  h),
	]
	var tris: Array = [
		# Four triangular sides, CCW outward.
		[b[0], b[1], apex],
		[b[1], b[2], apex],
		[b[2], b[3], apex],
		[b[3], b[0], apex],
		# Base (facing -Y), two triangles CCW from below.
		[b[0], b[3], b[2]],
		[b[0], b[2], b[1]],
	]
	return _from_triangles(tris)


static func pentagonal_star(outer: float = 1.0, inner: float = 0.382, depth: float = 0.2) -> ArrayMesh:
	# 10-pointed star prism (5-pointed star extruded).
	var pts_top: Array[Vector3] = []
	var pts_bot: Array[Vector3] = []
	var half_d: float = depth * 0.5
	for i in range(10):
		var angle: float = TAU * float(i) / 10.0 - PI * 0.5
		var r: float = outer if i % 2 == 0 else inner
		pts_top.append(Vector3(cos(angle) * r, half_d, sin(angle) * r))
		pts_bot.append(Vector3(cos(angle) * r, -half_d, sin(angle) * r))
	var center_top: Vector3 = Vector3(0, half_d, 0)
	var center_bot: Vector3 = Vector3(0, -half_d, 0)
	var tris: Array = []
	for i in range(10):
		var n: int = (i + 1) % 10
		# Top fan CCW looking from +Y.
		tris.append([center_top, pts_top[n], pts_top[i]])
		# Bottom fan CCW looking from -Y.
		tris.append([center_bot, pts_bot[i], pts_bot[n]])
		# Side quad split into 2 triangles, CCW outward.
		tris.append([pts_top[i], pts_top[n], pts_bot[n]])
		tris.append([pts_top[i], pts_bot[n], pts_bot[i]])
	return _from_triangles(tris)


static func hexagonal_prism(radius: float = 1.0, height: float = 1.0) -> ArrayMesh:
	return _prism(radius, height, 6)


static func heptagon(radius: float = 1.0, thickness: float = 0.05) -> ArrayMesh:
	# Flat 7-sided prism — used by Heptagon Lens mesh.
	return _prism(radius, thickness, 7)


static func octagonal_prism(radius: float = 1.0, height: float = 1.0) -> ArrayMesh:
	return _prism(radius, height, 8)


static func merkaba(edge: float = 1.0) -> ArrayMesh:
	# Two interlocking regular tetrahedra sharing center = Star Tetrahedron.
	# Per SPEC §20.2 / bible: dual counter-rotating tetrahedra.
	var s: float = edge / (2.0 * sqrt(2.0))

	# Tet A: 4 alternating corners of the unit cube (even parity).
	var a0: Vector3 = Vector3(1, 1, 1) * s
	var a1: Vector3 = Vector3(1, -1, -1) * s
	var a2: Vector3 = Vector3(-1, 1, -1) * s
	var a3: Vector3 = Vector3(-1, -1, 1) * s

	# Tet B: the other 4 corners (odd parity).
	var b0: Vector3 = Vector3(-1, -1, -1) * s
	var b1: Vector3 = Vector3(-1, 1, 1) * s
	var b2: Vector3 = Vector3(1, -1, 1) * s
	var b3: Vector3 = Vector3(1, 1, -1) * s

	var tris: Array = [
		# Tet A faces CCW outward.
		[a1, a3, a2],
		[a0, a2, a3],
		[a0, a3, a1],
		[a0, a1, a2],
		# Tet B faces CCW outward.
		[b1, b2, b3],
		[b0, b3, b2],
		[b0, b1, b3],
		[b0, b2, b1],
	]
	return _from_triangles(tris)


static func sphere_proc(radius: float = 1.0, rings: int = 16, segments: int = 24) -> ArrayMesh:
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for r in range(rings):
		var phi0: float = PI * float(r) / float(rings)
		var phi1: float = PI * float(r + 1) / float(rings)
		for s in range(segments):
			var th0: float = TAU * float(s) / float(segments)
			var th1: float = TAU * float(s + 1) / float(segments)
			var p00: Vector3 = _sph(radius, phi0, th0)
			var p01: Vector3 = _sph(radius, phi0, th1)
			var p10: Vector3 = _sph(radius, phi1, th0)
			var p11: Vector3 = _sph(radius, phi1, th1)
			# Normals for a sphere = position normalized, smooth shading.
			_emit_tri_smooth(st, p00, p10, p11, radius)
			_emit_tri_smooth(st, p00, p11, p01, radius)
	return st.commit()


# ─── Internals ────────────────────────────────────────────────────────────

static func _prism(radius: float, height: float, sides: int) -> ArrayMesh:
	var half_h: float = height * 0.5
	var top: Array[Vector3] = []
	var bot: Array[Vector3] = []
	for i in range(sides):
		var angle: float = TAU * float(i) / float(sides)
		top.append(Vector3(cos(angle) * radius, half_h, sin(angle) * radius))
		bot.append(Vector3(cos(angle) * radius, -half_h, sin(angle) * radius))
	var center_top: Vector3 = Vector3(0, half_h, 0)
	var center_bot: Vector3 = Vector3(0, -half_h, 0)
	var tris: Array = []
	for i in range(sides):
		var n: int = (i + 1) % sides
		# Top cap CCW from +Y.
		tris.append([center_top, top[n], top[i]])
		# Bottom cap CCW from -Y.
		tris.append([center_bot, bot[i], bot[n]])
		# Side quad CCW outward.
		tris.append([top[i], top[n], bot[n]])
		tris.append([top[i], bot[n], bot[i]])
	return _from_triangles(tris)


static func _from_triangles(tris: Array) -> ArrayMesh:
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for t in tris:
		var a: Vector3 = t[0]
		var b: Vector3 = t[1]
		var c: Vector3 = t[2]
		var n: Vector3 = (b - a).cross(c - a).normalized()
		st.set_normal(n); st.set_uv(Vector2(0, 0)); st.add_vertex(a)
		st.set_normal(n); st.set_uv(Vector2(1, 0)); st.add_vertex(b)
		st.set_normal(n); st.set_uv(Vector2(0.5, 1)); st.add_vertex(c)
	return st.commit()


static func _sph(r: float, phi: float, theta: float) -> Vector3:
	return Vector3(r * sin(phi) * cos(theta), r * cos(phi), r * sin(phi) * sin(theta))


static func _emit_tri_smooth(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, r: float) -> void:
	st.set_normal(a.normalized()); st.set_uv(Vector2(0, 0)); st.add_vertex(a)
	st.set_normal(b.normalized()); st.set_uv(Vector2(1, 0)); st.add_vertex(b)
	st.set_normal(c.normalized()); st.set_uv(Vector2(0.5, 1)); st.add_vertex(c)
