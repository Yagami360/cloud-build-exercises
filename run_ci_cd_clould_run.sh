#!/bin/sh
set -eu
TRIGER_BRANCH_NAME=cloud_run
PROJECT_ID=my-project2-303004
SERVICE_NAME=cloud-build-sample
HOST_ADRESS=https://${SERVICE_NAME}-zilzej7vmq-uc.a.run.app
PORT=8080

# CI/CD トリガー発行
#git checkout -b ${TRIGER_BRANCH_NAME}
git add .
git commit -m "a"
git push origin ${TRIGER_BRANCH_NAME}

# ビルド結果の表示
sleep 180
#gcloud builds describe ${BUILD_ID}

# テスト実行（リクエスト処理）
sleep 5
python api/request.py --host ${HOST_ADRESS} --port ${PORT} --request_value 1 --debug
python api/request.py --host ${HOST_ADRESS} --port ${PORT} --request_value 0 --debug
