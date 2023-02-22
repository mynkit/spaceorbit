import time
import argparse
from pythonosc.dispatcher import Dispatcher
from pythonosc import udp_client, osc_server
from typing import List, Any
from math import sqrt, degrees
import numpy as np

# touch designerに送信するために、相手のipとportを指定
parser = argparse.ArgumentParser()
parser.add_argument('--init', action='store_true')
parser.add_argument("--td_ip",
    default="192.168.0.30", help="The ip to send")
parser.add_argument("--td_port",
    type=int, default=10002, help="The port to send")
parser.add_argument("--my_port",
    type=int, default=57100, help="The port to listen on")
args = parser.parse_args()

# 送信用
client_to_tidal = udp_client.SimpleUDPClient('127.0.0.1', 6060)
client_to_tidalm = udp_client.SimpleUDPClient('127.0.0.1', 6061)
client_to_sc = udp_client.SimpleUDPClient('127.0.0.1', 57110)
client_to_sd = udp_client.SimpleUDPClient('127.0.0.1', 57120)
client_to_td = udp_client.SimpleUDPClient(args.td_ip, args.td_port)
client_to_mone = udp_client.SimpleUDPClient('192.168.0.32', 10002)


def init():
    pass


def send_nailClapper_gain(gain: float, add_second: float = 0.0):
    global nailClapper_timer
    gain = 1.0 if gain > 1 else gain
    print(f'/nailClapper', gain)
    client_to_td.send_message(f'/nailClapper', gain)
    nailClapper_timer = time.time() + add_second


def tidal_handler(address: str, *args: List[Any]) -> None:
    """tidalから受信用の関数"""
    try:
        # print(address, list(args))
        if '_id_' in args and 's' in args and 'gain' in args and 'n' in args:
            channel = args[(args.index('_id_')) + 1]
            sound_source = args[(args.index('s')) + 1]
            gain = args[(args.index('gain')) + 1]
            n = args[(args.index('n')) + 1]
            if channel == '6' and sound_source == 'tabla':
                print(f'/tabla', gain)
                client_to_td.send_message(f'/tabla', gain)
                client_to_mone.send_message(f'/tabla', gain)
            if channel == '5' and sound_source == 'noiseman':
                gain = gain * (10/7)
                print(f'/grazing', gain)
                client_to_td.send_message(f'/grazing', gain)
                client_to_mone.send_message(f'/grazing', gain)
            if channel == '3' and sound_source == 'windchimes':
                gain = gain * 2
                print(f'/windchimes', gain)
                client_to_td.send_message(f'/windchimes', gain)
                client_to_mone.send_message(f'/windchimes', gain)

    except ValueError:
        pass


def td_handler(address: str, *args: List[Any]) -> None:
    """touch designerから受信用の関数"""
    try:
        if len(args) > 0:
            if address == '/td/spin':
                # シーン2の回るところ
                # あやしいコード
                client_to_tidal.send_message('/ctrl', ['spin', args[0]])
            
    except ValueError:
        pass

def xy_handler(address: str, *args: List[Any]) -> None:
    try:
        if address == '/xy1':
            x, y = args
            dis = 2 * sqrt((x-0.5)**2 + (y-0.5)**2)
            theta = (90 - degrees(np.angle((x-0.5) + (y-0.5)*1j))) / 180
            client_to_tidalm.send_message('/ctrl', ['dis1', dis])
            client_to_tidalm.send_message('/ctrl', ['theta1', theta])

    except ValueError:
        pass

if __name__ == "__main__":
    if args.init:
        init()

    else:
        dispatcher = Dispatcher()
        dispatcher.map("/dirt/play*", tidal_handler)
        dispatcher.map("/td*", td_handler)
        dispatcher.map("/xy*", xy_handler)

        server = osc_server.ThreadingOSCUDPServer(
            ('0.0.0.0', args.my_port), dispatcher)
        print("Serving on {}".format(server.server_address))
        server.serve_forever()