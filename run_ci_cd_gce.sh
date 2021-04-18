#!/bin/sh
set -eu
TRIGER_BRANCH_NAME=gce

# CI/CD トリガー発行
git checkout -b ${TRIGER_BRANCH_NAME}
git add .
git commit -m "a"
git push origin ${TRIGER_BRANCH_NAME}

# ビルド結果の表示
#gcloud builds describe ${BUILD_ID}