#!/usr/bin/python3.6

import sys
import argparse
import math


BASE_BOUNTY = 50
HEIGHT_ADJUSTMENT = 210000


def compute_inflation(height):
	current_slice = math.floor(height / HEIGHT_ADJUSTMENT)

	# inflation on current slice
	total_inflation = (50/2**current_slice) * (height % HEIGHT_ADJUSTMENT)

	# inflation during previous slices
	for i in range(current_slice):
		total_inflation += (50/2**i) * HEIGHT_ADJUSTMENT

	return total_inflation


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("height", help="block height to convert into bounty value", type=int)
	args = parser.parse_args()

	result = compute_inflation(args.height)

	print(result)


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
