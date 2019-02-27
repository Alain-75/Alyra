import json
from http import client as httpc


BUY = -1
SELL = 1



class RESTAPI:
	def __init__(self, server):
		self._server = server
		self._conn = httpc.HTTPSConnection(server)


	def query(self, path):
		self._conn.request("GET", path)
		resp = self._conn.getresponse()
		if resp.status != 200:
			raise RuntimeError("Cannot get {} from {}: {} {}".format(path, self._server, resp.status, resp.reason))
		return resp.read()


	def json_query(self, path):
		return json.loads(self.query(path))



class OrderBook:
	def __init__(self, exchange, ticker):
		self._book = exchange.build_book(ticker)


	def walk_book(self, book, side, qty):
		total_px = 0

		for idx in range(len(book)):
			entry = book[idx]
			entry_px = float(entry[0])
			entry_qty = float(entry[1])

			if entry_qty >= qty:
				total_px += side * qty * entry_px
				qty = 0
				break
			else:
				total_px += side * entry_qty * entry_px
				qty -= entry_qty

		return total_px, qty


	def simulate_order(self, side, qty):
		if side == BUY:
			return self.walk_book(self._book['ask'], side, qty)
		return self.walk_book(self._book['bid'], side, qty)



class Bitfinex(RESTAPI):
	def __init__(self):
		super(Bitfinex,self).__init__('api.bitfinex.com')


	def build_book(self, ticker):
		response = self.json_query('/v1/book/' + ticker)

		return {
			# buy BTC, paying USD
			'bid': [ (x['price'], x['amount']) for x in response['bids'] ],
			# sell BTC, getting paid in USD
			'ask': [ (x['price'], x['amount']) for x in response['asks'] ]
			}


	def last_execution(self, ticker):
		response = self.json_query('/v2/trades/t' + ticker + '/hist?limit=1')
		return {
			'id': response[0][0],
			'qty': response[0][2],
			'px': response[0][3]
		}



class Bitmex(RESTAPI):
	def __init__(self):
		super(Bitmex,self).__init__('www.bitmex.com')


	def build_book(self, ticker):
		response = self.json_query('/api/v1/orderBook/L2?symbol=' + ticker)

		bid = []
		ask = []

		for order in response:
			if order['side'] == "Buy":
				# buy BTC, paying USD
				bid.append( (order['price'], order['size']) )
			else:
				# sell BTC, getting paid in USD
				ask.append( (order['price'], order['size']) )

		return {'bid': bid, 'ask': ask}



class Messari(RESTAPI):
	def __init__(self):
		super(Messari,self).__init__('data.messari.io')


	def metrics(self, ticker):
		return self.json_query('/api/v1/assets/' + ticker + '/metrics')
