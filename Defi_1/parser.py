#!/usr/bin/python3.6

import sys
import argparse
from bc_parsers import Block as Block
from bc_parsers import Transaction as Transaction
from bc_parsers import Input as Input
from bc_parsers import Output as Output


def check_type(t):
	if t == "block":
		return Block
	elif t == "tx":
		return Transaction
	elif t == "input":
		return Input
	elif t == "output":
		return Output
	else:
		raise argparse.ArgumentTypeError("--type must be on of (block, tx, input, output), got '{}'".format(t))


def check_format(f):
	if f == "bin" or f == "hex":
		return f
	else:
		raise argparse.ArgumentTypeError("--format must be on of (block, tx, format, output), got '{}'".format(t))


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--file", help="read from file instead of standard input")
	parser.add_argument("--type", help="must take one of the following values: block, tx, input, output. By default, this command expects a block", type=check_type)
	parser.add_argument("--format", help="must take one of the following values: bin, hex. By default, this command expects hexadecimal format", type=check_format)
	args = parser.parse_args()

	parsed_type = args.type if args.type else Block

	if args.format == "bin":
		if args.file:
			with open(args.file) as file:
				result = parsed_type.from_bytes(file.read(-1))
		else:
			result = parsed_type.from_bytes(sys.stdin.read(-1))
	else:
		if args.file:
			with open(args.file) as file:
				result = parsed_type.from_hex(file.read(-1))
		else:
			result = parsed_type.from_hex(sys.stdin.read(-1))

	print(result)


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
