import websocket
from pythonosc.dispatcher import Dispatcher
from pythonosc import udp_client, osc_server
import json
import rel
from math import sqrt, degrees
import numpy as np
import pandas as pd
import os

state_df = pd.DataFrame()

def on_error(ws, error):
    print(error)

def on_close(ws, close_status_code, close_msg):
    print("### closed ###")

def on_open(ws):
    print("Opened connection")

def on_message(ws, message):
    global state_df
    message = json.loads(message)
    state_df = pd.concat([state_df, pd.json_normalize(message).set_index('type')])
    state_df = state_df[~state_df.index.duplicated(keep='last')].fillna(0)
    sound_state = state_df.to_dict(orient='index')
    with open('state/sound_state.json', 'w') as f:
        json.dump(sound_state, f, indent=4)

if __name__ == '__main__':
    IP_ADDR = os.environ.get('REACT_APP_PRIVATE_IP', "localhost") # IPアドレスを指定
    wsapp = websocket.WebSocketApp(
        f"ws://{IP_ADDR}:9001",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
        )
    wsapp.run_forever(dispatcher=rel, reconnect=3)
    rel.signal(2, rel.abort)  # Keyboard Interrupt
    rel.dispatch()
