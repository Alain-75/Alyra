#!/usr/bin/python3.6

import sys
import argparse
import json
from http import client as httpc


BUY = -1
SELL = 1


class Exchange:
	def __init__(self, server, request_path):
		conn = httpc.HTTPSConnection(server)
		conn.request("GET", request_path)
		resp = conn.getresponse()
		if resp.status != 200:
			raise RuntimeError("Cannot get book from {}: {} {}".format(server, resp.status, resp.reason))
		self.build_book(json.loads(resp.read()))


	def walk_book(self, book, side, qty):
		total_price = 0

		for idx in range(len(book)):
			entry = book[idx]
			entry_price = float(entry[0])
			entry_qty = float(entry[1])

			if entry_qty >= qty:
				total_price += side * qty * entry_price
				qty = 0
				break
			else:
				total_price += side * entry_qty * entry_price
				qty -= entry_qty

		return total_price, qty


	def simulate_order(self, side, qty):
		if side == BUY:
			return self.walk_book(self._ask, side, qty)
		return self.walk_book(self._bid, side, qty)



class Bitfinex(Exchange):
	def __init__(self):
		super(Bitfinex,self).__init__('api.bitfinex.com', '/v1/book/btcusd')

	def build_book(self, response):
		# buy BTC, paying USD
		self._bid = [ (x['price'], x['amount']) for x in response['bids'] ]
		# sell BTC, getting paid in USD
		self._ask = [ (x['price'], x['amount']) for x in response['asks'] ]



class Bitmex(Exchange):
	def __init__(self):
		super(Bitmex,self).__init__('www.bitmex.com', '/api/v1/orderBook/L2?symbol=XBT')

	def build_book(self, response):
		self._bid = []
		self._ask = []
		for order in response:
			if order['side'] == "Buy":
				# buy BTC, paying USD
				self._bid.append( (order['price'], order['size']) )
			else:
				# sell BTC, getting paid in USD
				self._ask.append( (order['price'], order['size']) )



def compare_books(side, qty):
	exchanges = {
		"bitfinex": Bitfinex(),
		"bitmex": Bitmex()
	}

	for name, ex in exchanges.items():
		total_price, remaining_qty = ex.simulate_order(side, qty)

		if remaining_qty > 0:
			print("{}: partial execution of {} @ {}".format(name, qty - remaining_qty, total_price))
		else:
			print("{}: total execution @ {}".format(name, total_price))


def validate_side(side):
	if side == "buy": return BUY
	elif side == "sell": return SELL
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
