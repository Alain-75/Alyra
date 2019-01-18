#!/usr/bin/python3.6

import sys
import argparse


def convert(number):
	big_endian = ""
	little_endian = ""
	byte_array = [x.to_bytes(1, "big").hex() for x in number.to_bytes(sys.getsizeof(number), "big")]

	for x in reversed(byte_array):
		if x == "00":
			break
		big_endian = "{} {}".format(x, big_endian)
		little_endian = "{} {}".format(little_endian, x)

	return (big_endian.strip(), little_endian.strip())


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("number", help="number to convert", type=int)
	args = parser.parse_args()

	result = ""

	result = convert(args.number)
	print("{}\t=> 0x {} (big endian)\n\t=> 0x {} (litle endian)".format(args.number, result[0], result[1]))


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
