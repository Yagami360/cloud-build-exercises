#!/bin/sh
set -eu
TRIGER_BRANCH_NAME=local
PROJECT_ID=my-project2-303004
IMAGE_NAME=api-sample-image

# CI/CD トリガー発行
#git checkout -b ${TRIGER_BRANCH_NAME}
git add .
git commit -m "a"
git push origin ${TRIGER_BRANCH_NAME}

# Container Registry とやり取りするときに Container Registry 認証情報を使用するよう Docker を構成
gcloud auth configure-docker

# docker image を実行
docker run gcr.io/${PROJECT_ID}/${IMAGE_NAME}

# ビルド結果の表示
#gcloud builds describe ${BUILD_ID}