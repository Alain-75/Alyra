#!/usr/bin/python3.6

import sys
import argparse


VERSION_SIZE = 4


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


def parse_entry(entry):
	previous_hash = entry[:64] # Le hash de la transaction passée où sont les bitcoins à dépenser (sur 32 octets) 
	out_index = entry[64:72] # L’index de la sortie (output) de cette transaction concernée (sur 4 octets)

	# Longueur de ScriptSig (varInt)
	varInt_size, scriptSig_length = parse_varInt(entry[72:])

	# ScriptSig
	scriptSig_end = 2*(32 + 4 + varInt_size + scriptSig_length)
	scriptSig = entry[72 + 2*varInt_size:scriptSig_end]

	# Séquence (sur 4 octets)
	total_length = scriptSig_end + 8
	sequence = entry[scriptSig_end:total_length]

	return previous_hash, out_index, scriptSig_length, scriptSig, sequence, total_length


def parse_transaction(line):
	version = line[:2*VERSION_SIZE]

	if version not in ['01000000', '02000000']:
		raise ValueError("Unknown version number {}".format(version))

	varInt_size, number_of_entries = parse_varInt(line[2*VERSION_SIZE:])

	count = 2*(VERSION_SIZE + varInt_size)

	results = []

	for i in range(number_of_entries):
		previous_hash, out_index, scriptSig_length, scriptSig, sequence, total_length = parse_entry(line[count:])
		results.append([previous_hash, out_index, scriptSig_length, scriptSig, sequence])
		count += total_length
		if count > len(line):
			raise ValueError("Missing entries")

	return results


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("path", help="path to transactions file, one transaction per line", type=str)
	args = parser.parse_args()

	with open(args.path) as file:
		results = [parse_transaction(line.strip()) for line in file]

	t_count = 0
	for transaction in results:
		print("transaction {}:".format(t_count))
		t_count += 1
		e_count = 0
		for entry in transaction:
			print("\t|__ entry {}:\n\t\t|__ prev_hash {}\n\t\t|__ out_index {}\n\t\t|__ scriptSig_length {}\n\t\t|__ scriptSig {}\n\t\t|__ sequence {}".format(
				e_count,
				entry[0],
				entry[1],
				entry[2],
				entry[3],
				entry[4]))
			e_count += 1


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
