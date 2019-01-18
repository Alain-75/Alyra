#!/usr/bin/python3.6

import sys


def do_add(op1, op2):
	return op1 + op2


def do_sub(op1, op2):
	return op1 - op2


def do_mul(op1, op2):
	return op1 * op2


def do_div(op1, op2):
	return op1 / op2


def do_les(op1, op2):
	return op1 < op2


def do_mor(op1, op2):
	return op1 > op2


def do_equ(op1, op2):
	return op1 == op2



class StackMachine:
	OPERATIONS = {
		'+' : do_add,
		'-' : do_sub,
		'*' : do_mul,
		'x' : do_mul,
		'/' : do_div,
		'<' : do_les,
		'>' : do_mor,
		'=' : do_equ
	}


	def __init__(self):
		self._stack = []


	def push(self, op):
		try:
			self._stack.append(StackMachine.OPERATIONS[op])
		except KeyError:
			try:
				self._stack.append(int(op))
			except ValueError:
				try:
					self._stack.append(float(op))
				except ValueError:
					raise ValueError("Unknown operator: '{}'".format(op))


	def solve(self):
		while len(self._stack) > 2:
			operand_1 = self._stack.pop()

			if callable(operand_1):
				raise ValueError("Missing operand")

			operand_2 = self._stack.pop()

			if callable(operand_2):
				raise ValueError("Missing operand")

			operator = self._stack.pop()

			if not callable(operator):
				raise ValueError("Missing operator for ({}, {})".format(operand_1, operand_2))

			self._stack.append(operator(operand_1, operand_2))

		if len(self._stack) == 1:
			return self._stack.pop()

		raise ValueError("Invalid syntax")


def handle_input(inp, machine):
	inp = inp.split()

	for op in reversed(inp):
		machine.push(op)

	result = machine.solve()
	print(result)


def main():
	loop = True
	machine = StackMachine()

	while loop:
		try:
			inp = input('? ')
		except EOFError:
			print()
			break

		handle_input(inp, machine)


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
