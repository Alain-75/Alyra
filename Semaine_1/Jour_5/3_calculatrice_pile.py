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


	def push_value(self, value):
		self._stack.append(value)


	def handle_operation(self, op):
		try:
			operator = StackMachine.OPERATIONS[op]
		except KeyError:
			raise ValueError("Unknown operator: '{}'".format(op))

		try:
			operand_2 = self._stack.pop()
			operand_1 = self._stack.pop()
		except IndexError:
			raise IndexError("Missing operands for operation '{}'".format(op))

		return operator(operand_1, operand_2)


	def push(self, op):
		try:
			self.push_value(int(op))
		except ValueError:
			try:
				self.push_value(float(op))
			except ValueError:
				self.push_value(self.handle_operation(op))



def handle_input(inp, machine):
	inp = inp.split()

	for op in inp:
		print(machine._stack)
		machine.push(op)

	print(machine._stack)
	stack = machine._stack

	if len(stack) == 1:
		print("=> {}".format(stack.pop()))


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
