#!/usr/bin/python3.6

import sys
import argparse
import struct
import hashlib
import base58 # disponible sur PyPI


def sha256(bytestring):
	sha = hashlib.sha256()
	sha.update(bytestring)
	return sha


def number_to_address(value, testnet):
	b = struct.pack("l", value)
	sha = sha256(b)
	h = hashlib.new('ripemd160')
	h.update(sha.digest())
	bin_digest = (b'\x6f' if testnet else b'\x00') + h.digest()
	control = sha256(sha256(bin_digest).digest()).digest()[0:4]
	return base58.b58encode(bin_digest + control)


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("number", help="number to transform into a bitcoin address", type=int)
	parser.add_argument("--testnet", help="convert into a testnet address", action="store_true")
	args = parser.parse_args()

	result = number_to_address(args.number, args.testnet)
	print(result.hex())


if __name__ == "__main__":
    # executer seulement si lancé depuis la ligne de commande
    main()
