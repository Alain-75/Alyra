#!/usr/bin/python3.6

import sys
import argparse
import hashlib


def reverse_hex_string(hex_string):
	reverse_string = ""
	for i in range(0, len(hex_string), 2):
		reverse_string = hex_string[i:i+2] + reverse_string
	return reverse_string


def parse_varInt(hex_string):
	first_byte = int(hex_string[:2], 16)

	if first_byte < 0xfd:
		return 1, first_byte
	elif first_byte == 0xfd:
		return 3, int(reverse_hex_string(hex_string[2:6]), 16)
	elif first_byte == 0xfe:
		return 5, int(reverse_hex_string(hex_string[2:10]), 16)
	elif first_byte == 0xff:
		return 9, int(reverse_hex_string(hex_string[2:18]), 16)


def parse_variable_length_string(hex_string):
	varInt_size, str_len = parse_varInt(hex_string)
	start = 2*varInt_size
	end = start + 2*str_len
	return hex_string[start:end], hex_string[end:]



class Stack:
	def __init__(self):
		self._stack = []


	def pop(self): return self._stack.pop()
	def peek(self): return self._stack[-1]
	def push(self, value): self._stack.append(value)



class Operation:
	def __init__(self, name):
		self._name = name


	def pop_value(self, stack):
		try:
			value = stack.pop()
		except IndexError:
			raise IndexError("Missing value for operation {}".format(self._name))

		return value


	def pop_two_values(self, stack):
		try:
			value2 = stack.pop()
			value1 = stack.pop()
		except IndexError:
			raise IndexError("Missing value for operation {}".format(self._name))

		return value1, value2



class op_0(Operation):
	def __init__(self) :
		super(op_0, self).__init__("op_0")


	def apply(self, stack):
		stack.push("00")



class op_1(Operation):
	def __init__(self) :
		super(op_1, self).__init__("op_1")


	def apply(self, stack):
		stack.push("01")



class op_dup(Operation):
	def __init__(self) :
		super(op_dup, self).__init__("op_dup")


	def apply(self, stack):
		stack.push(stack.peek())



class op_add(Operation):
	def __init__(self) :
		super(op_add, self).__init__("op_add")


	def apply(self, stack):
		v1, v2 = self.pop_two_values(stack)
		stack.push( (int(v1, 16)+int(v2, 16)).hex() )



class op_equalverify(Operation):
	def __init__(self) :
		super(op_equalverify, self).__init__("op_equalverify")


	def apply(self, stack):
		v1, v2 = self.pop_two_values(stack)
		if v1 != v2:
			raise ValueError("op_equalverify {} != {}".format(v1, v2))



class op_hash160(Operation):
	def __init__(self) :
		super(op_hash160, self).__init__("op_hash160")


	def apply(self, stack):
		sha = hashlib.sha256()
		ripemd160 = hashlib.new('ripemd160')
		hex_value = self.pop_value(stack)
		sha.update(bytearray.fromhex(hex_value))
		ripemd160.update(sha.digest())
		stack.push(ripemd160.hexdigest())



class op_checksig(Operation):
	def __init__(self) :
		super(op_checksig, self).__init__("op_checksig")


	def apply(self, stack):
		self.pop_two_values(stack)
		stack.push(True)



class op_checklocktimeverify(Operation):
	def __init__(self) :
		super(op_checklocktimeverify, self).__init__("op_checklocktimeverify")


	def apply(self, stack):
		pass




class StackMachine:
	OPERATIONS = {
		'00' : op_0(),
		'51' : op_1(),
		'76' : op_dup(),
		'93' : op_add(),
		'88' : op_equalverify(),
		'a9' : op_hash160(),
		'ac' : op_checksig(),
		'b1' : op_checklocktimeverify()
	}


	def __init__(self):
		self._stack = Stack()


	def push_value(self, value):
		self._stack.push(value)


	def handle_operation(self, op):
		StackMachine.OPERATIONS[op].apply(self._stack)


	def push(self, hex_string):
		try:
			self.handle_operation(hex_string[:2])
			return hex_string[2:]
		except KeyError:
			pass # l'opération est inconnu, on suppose qu'il s'agit d'une valeur

		result, tail = parse_variable_length_string(hex_string)
		self.push_value(result)
		return tail



def check_p2pkh(scriptSig, scriptPubKey):
	machine = StackMachine()
	sig, scriptSig = parse_variable_length_string(scriptSig)
	pub, scriptSig = parse_variable_length_string(scriptSig)

	machine.push_value(sig)
	machine.push_value(pub)

	while scriptPubKey:
		scriptPubKey = machine.push(scriptPubKey)

	return machine._stack.pop()



def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("path", help="path to file containing a spaced separated sciptSig and scriptPubKey couple on each line", type=str)
	args = parser.parse_args()

	results = []

	with open(args.path) as file:
		for line in file:
			values = line.split()
			results.append(check_p2pkh(values[0], values[1]))

	print(results)


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
