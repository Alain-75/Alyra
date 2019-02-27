#!/usr/bin/python3.6

import sys
import argparse
import exchanges as EX


def compare_books(side, qty):
	exchanges = {
		"bitfinex": EX.OrderBook(EX.Bitfinex(), 'btcusd'),
		"bitmex": EX.OrderBook(EX.Bitmex(), 'XBT')
	}

	for name, ex in exchanges.items():
		total_px, remaining_qty = ex.simulate_order(side, qty)

		if remaining_qty > 0:
			print("{}: partial execution of {} @ {}".format(name, qty - remaining_qty, total_px))
		else:
			print("{}: total execution @ {}".format(name, total_px))


def validate_side(side):
	if side == "buy": return EX.BUY
	elif side == "sell": return EX.SELL
	else:
		raise argparse.ArgumentTypeError("Not an order side, got '{}' expected 'buy' or 'sell'".format(side))


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("side", help="side of order, 'buy' or 'sell'", type=validate_side)
	parser.add_argument("qty", help="quantity of order", type=float)
	args = parser.parse_args()

	compare_books(args.side, args.qty)


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
