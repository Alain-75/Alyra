#!/usr/bin/python3.6

import sys
from hashlib import sha256 as sha256


def city_hash(city):
	h = sha256()
	h.update(city.encode("utf-8"))
	return h.hexdigest()[0:8]


def server_hash_table(servers):
	return {city_hash(server[0]): server[1] for server in servers}


def main():
	# On suppose que le fichier d'entrée contient un couple ville/IP par ligne,
	# séparés par une tabulation.
	# Le fichier de sortie contiendra les 8 premiers chiffres hexa du sha-256
	# de la ville, suivis d'une tabulation, suivie de l'adresse IP associée
	# à la ville. Les hash sont triés.
	try:
		server_file = sys.argv[1]
		result_file = sys.argv[2]
	except IndexError:
		sys.exit("missing argument")

	servers = []

	with open(server_file) as file:
		servers = [ (place.strip(), ip_address.strip()) for place, ip_address in (line.split('\t') for line in file) ]

	with open(result_file, 'w') as file:
		file.writelines( "{}\t{}\n".format(h, ip) for h, ip in sorted(server_hash_table(servers).items()) )


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
