#!/usr/bin/python3.6

import sys
import argparse

# cible(max) = ( (2¹⁶ - 1) * 2²⁰⁸
MAX_TARGET = (2**16 -1) * 2**208


def compute_difficulty(target):
	# Difficulté actuelle = cible(max)/cible(actuelle)
	return MAX_TARGET / target


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("target", help="target to convert into difficulty", type=int)
	args = parser.parse_args()

	result = compute_difficulty(args.target)

	print(result)


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
