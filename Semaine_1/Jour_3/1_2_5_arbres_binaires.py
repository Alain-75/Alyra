#!/usr/bin/python3.6

##########################################################
#
# Voir le fichier binary_tree.py pour l'implémentation.
#
##########################################################

from binary_tree import BinaryNode as Node
from binary_tree import BinaryTree as Tree

import unittest



class TestTree(unittest.TestCase):
	def setUp(self):
		self._sub_tree = Node( "A",
			Node( "W",
				Node(1),
				Node(2)
				),
			Node( "X",
				Node(3),
				Node(4)
				)
			)

		self._tree = Tree( "R",
			self._sub_tree,
			Node( "B",
				Node( "Y",
					Node(5),
					Node(6)
					),
				Node( "Z",
					Node(7)
					)
				),
			)


	# Écrire la méthode pour afficher l’arbre selon un parcours infixe
	def test_infix(self):
		self.assertEqual(self._tree._root.infix_serialize(), "1 W 2 A 3 X 4 R 5 Y 6 B 7 Z")


	def test_prefix(self):
		self.assertEqual(self._tree._root.prefix_serialize(), "R A W 1 2 X 3 4 B Y 5 6 Z 7")


	def test_postfix(self):
		self.assertEqual(self._tree._root.postfix_serialize(), "1 2 W 3 4 X A 5 6 Y 7 Z B R")


	# Définir la méthode pour trouver une valeur donnée dans un arbre binaire de recherche
	def test_find(self):
		self.assertIs(self._tree.find("R A"), self._sub_tree)
		self.assertIsNone(self._tree.find("R A B C"))
		self.assertIsNotNone(self._tree.find("R A X 4"))
		self.assertIsNone(self._tree.find("R A X 5"))
		self.assertIsNone(self._tree.find("R A X 4 7"))


	# Écrire la méthode pour supprimer un noeud donné en distinguant trois cas : 
	def test_pop(self):
		self.assertIs(self._tree.pop("R A"), self._sub_tree)
		# les noeuds A et W ont été supprimés
		self.assertEqual(self._tree._root.infix_serialize(), "3 X 4 R 5 Y 6 B 7 Z")
		self._tree.pop("R B Z 7")
		self.assertEqual(self._tree._root.infix_serialize(), "3 X 4 R 5 Y 6 B Z")


if __name__ == '__main__':
	unittest.main()
