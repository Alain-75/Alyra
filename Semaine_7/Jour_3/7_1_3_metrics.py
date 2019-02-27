#!/usr/bin/python3.6

import sys
import argparse
import exchanges as EX


def get_metrics(ticker):
	return EX.Messari().metrics(ticker)


def transform_ticker(ticker):
	return ticker.lower()


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("ticker", help="ticker to get last trade for", type=transform_ticker)
	args = parser.parse_args()

	result = get_metrics(args.ticker)

	current_px = float(result['data']['market_data']['price_usd'])
	highest_px = float(result['data']['all_time_high']['price'])
	current_qty = float(result['data']['supply']['circulating'])
	y2050_qty = float(result['data']['supply']['y_2050'])

	print("{} metrics".format(args.ticker))
	print("* prices")
	print("\t* current: {}".format(current_px))
	print("\t* highest: {}".format(highest_px))
	print("\t\t* current to highest ratio: {}%".format(100*current_px/highest_px))
	print("* volume")
	print("\t* current: {}".format(current_qty))
	print("\t* y2050: {}".format(y2050_qty))
	print("\t\t* current to y2050 ratio: {}%".format(100*current_qty/y2050_qty))


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
