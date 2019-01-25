from sys import getsizeof as getsizeof


# cible(max) = ( (2¹⁶ - 1) * 2²⁰⁸
MAX_TARGET = (2**16 -1) * 2**208



class Stack:
	def __init__(self):
		self._stack = []


	def pop(self): return self._stack.pop()
	def peek(self): return self._stack[-1]
	def push(self, value): self._stack.append(value)



class ScriptStack:
	MIN_DATA_OPCODE = 1
	MAX_DATA_OPCODE = 75
	OP_PUSHDATA1 = 0x4c
	OP_PUSHDATA2 = 0x4d
	OP_PUSHDATA4 = 0x4e


	@staticmethod
	def is_implict_push(op):
		return op >= ScriptStack.MIN_DATA_OPCODE and op <= ScriptStack.MAX_DATA_OPCODE


	@staticmethod
	def is_explicit_push(op):
		if op == ScriptStack.OP_PUSHDATA1:
			return 1
		elif op == ScriptStack.OP_PUSHDATA2:
			return 2
		elif op == ScriptStack.OP_PUSHDATA4:
			return 4
		return False


	OPCODES = {
		# push value
		0x00 : 'OP_0',
		0x4c : 'OP_PUSHDATA1',
		0x4d : 'OP_PUSHDATA2',
		0x4e : 'OP_PUSHDATA4',
		0x4f : 'OP_1NEGATE',
		0x50 : 'OP_RESERVED',
		0x51 : 'OP_1',
		0x52 : 'OP_2',
		0x53 : 'OP_3',
		0x54 : 'OP_4',
		0x55 : 'OP_5',
		0x56 : 'OP_6',
		0x57 : 'OP_7',
		0x58 : 'OP_8',
		0x59 : 'OP_9',
		0x5a : 'OP_10',
		0x5b : 'OP_11',
		0x5c : 'OP_12',
		0x5d : 'OP_13',
		0x5e : 'OP_14',
		0x5f : 'OP_15',
		0x60 : 'OP_16',

		# control
		0x61 : 'OP_NOP',
		0x62 : 'OP_VER',
		0x63 : 'OP_IF',
		0x64 : 'OP_NOTIF',
		0x65 : 'OP_VERIF',
		0x66 : 'OP_VERNOTIF',
		0x67 : 'OP_ELSE',
		0x68 : 'OP_ENDIF',
		0x69 : 'OP_VERIFY',
		0x6a : 'OP_RETURN',

		# stack ops
		0x6b : 'OP_TOALTSTACK',
		0x6c : 'OP_FROMALTSTACK',
		0x6d : 'OP_2DROP',
		0x6e : 'OP_2DUP',
		0x6f : 'OP_3DUP',
		0x70 : 'OP_2OVER',
		0x71 : 'OP_2ROT',
		0x72 : 'OP_2SWAP',
		0x73 : 'OP_IFDUP',
		0x74 : 'OP_DEPTH',
		0x75 : 'OP_DROP',
		0x76 : 'OP_DUP',
		0x77 : 'OP_NIP',
		0x78 : 'OP_OVER',
		0x79 : 'OP_PICK',
		0x7a : 'OP_ROLL',
		0x7b : 'OP_ROT',
		0x7c : 'OP_SWAP',
		0x7d : 'OP_TUCK',

		# splice ops
		0x7e : 'OP_CAT',
		0x7f : 'OP_SUBSTR',
		0x80 : 'OP_LEFT',
		0x81 : 'OP_RIGHT',
		0x82 : 'OP_SIZE',

		# bit logic
		0x83 : 'OP_INVERT',
		0x84 : 'OP_AND',
		0x85 : 'OP_OR',
		0x86 : 'OP_XOR',
		0x87 : 'OP_EQUAL',
		0x88 : 'OP_EQUALVERIFY',
		0x89 : 'OP_RESERVED1',
		0x8a : 'OP_RESERVED2',

		# numeric
		0x8b : 'OP_1ADD',
		0x8c : 'OP_1SUB',
		0x8d : 'OP_2MUL',
		0x8e : 'OP_2DIV',
		0x8f : 'OP_NEGATE',
		0x90 : 'OP_ABS',
		0x91 : 'OP_NOT',
		0x92 : 'OP_0NOTEQUAL',

		0x93 : 'OP_ADD',
		0x94 : 'OP_SUB',
		0x95 : 'OP_MUL',
		0x96 : 'OP_DIV',
		0x97 : 'OP_MOD',
		0x98 : 'OP_LSHIFT',
		0x99 : 'OP_RSHIFT',

		0x9a : 'OP_BOOLAND',
		0x9b : 'OP_BOOLOR',
		0x9c : 'OP_NUMEQUAL',
		0x9d : 'OP_NUMEQUALVERIFY',
		0x9e : 'OP_NUMNOTEQUAL',
		0x9f : 'OP_LESSTHAN',
		0xa0 : 'OP_GREATERTHAN',
		0xa1 : 'OP_LESSTHANOREQUAL',
		0xa2 : 'OP_GREATERTHANOREQUAL',
		0xa3 : 'OP_MIN',
		0xa4 : 'OP_MAX',

		0xa5 : 'OP_WITHIN',

		# crypto
		0xa6 : 'OP_RIPEMD160',
		0xa7 : 'OP_SHA1',
		0xa8 : 'OP_SHA256',
		0xa9 : 'OP_HASH160',
		0xaa : 'OP_HASH256',
		0xab : 'OP_CODESEPARATOR',
		0xac : 'OP_CHECKSIG',
		0xad : 'OP_CHECKSIGVERIFY',
		0xae : 'OP_CHECKMULTISIG',
		0xaf : 'OP_CHECKMULTISIGVERIFY',

		# expansion
		0xb0 : 'OP_NOP1',
		0xb1 : 'OP_CHECKLOCKTIMEVERIFY',
		0xb2 : 'OP_CHECKSEQUENCEVERIFY',
		0xb3 : 'OP_NOP4',
		0xb4 : 'OP_NOP5',
		0xb5 : 'OP_NOP6',
		0xb6 : 'OP_NOP7',
		0xb7 : 'OP_NOP8',
		0xb8 : 'OP_NOP9',
		0xb9 : 'OP_NOP10',

		0xff : 'OP_INVALIDOPCODE'
	}


	def __init__(self):
		self._stack = Stack()


	def push_value(self, value):
		self._stack.push(value)


	def push_operation(self, op):
		try:
			self.push_value(self.OPCODES[op])
		except KeyError:
			print (self.stack())
			raise ValueError('Unknown OPCODE = 0x{:x}'.format(op))


	def push_data(self, size, data):
		self.push_value("Data with length {} = '{}'".format(size, data))


	def push_hex(self, hex_string):
		op = int(hex_string[:2], 16)
		hex_string = hex_string[2:]
		data_size = False
		push_size = self.is_explicit_push(op)

		if push_size:
			data_size = int(StrConverter.hex_reverse_endianness(hex_string[:2*push_size]), 16)
			hex_string = hex_string[2*push_size:]
		elif self.is_implict_push(op):
			data_size = op

		if data_size:
			# on pousse des données sur la pile
			self.push_data(data_size, hex_string[:2*data_size])
			hex_string = hex_string[2*data_size:]
		else:
			self.push_operation(op)

		return hex_string


	def push_byte(self, byte_array):
		op = byte_array[0]
		byte_array = byte_array[1:]
		data_size = False
		push_size = self.is_explicit_push(op)

		if push_size:
			data_size = int.from_bytes(hex_string[:push_size], byteorder='little', signed=False)
			byte_array = byte_array[push_size:]
		elif self.is_implict_push(op):
			data_size = op

		if data_size:
			# on pousse des données sur la pile
			self.push_data(data_size, byte_array[:op])
			byte_array = byte_array[op:]
		else:
			self.push_operation(op)

		return byte_array


	def stack(self): return self._stack._stack



