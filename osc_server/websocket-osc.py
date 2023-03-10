from websocket_server import WebsocketServer
import logging
from pythonosc.dispatcher import Dispatcher
from pythonosc import udp_client, osc_server
import json
from math import sqrt, degrees
import numpy as np
import os
import json

client_to_tidal = udp_client.SimpleUDPClient('127.0.0.1', 6060)
client_to_tidalm = udp_client.SimpleUDPClient('127.0.0.1', 6061)
client_to_sc = udp_client.SimpleUDPClient('127.0.0.1', 57110)

forestNode = 1000
rainNode = 1001
backgroundNode = 1002
leavesNode = 1003

def send_position(message):
    s_name = message['type']
    x = message['x']
    y = message['y']
    amp = message['value']
    isMute = message['isMute']
    dis = 2 * sqrt((x-0.5)**2 + (y-0.5)**2)
    theta = (90 - degrees(np.angle((x-0.5) + (y-0.5)*1j))) / 180
    print(f'{s_name}Dis: {dis}, {s_name}Theta: {theta}, {s_name}IsMute: {isMute}, {s_name}Amp: {amp}')
    client_to_tidalm.send_message('/ctrl', [f'{s_name}Dis', dis])
    client_to_tidalm.send_message('/ctrl', [f'{s_name}Theta', theta])
    client_to_tidalm.send_message('/ctrl', [f'{s_name}Amp', amp])
    client_to_tidalm.send_message('/ctrl', [f'{s_name}IsMute', isMute])


class Websocket_Server():

    def __init__(self, host, port):
        self.server = WebsocketServer(
            port=port,
            host=host,
            loglevel=logging.DEBUG,
        )
        self.client_ids = []

    # クライアント接続時に呼ばれる関数
    def new_client(self, client, server):
        print("new client connected and was given id {}".format(client['id']))
        self.client_ids.append(client['id'])

    # クライアント切断時に呼ばれる関数
    def client_left(self, client, server):
        print("client({}) disconnected".format(client['id']))
        self.client_ids.remove(client['id'])


    # クライアントからメッセージを受信したときに呼ばれる関数
    def message_received(self, client, server, message):
        print("client({}) said: {}".format(client['id'], message))
        message = json.loads(message)
        if message['type']=='access':
            # クライアントID
            message['connectionId'] = client['id']
            self.server.send_message(client, json.dumps(message))
            # 今の音の状態
            sound_state = {}
            state_file_path = 'state/sound_state.json'
            if os.path.isfile(state_file_path):
              with open('state/sound_state.json') as f:
                  sound_state = json.load(f)
              sound_state_msg = {}
              for k in sound_state.keys():
                sound_state_msg = {'type': k}
                sound_state_msg.update(sound_state[k])
                self.server.send_message(client, json.dumps(sound_state_msg))
            print('### all client_ids ###')
            print(self.client_ids)
        else:
            # 全クライアントにメッセージを送信
            self.server.send_message_to_all(json.dumps(message))
            if message['type']=='rain':
                client_to_sc.send_message('/n_set', [rainNode, 'amp', message['value']])
                client_to_tidal.send_message('/ctrl', ['rain', message['value']])
            if message['type']=='road':
                client_to_sc.send_message('/n_set', [backgroundNode, 'amp', message['value']])
            if message['type']=='pond':
                client_to_tidal.send_message('/ctrl', ['pond', message['value']])
            if message['type'] in ['synth', 'bird1', 'bird2', 'dove', 'crow']:
                send_position(message)
    
    # サーバーを起動する
    def run(self):
        # クライアント接続時のコールバック関数にself.new_client関数をセット
        self.server.set_fn_new_client(self.new_client)
        # クライアント切断時のコールバック関数にself.client_left関数をセット
        self.server.set_fn_client_left(self.client_left)
    # メッセージ受信時のコールバック関数にself.message_received関数をセット
        self.server.set_fn_message_received(self.message_received) 
        self.server.run_forever()

if __name__ == '__main__':
  IP_ADDR = os.environ.get('REACT_APP_PRIVATE_IP', "0.0.0.0") # IPアドレスを指定
  PORT=9001 # ポートを指定
  ws_server = Websocket_Server(IP_ADDR, PORT)
  ws_server.run()