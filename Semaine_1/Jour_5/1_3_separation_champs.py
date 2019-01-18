#!/usr/bin/python3.6

import sys
import argparse


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


def parse_entry(line):
	previous_hash = line[:64] # Le hash de la transaction passée où sont les bitcoins à dépenser (sur 32 octets) 
	out_index = line[64:72] # L’index de la sortie (output) de cette transaction concernée (sur 4 octets)

	# Longueur de ScriptSig (varInt)
	varInt_size, scriptSig_length = parse_varInt(line[72:])

	# ScriptSig
	scriptSig_end = 2*(32 + 4 + varInt_size + scriptSig_length)
	scriptSig = line[72 + 2*varInt_size:scriptSig_end]

	# on vérifie la cohérence
	expected_hex_digits = scriptSig_end + 8

	if expected_hex_digits != len(line):
	 	raise ValueError("Expected {} hex digits, got {}".format(expected_hex_digits, len(line)))

	# Séquence (sur 4 octets)
	sequence = line[scriptSig_end:expected_hex_digits]

	return previous_hash, out_index, scriptSig_length, scriptSig, sequence


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("path", help="path to entries file, one entry per line", type=str)
	args = parser.parse_args()

	with open(args.path) as file:
		results = [parse_entry(line.strip()) for line in file]

	e_count = 0
	for entry in results:
		print("entry {}:\n\t|__ prev_hash '{}'\n\t|__ out_index '{}'\n\t|__ sig_length '{}'\n\t|__ scriptSig '{}'\n\t|__ sequence '{}'".format(
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
