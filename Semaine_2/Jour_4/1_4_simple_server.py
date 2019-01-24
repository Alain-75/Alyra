import sys
import argparse
import asyncio


async def server_handler(reader, writer):
	data = await reader.read(-1)
	message = data.decode()
	print(message)


def valid_port(arg):
	try:
		port = int(arg)

		if port < 0 or port > 65535:
			raise ValueError
		return port

	except ValueError:
		msg = "Not a valid TCP port: '{}'.".format(arg)
		raise argparse.ArgumentTypeError(msg)


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("port", help="listening port to open", type=int)
	args = parser.parse_args()

	loop = asyncio.get_event_loop()
	coro = asyncio.start_server(server_handler, '127.0.0.1', 6667, loop=loop)
	server = loop.run_until_complete(coro)

	try:
		loop.run_forever()
	except KeyboardInterrupt:
		pass

	# Close the server
	server.close()
	loop.run_until_complete(server.wait_closed())
	loop.close()


if __name__ == "__main__":
	# executer seulement si lancé depuis la ligne de commande
	main()
