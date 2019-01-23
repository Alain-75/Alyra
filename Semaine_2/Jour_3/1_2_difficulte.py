#!/usr/bin/python3.6

import sys
import argparse


# cible(max) = ( (2¹⁶ - 1) * 2²⁰⁸
MAX_TARGET = (2**16 -1) * 2**208


# https://bitcoin.stackexchange.com/questions/2924/how-to-calculate-new-bits-value
# The first byte indicates the number of bytes the represented
# number takes up, and the next one to three bytes give the most significant digits of the
# number. If the 2nd byte has a value greater than 127 then the number is interpreted as being
# negative.
def convert(hex_string):
	if "0x" == hex_string[0:2]:
		hex_string = hex_string[2:]
	number_of_bytes = int(hex_string[0:2], 16) - 3
	decoded = bytes.fromhex(hex_string[2:])
	value = int.from_bytes(decoded, byteorder='big', signed=False)
	return value * 256**number_of_bytes


def compute_difficulty(hex_target):
	target = convert(hex_target)
	# Difficulté actuelle = cible(max)/cible(actuelle)
	return MAX_TARGET / target


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("target", help="hex target to convert into difficulty", type=str)
	args = parser.parse_args()

	result = compute_difficulty(args.target)

	print(result)


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
