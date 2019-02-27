#!/usr/bin/python3.6

import sys
import argparse
import exchanges as EX


def get_last_execution(ticker):
	return EX.Bitfinex().last_execution(ticker)


def transform_ticker(ticker):
	return ticker.upper()


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("ticker", help="ticker to get last trade for", type=transform_ticker)
	args = parser.parse_args()

	result = get_last_execution(args.ticker)
	print("Last execution on {}: {} @ {} ID({})".format(args.ticker, result['qty'], result['px'], result['id']))


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
