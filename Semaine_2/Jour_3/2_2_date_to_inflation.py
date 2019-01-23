#!/usr/bin/python3.6

import sys
import argparse
import math
import datetime


SECONDS_IN_10_MINUTES = 60*10
BITCOIN_START_DATE = datetime.datetime.strptime("20090103", "%Y%m%d")
BASE_BOUNTY = 50
HEIGHT_ADJUSTMENT = 210000


def compute_inflation(height):
	current_slice = math.floor(height / HEIGHT_ADJUSTMENT)

	# inflation on current slice
	total_inflation = (50/2**current_slice) * (height % HEIGHT_ADJUSTMENT)

	# inflation during previous slices
	for i in range(current_slice):
		total_inflation += (50/2**i) * HEIGHT_ADJUSTMENT

	return total_inflation


def date_to_block_height(date):
	return math.floor((date - BITCOIN_START_DATE).total_seconds() / SECONDS_IN_10_MINUTES)


def valid_date(arg):
    try:
        return datetime.datetime.strptime(arg, "%Y%m%d")
    except ValueError:
        msg = "Not a valid date: '{}'.".format(arg)
        raise argparse.ArgumentTypeError(msg)


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("date", help="date to use for inflation calculation", type=valid_date)
	args = parser.parse_args()

	result = compute_inflation(date_to_block_height(args.date))

	print(result)


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
