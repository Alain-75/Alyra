from bc_converters import StrConverter as Str
from bc_converters import IntConverter as Int
from bc_converters import ByteArrayConverter as BA



class DataReader:
	def __init__(self, byte_array):
		self._bytes = byte_array


	def peek(self, n):
		if n > len(self._bytes):
			raise ValueError("Missing data")
		return self._bytes[:n]


	def __drain(self, n):
		self._bytes = self._bytes[n:]


	def drain(self, n):
		if n > len(self._bytes):
			raise ValueError("Missing data")
		self.__drain(n)


	def read(self, n):
		result = self.peek(n)
		self.__drain(n)
		return result


	def read_varInt(self):
		n, value = BA.parse_varInt(self._bytes)
		if n > len(self._bytes):
			raise ValueError("Missing data")
		self.__drain(n)
		return value



class Serialized:
	@classmethod
	def from_bytes(cls, byte_array):
		data = DataReader(byte_array)
		result = cls.from_data_reader(data)
		return result, data._bytes


	@classmethod
	def from_hex(cls, string):
		result, _ = cls.from_bytes(bytearray.fromhex(string))
		return result



class Input(Serialized):
	ACCEPTED_SEQUENCES = [b'\x00\x00\x00\x00', b'\xff\xff\xff\xff', b'\xfe\xff\xff\xff', b'\xfd\xff\xff\xff']
	TXID_SIZE = 32
	VOUT_SIZE = 4
	SEQUENCE_SIZE = 4


	def __init__(self):
		self._sequence = None


	def __str__(self):
		return "txid: {}, vout: {}, scriptSig: {}".format(self._txid, self._vout, self._scriptsig)


	@staticmethod
	def from_data_reader(data):
		inp = Input()
		inp._txid = BA.to_hex(data.read(inp.TXID_SIZE)) # Le hash de la transaction passée où sont les bitcoins à dépenser (sur 32 octets)
		inp._vout = BA.little_endian_to_int(data.read(inp.VOUT_SIZE)) # L’index de la sortie (output) de cette transaction concernée (sur 4 octets)

		# Longueur de ScriptSig (varInt)
		scriptSig_length = data.read_varInt()

		# scriptSig
		inp._scriptsig = BA.to_hex(data.read(scriptSig_length))

		# Séquence (sur 4 octets)
		inp._sequence = data.read(inp.SEQUENCE_SIZE)

		if inp._sequence not in inp.ACCEPTED_SEQUENCES:
			raise ValueError("Unacceptable sequence {}".format(inp._sequence))

		return inp



class Output(Serialized):
	VALUE_SIZE = 8


	def __init__(self):
		pass


	def __str__(self):
		return "value: {}, script: {}".format(self._value, self._parsed_script)


	@staticmethod
	def from_data_reader(data):
		out = Output()
		out._value = BA.little_endian_to_int(data.read(out.VALUE_SIZE))
		scriptPubKey_length = data.read_varInt()
		out._scriptpubkey = data.read(scriptPubKey_length)
		out._parsed_script = BA.script_to_opcodes(out._scriptpubkey)
		out._scriptpubkey = BA.to_hex(out._scriptpubkey)
		return out



class Witness(Serialized):
	VALUE_SIZE = 8


	def __init__(self):
		self._stack_elements = []


	def __str__(self):
		return "witness: {}".format(self._stack_elements)


	@staticmethod
	def from_data_reader(data):
		wit = Witness()
		number_of_stack_elements = data.read_varInt()
		wit._stack_elements = []

		for i in range(number_of_stack_elements):
			element_size = data.read_varInt()
			wit._stack_elements.append(BA.to_hex(data.read(element_size)))

		return wit



class Transaction(Serialized):
	ACCEPTED_VERSIONS = [b'\x01\x00\x00\x00', b'\x02\x00\x00\x00']
	VERSION_SIZE = 4
	FLAG_SIZE = 2
	SEGWIT_FLAG = b'\x00\x01'
	LOCKTIME_SIZE = 4


	def __init__(self):
		self._flag = False
		self._inputs = []
		self._outputs = []
		self._witnesses = []


	def __str__(self):
		result = "\t- version: {}, locktime: {}:\n\t- in:\n".format(self._version, self._locktime)
		for i in self._inputs:
			result += "\t\t- {}\n".format(i)
		result += "\t- out:\n"
		for o in self._outputs:
			result += "\t\t- {}\n".format(o)
		return result


	@staticmethod
	def from_data_reader(data):
		tx = Transaction()
		tx._version = data.read(tx.VERSION_SIZE)

		if tx._version not in tx.ACCEPTED_VERSIONS:
			raise ValueError("Unknown tx version number {}".format(tx._version))

		tx._version = BA.to_hex(tx._version)
		tx._flag = (data.peek(tx.FLAG_SIZE) == tx.SEGWIT_FLAG)

		if tx._flag:
			tx._flag = True
			data.drain(tx.FLAG_SIZE)

		number_of_inputs = data.read_varInt()
		tx._inputs = []

		for i in range(number_of_inputs):
			tx._inputs.append(Input.from_data_reader(data))

		number_of_outputs = data.read_varInt()
		tx._outputs = []

		for i in range(number_of_outputs):
			tx._outputs.append(Output.from_data_reader(data))

		if tx._flag:
			# lire les données témoin
			for i in range(number_of_inputs):
				tx._witnesses.append(Witness.from_data_reader(data))

		tx._locktime = BA.little_endian_to_int(data.read(tx.LOCKTIME_SIZE))

		return tx



class Block(Serialized):
	VERSION_SIZE = 4
	PREVIOUS_BLOCK_HASH_SIZE = 32
	MERKLE_ROOT_SIZE = 32
	TIME_SIZE = 4
	BITS_SIZE = 4
	NONCE_SIZE = 4


	def __init__(self):
		self._transactions = []


	def __str__(self):
		result = "version: {}, previous hash: {}, merkle root: {}, time: {}, nonce: {}\n\ttransactions:\n".format(
				self._version
			,	self._previous_block_hash
			,	self._merkle_root
			,	self._time
			,	self._nonce
			)
		for t in self._transactions:
			result += "- transaction: {}".format(t)
		return result


	@staticmethod
	def from_data_reader(data):
		b = Block()
		b._version = BA.little_endian_to_int(data.read(b.VERSION_SIZE))
		b._previous_block_hash = BA.to_hex(data.read(b.PREVIOUS_BLOCK_HASH_SIZE))
		b._merkle_root = BA.to_hex(data.read(b.MERKLE_ROOT_SIZE))
		b._time = BA.little_endian_to_int(data.read(b.TIME_SIZE))
		b._bits = data.read(b.BITS_SIZE)
		b._nonce = BA.little_endian_to_int(data.read(b.NONCE_SIZE))

		number_of_transactions = data.read_varInt()
		b._transactions = []

		for i in range(number_of_transactions):
			try:
				b._transactions.append(Transaction.from_data_reader(data))
			except:
				print(b)
				raise ValueError("i={}".format(i))

		return b
