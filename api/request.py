# coding=utf-8
import os
import sys
import argparse
import json
from PIL import Image
from tqdm import tqdm 
import requests

# グローバル変数
IMG_EXTENSIONS = (
    '.jpg', '.jpeg', '.png', '.ppm', '.bmp', '.pgm', '.tif',
    '.JPG', '.JPEG', '.PNG', '.PPM', '.BMP', '.PGM', '.TIF',
)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', type=str, default="localhost", help="API サーバーのホスト名（コンテナ名 or コンテナ ID）")
    parser.add_argument('--port', type=str, default="5000", help="API サーバーのポート番号")
    parser.add_argument('--url', type=str, default="https://", help="URL")
    parser.add_argument('--use_url', action='store_true', help="URL指定有効化")
    parser.add_argument('--request_value', type=int, default=0, help="リクエストデータの値")
    parser.add_argument('--debug', action='store_true', help="デバッグモード有効化")
    args = parser.parse_args()
    if( args.debug ):
        for key, value in vars(args).items():
            print('%s: %s' % (str(key), str(value)))
    
    if(args.use_url):
        api_server_url = args.url + "/api_server"
    else:
        api_server_url = "http://" + args.host + ":" + args.port + "/api_server"
        #api_server_url = "http://" + args.host + ":" + args.port + "/"
    
    if( args.debug ):
        print( "api_server_url : ", api_server_url )

    #----------------------------------
    # リクエスト処理
    #----------------------------------
    request_msg = { 'value' : args.request_value }
    request_msg = json.dumps(request_msg)
    try:
        api_responce = requests.post( api_server_url, json=request_msg )
        api_responce = api_responce.json()
        if( args.debug ):
            print( "api_responce : ", api_responce )

        if( api_responce["status"] == "OK" ):
            sys.exit(0)
        else:
            sys.exit(1)

    except Exception as e:
        print( "通信失敗 [API server]" )
        print( "Exception : ", e )
        sys.exit(1)

