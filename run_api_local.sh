#!/bin/sh
set -eu

docker-compose -f api/docker-compose.yml stop
docker-compose -f api/docker-compose.yml up -d
#docker exec -it api-sample-container bash

sleep 1
python api/request.py --host 0.0.0.0 --port 5000 --request_value 1 --debug
sleep 5
python api/request.py --host 0.0.0.0 --port 5000 --request_value 0 --debug
