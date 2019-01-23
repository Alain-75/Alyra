#!/usr/bin/python3.6

import sys
import argparse
import math


BASE_BOUNTY = 50
HEIGHT_ADJUSTMENT = 210000


def compute_bounty(height):
	return BASE_BOUNTY / 2**math.floor(height / HEIGHT_ADJUSTMENT)


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("height", help="block height to convert into bounty value", type=int)
	args = parser.parse_args()

	result = compute_bounty(args.height)

	print(result)


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
