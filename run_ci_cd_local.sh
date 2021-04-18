#!/bin/sh
set -eu
TRIGER_BRANCH_NAME=local
PROJECT_ID=my-project2-303004
IMAGE_NAME=api-sample-image
CONTAINER_NAME=api-sample-container

# CI/CD トリガー発行
#git checkout -b ${TRIGER_BRANCH_NAME}
git add .
git commit -m "a"
git push origin ${TRIGER_BRANCH_NAME}

# ビルド結果の表示
sleep 180
#gcloud builds describe ${BUILD_ID}

# Container Registry とやり取りするときに Container Registry 認証情報を使用するよう Docker を構成
gcloud auth configure-docker

# API 実行（デプロイした docker image 実行）
docker run -it --rm -d --name ${CONTAINER_NAME} gcr.io/${PROJECT_ID}/${IMAGE_NAME}
docker logs ${CONTAINER_NAME}

# テスト実行（リクエスト処理）
sleep 5
python api/request.py --host 0.0.0.0 --port 5000 --request_value 1 --debug
python api/request.py --host 0.0.0.0 --port 5000 --request_value 0 --debug
