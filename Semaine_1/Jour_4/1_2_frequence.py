#!/usr/bin/python3.6

import sys


def count_occurences(line):
	return { char: line.count(char) for char in line }


def update_occurences(table, occurences):
	for char, count in occurences.items():
		table[char] = table.get(char, 0) + count


def count_occurences_in_file(file):
	table = {}
	for line in file:
		update_occurences(table, count_occurences(line))
	return table


def main():
	try:
		file_path = sys.argv[1]
	except IndexError:
		sys.exit("missing argument")

	with open(file_path) as file:
		table = count_occurences_in_file(file)
		print(table)


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
