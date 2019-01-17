#!/usr/bin/python3.6

import sys
import argparse


CODE_TABLE = [
	'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l',
	'm', 'n', 'o', 'p', 'q', 'r',
	's', 't', 'u', 'v', 'w', 'x',
	'y', 'z', '.', ';', ':', ' ',
	'A', 'B', 'C', 'D', 'E', 'F',
	'G', 'H', 'I', 'J', 'K', 'L',
	'M', 'N', 'O', 'P', 'Q', 'R',
	'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', '?', '!', '"', '\'',
	'0', '1', '2', '3', '4', '5',
	'6', '7', '8', '9', '$', '-'
	]


def code_index(char):
	return CODE_TABLE.index(char)


def shift_character(char, shift):
	return CODE_TABLE[(code_index(char) + shift) % len(CODE_TABLE)]


def vigenere_encode(message, key):
	encoded = ""
	key_count = 0

	for m in message:
		encoded += shift_character(m, code_index(key[key_count]))
		key_count = (key_count+1) % len(key)

	return encoded


def vigenere_decode(message, key):
	decoded = ""
	key_count = 0

	for m in message:
		decoded += shift_character(m, -code_index(key[key_count]))
		key_count = (key_count+1) % len(key)

	return decoded


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("message", help="plain text or encoded message", type=str)
	parser.add_argument("key", help="key for encoding or decoding", type=str)
	parser.add_argument("--decode", help="consider message is encoded and use key for decoding", action="store_true")
	args = parser.parse_args()

	result = ""

	if args.decode:
		result = vigenere_decode(args.message, args.key)
	else:
		result = vigenere_encode(args.message, args.key)

	print(result)


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
