#!/usr/bin/python3.6

import sys


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


def shift_character(char, shift):
	return CODE_TABLE[(CODE_TABLE.index(char) + shift) % len(CODE_TABLE)]


def cesar(message, shift):
	return ''.join(shift_character(c, shift) for c in message)


def main():
	try:
		message = sys.argv[1]
		shift = int(sys.argv[2])
	except IndexError:
		sys.exit("missing argument")
	except ValueError:
		sys.exit("bad argument two '" + sys.argv[2] + "', must pass an integer")

	result = cesar(message, shift)
	print(result)


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
