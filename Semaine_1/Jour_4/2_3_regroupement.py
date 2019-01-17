#!/usr/bin/python3.6

import sys
import argparse


def group(message, key):
	table = [ "" for i in range(key) ]
	# retirer tous les espaces du message :
	message = ''.join(message.split())

	for count in range(len(message)):
		table[ count%key ] += message[count]

	return table


def check_positive(value):
    v = int(value)
    if v <= 0:
        raise argparse.ArgumentTypeError("expecting strictly positive integer for key, got {}".format(value))
    return v


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("message", help="plain text or encoded message", type=str)
	parser.add_argument("key", help="strictly positive integer value for grouping", type=check_positive)
	args = parser.parse_args()

	result = group(args.message, args.key)
	print(result)


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
