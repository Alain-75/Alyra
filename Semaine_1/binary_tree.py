class BinaryNode:
	def __init__(self, value, left = None, right = None):
		self._left = left
		self._right = right
		self._value = value


	def infix_serialize(self):
		if self._left is None:
			return str(self._value)
		if self._right is None:
			return "{} {}".format(self._left.infix_serialize(), self._value)
		return "{} {} {}".format(self._left.infix_serialize(), self._value, self._right.infix_serialize())


	def prefix_serialize(self):
		if self._left is None:
			return str(self._value)
		if self._right is None:
			return "{} {}".format(self._value, self._left.prefix_serialize())
		return "{} {} {}".format(self._value, self._left.prefix_serialize(), self._right.prefix_serialize())


	def postfix_serialize(self):
		if self._left is None:
			return str(self._value)
		if self._right is None:
			return "{} {}".format(self._left.postfix_serialize(), self._value)
		return "{} {} {}".format(self._left.postfix_serialize(), self._right.postfix_serialize(), self._value)


	def find(self, labels):
		if not labels:
			return self

		if self._left is not None and str(self._left._value) == labels[0]:
			return self._left.find(labels[1:])

		if self._right is not None and str(self._right._value) == labels[0]:
			return self._right.find(labels[1:])

		return None


	def pop_left_child(self):
		if self._left._left is None:
			result, self._left = self._left, None
			return result
		if self._left._right is None:
			result, self._left = self._left, self._left._left
			return result
		result, self._left = self._left, self._left._right
		return result


	def pop_right_child(self):
		if self._right._left is None:
			result, self._right = self._right, None
			return result
		result, self._right = self._right, self._right._left
		return result



class BinaryTree:
	def __init__(self, value, left = None, right = None):
		self._root = BinaryNode(value, left, right)


	def find_labels(self, labels):
		if not labels:
			return None

		if str(self._root._value) == labels[0]:
			return self._root.find(labels[1:])

		return None


	def find(self, path):
		return self.find_labels(path.split(' '))


	def pop(self, path):
		labels = path.split(' ')

		if not labels:
			return None

		parent = self.find_labels(labels[:-1])

		if str(parent._left._value) == labels[-1]:
			return parent.pop_left_child()

		if str(parent._right._value) == labels[-1]:
			return parent.pop_right_child()