class IntConverter:
	@staticmethod
	def target_to_difficulty(target):
		# Difficulté actuelle = cible(max)/cible(actuelle)
		return MAX_TARGET / target



class ByteArrayConverter:
	@staticmethod
	def parse_varInt(array):
		first_byte = array[0]

		if first_byte == 0xfd:
			return 3, int.from_bytes(array[1:3], byteorder='little', signed=False)
		elif first_byte == 0xfe:
			return 5, int.from_bytes(array[1:5], byteorder='little', signed=False)
		elif first_byte == 0xff:
			return 9, int.from_bytes(array[1:9], byteorder='little', signed=False)

		return 1, first_byte


	@staticmethod
	def script_to_opcodes(array):
		machine = ScriptStack()

		while array:
			array = machine.push_byte(array)

		return machine.stack()



class StrConverter:
	@staticmethod
	def clean_hex_string(string):
		return string[2:] if "0x" == string[0:2] else string


	@staticmethod
	def dec_to_int(string):
		return int(string, 10)


	@staticmethod
	def hex_to_int(string):
		return int(string, 16)


	@staticmethod
	def hex_to_dec(string):
		return str(StrConverter.hex_to_int(string))


	@staticmethod
	def dec_to_hex(string):
		return hex(StrConverter.dec_to_int(string))


	@staticmethod
	def hex_to_byte_array(string):
		number = StrConverter.hex_to_int(string)
		array = number.to_bytes(getsizeof(number), 'big')
		for i in range(len(array)):
			if array[i] != 0:
				return array[i:]
		return b'\x00'


	@staticmethod
	def hex_reverse_endianness(string):
		return hex(int.from_bytes(StrConverter.hex_to_byte_array(string), byteorder='little', signed=False))


	@staticmethod
	def parse_varInt(string):
		return ByteArrayConverter.parse_varInt(StrConverter.hex_to_byte_array(string))


	# https://bitcoin.stackexchange.com/questions/2924/how-to-calculate-new-bits-value
	# The first byte indicates the number of bytes the represented
	# number takes up, and the next one to three bytes give the most significant digits of the
	# number. If the 2nd byte has a value greater than 127 then the number is interpreted as being
	# negative.

	# Bits = 0xWWXXYYZZ
	# WW => nombre d'octet dans la valeur.
	# XXYYZZ => 3 octets les plus significatifs de la valeur.
	# Par exemple, si WW = 0x05 le nombre cible est sur 5 octets, et égal à 0x XX YY ZZ 00 00
	@staticmethod
	def bits_field_to_target(string):
		string = StrConverter.clean_hex_string(string)
		return int(string[2:] + ("00" * (int(string[0:2], 16)-3)), 16) # -3 car XX YY ZZ sont déjà compté


	@staticmethod
	def hex_script_to_opcodes(string):
		machine = ScriptStack()

		while string:
			string = machine.push_hex(string)

		return machine.stack()
