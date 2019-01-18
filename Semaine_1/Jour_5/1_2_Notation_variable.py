#!/usr/bin/python3.6

import sys
import argparse


def convert(number):
	big_endian = ""
	little_endian = ""
	variable_little_endian = ""
	byte_array = [x.to_bytes(1, "big").hex() for x in number.to_bytes(sys.getsizeof(number), "big")]

	count = 0

	for x in reversed(byte_array):
		if x == "00":
			break
		count += 1
		big_endian = "{} {}".format(x, big_endian)
		little_endian = "{} {}".format(little_endian, x)

	if count == 1 and number < 253:
		variable_little_endian = little_endian
	elif count == 2 or (count == 1 and number >= 253):
		variable_little_endian = "fd" + little_endian
	elif count == 3:
		variable_little_endian = "fe" + little_endian + " 00"
	elif count == 4:
		variable_little_endian = "fe" + little_endian
	elif count < 9:
		variable_little_endian = "ff" + little_endian
		for count in range(count, 9):
			variable_little_endian += " 00"
	else:
		raise ValueError("'{}' is to large for varInt representation".format(number))

	return (big_endian.strip(), little_endian.strip(), variable_little_endian.strip())


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("number", help="number to convert", type=int)
	args = parser.parse_args()

	result = ""

	result = convert(args.number)
	print("{}\t=> 0x {} (big endian)\n\t=> 0x {} (litle endian)\n\t=> 0x {} (varInt)".format(args.number, result[0], result[1], result[2]))


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
