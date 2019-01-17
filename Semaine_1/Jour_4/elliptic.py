
class EllipticCurve:
	def __init__(self, a, b):
		if 4*a**3+27*b**2 == 0 :
			raise ValueError('({}, {}) is not a valid curve'.format(a, b))

		self._a = a
		self._b = b


	# Ajouter à la classe courbe elliptique une fonction __eq__ qui permette de comparer si deux courbes sont équivalentes.
	def __eq__(self, other):
		return self._a == other._a and self._b == other._b


	# Ajouter une fonction qui retourne une chaîne de caractères avec les paramètres de la courbe
	def __str__(self):
		return '({}, {})'.format(self._a, self._b)


	def has_point(self, point):
		# vérifie si y² = x³ + ax + b
		x, y = point[0], point[1]
		return y**2 == x**3 + self._a*x + self._b


	# Ajouter une fonction testPoint(self,x, y ) qui  vérifie si un point appartient à la courbe
	def test_point(self, x, y):
		return self.has_point((x,y))


	def ensure_point(self, point):
		if not self.has_point(point):
			raise ValueError('{} is not a member of curve {}'.format(point, self))


	def add_points(self, A, B):
		self.ensure_point(A)
		self.ensure_point(B)
		# voir https://en.m.wikipedia.org/wiki/Elliptic_curve_point_multiplication
		l = (B[1] - A[1])/(B[0] - A[0])
		Cx = l**2 - A[0] - B[0]
		Cy = l*(A[0] - Cx) - A[1]
		C = (Cx, Cy)
		self.ensure_point(C)
		return C
