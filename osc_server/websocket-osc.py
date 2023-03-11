import socket
from pythonosc import udp_client, osc_server
import math

client_to_tidalm = udp_client.SimpleUDPClient('127.0.0.1', 6061)
client_to_sc = udp_client.SimpleUDPClient('127.0.0.1', 57110)

HOST_NAME = "0.0.0.0"
PORT = 57100
#ipv4を使うので、AF_INET
#tcp/ip通信を使いたいので、SOCK_STREAM
sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
#localhostとlocal portを指定
sock.bind((HOST_NAME,PORT))
#server動作開始
sock.listen(1)
#接続を許可して、待つ
client,remote_addr = sock.accept()
print("accepted remote. remote_addr {}.".format(remote_addr))
while True:
    #接続されたら、データが送られてくるまで待つ
    rcv_data = client.recv(1024)
    #接続が切られたら、終了
    if not rcv_data:
        print("receive data don't exist")
        break
    else:
        txt = rcv_data.decode("utf-8")
        print("receive data : {} ".format(txt))
        #clientにOKを送信
        # client.sendall('OK\n'.encode())
        try:
            x, y, z = txt.split(',')
            x = float(x)
            y = float(y)
            z = float(z)
            if z != 0:
              theta = math.atan(y / z) / math.pi
            else:
              if y<0:
                theta = -0.5
              else:
                theta = 0.5
            client_to_tidalm.send_message('/ctrl', ['synthTheta', theta])
        except:
           pass



print("close client communication")
#clientとserverのsocketを閉じる
client.close()
sock.close()



# import time
# import argparse
# from pythonosc.dispatcher import Dispatcher
# from pythonosc import udp_client, osc_server
# from typing import List, Any

# # touch designerに送信するために、相手のipとportを指定
# parser = argparse.ArgumentParser()
# parser.add_argument('--init', action='store_true')
# parser.add_argument("--td_ip",
#     default="192.168.0.31", help="The ip to send")
# parser.add_argument("--td_port",
#     type=int, default=2020, help="The port to send")
# parser.add_argument("--my_port",
#     type=int, default=57100, help="The port to listen on")
# args = parser.parse_args()

# # 送信用
# client_to_tidal = udp_client.SimpleUDPClient('127.0.0.1', 6060)
# client_to_sc = udp_client.SimpleUDPClient('127.0.0.1', 57110)
# client_to_sd = udp_client.SimpleUDPClient('127.0.0.1', 57120)
# client_to_td = udp_client.SimpleUDPClient(args.td_ip, args.td_port)


# def handler(address: str, *args: List[Any]) -> None:
#     """touch designerから受信用の関数"""
#     # global scene1n1, scene1n2, scene2n1, scene2n2, riverwalk_n
#     try:
#         if len(args) > 0:
#           print(args)

#     except ValueError:
#         pass

# if __name__ == "__main__":
#     dispatcher = Dispatcher()
#     dispatcher.map("/*", handler)

#     server = osc_server.ThreadingOSCUDPServer(
#         ('0.0.0.0', args.my_port), dispatcher)
#     print("Serving on {}".format(server.server_address))
#     server.serve_forever()