#!/usr/bin/python3.6

import sys
import argparse
from bc_parsers import Block as Block


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--file", help="read block from file instead of standard input")
	args = parser.parse_args()

	if args.file:
		with open(args.file) as file:
			b = Block.from_hex(file.read(-1))
	else:
		b = Block.from_hex(sys.stdin.read(-1))

	print(b)


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
