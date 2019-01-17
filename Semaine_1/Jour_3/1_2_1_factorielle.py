#!/usr/bin/python3.6

import sys


# complexité en O(n)
def factorielle(number):
	result = 1

	for i in range(1,number+1):
		result *= i

	print(result)


def main():
	try:
		number = int(sys.argv[1])
	except IndexError:
		sys.exit("missing argument")
	except ValueError:
		sys.exit("bad argument one '" + sys.argv[1] + "', must pass an integer")

	factorielle(number)


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
