#!/usr/bin/python3.6

##########################################################
#
# Voir le fichier elliptic.py pour l'implémentation.
#
##########################################################

from elliptic import EllipticCurve as Curve

import unittest
import math


class TestCurve(unittest.TestCase):
	def test_equality(self):
		self.assertEqual( Curve(5,3), Curve(5,3) )
		self.assertNotEqual( Curve(5,2), Curve(5,3) )


	def test_serialize(self):
		self.assertEqual( str(Curve(5,3)), "(5, 3)" )


	def test_has_point(self):
		self.assertFalse( Curve(5,3).test_point(0,1) )

		# y² = x³ + ax + b
		# Avec x = 1, a = 5, b = 3, on a:
		# y² = 1 + 5 + 3
		# y² = 9
		# y = 3
		self.assertTrue( Curve(5,3).test_point(1,3) )

		# y² = x³ + ax + b
		# Avec x = 2, a = 5, b = 3, on a:
		# y² = 8 + 10 + 3
		# y² = 21
		# y = sqrt(21)
		self.assertTrue( Curve(5,3).test_point(2, math.sqrt(21)) )


	def test_addition(self):
		A = (1, 3)
		B = (2, math.sqrt(21))

		try:
			C = Curve(5, 3).add_points(A, B)
		except ValueError:
			self.fail("add_points({}, {}) raised ValueError unexpectedly!".format(A, B))


if __name__ == '__main__':
	unittest.main()
