#!/usr/bin/python3.6

import sys


BLOCK_SIZE = 6000


# L'idée ici est que la méthode par force brute va faire exploser la complexité :
# si n est le nombre de transactions en entrée et m le nombre de transaction possible
# dans un bloc, le pire cas est de l'ordre de n^m opérations pour trouver la solution
# optimale. On est face à une complexité polynomiale, ce qui ne semble pas acceptable.
# On va donc utiliser une heuristique, en donnant une note à chaque transaction. Cette
# note est égale au ratio pourboire/taille. On va trier les transactions en fonction de
# cette note. Puis on va sélectionner les meilleures jusqu'à avoir rempli notre bloc.
# Cet algorithme ne donne pas la solution optimale, mais il donne une bonne solution.
# Sa complexité est correspond à celle du tri inital. Cette complexité est donc
# logarithmique sur la taille des entrées.
def choose_transactions(transactions):
	# La ligne suivante tri la liste en fonction de la note de chaque transaction.
	# On oublie immédiatement la note, l'important étant de trier la liste
	weighted_transactions = sorted(transactions, reverse=True, key=lambda t: t[1]/t[0])

	total_tip = 0
	chosen_transactions = []
	current_size = 0

	# on dépile weighted_transactions tant que le bloc n'est pas rempli.
	while current_size < BLOCK_SIZE and weighted_transactions:
		transaction = weighted_transactions.pop(0)
		if current_size + transaction[0] <= BLOCK_SIZE:
			current_size += transaction[0]
			chosen_transactions.append(transaction)
			total_tip += transaction[1]

	print("chosen transactions: {}\ntotal tip: {}".format(chosen_transactions, total_tip))


def main():
	# on suppose qu'un fichier contient une transaction par ligne avec la taille,
	# en début de ligne, suivie du pourboire, séparés par un espace.
	try:
		transaction_file = sys.argv[1]
	except IndexError:
		sys.exit("missing argument")

	transactions = []

	with open(transaction_file) as file:
		line_splitter = (line.split(' ') for line in file)

		try:
			transactions = [ (int(size.strip()), int(tip.strip())) for size, tip in line_splitter ]
		except ValueError:
			sys.exit("bad value in '" + transaction_file + "', must contain two integers per line")

	choose_transactions(transactions)


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
