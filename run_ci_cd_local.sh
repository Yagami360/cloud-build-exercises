#!/bin/sh
set -eu
TRIGER_BRANCH_NAME=local
PROJECT_ID=my-project2-303004
IMAGE_NAME=api-sample-image
CONTAINER_NAME=api-sample-container
HOST_ADRESS=0.0.0.0
PORT=5000

#-----------------------
# CI/CD トリガー発行
#-----------------------
# ${TRIGER_BRANCH_NAME} ブランチが存在しない場合
if [ "`git branch | grep ${TRIGER_BRANCH_NAME} | sed 's/ //g' | sed 's/*//g'`" != "${TRIGER_BRANCH_NAME}" ] ; then
    git checkout -b ${TRIGER_BRANCH_NAME}
fi

# 現在のブランチが ${TRIGER_BRANCH_NAME} でない場合
if [ "`git branch --contains=HEAD | sed 's/ //g' | sed 's/*//g'`" != "${TRIGER_BRANCH_NAME}" ] ; then
    git checkout ${TRIGER_BRANCH_NAME}
fi

git add .
git commit -m "run ci/cd on ${TRIGER_BRANCH_NAME} branch"
git push origin ${TRIGER_BRANCH_NAME}

#-----------------------
# Container Registry とやり取りするときに Container Registry 認証情報を使用するよう Docker を構成
#-----------------------
gcloud auth configure-docker

#-----------------------
# ビルド待ち＆テスト処理
#-----------------------
BUILD_ID=`gcloud builds list | sed -n 2p | awk '{print $1}'`

while :
do
    BUILD_STATUS=`gcloud builds list | sed -n 2p | sed 's/ (+. more//g' | awk '{print $6}'`
    echo "${BUILD_STATUS} : ビルド実行中..."
    sleep 5

    if [ ${BUILD_STATUS} = "SUCCESS" ] ; then
        echo "${BUILD_STATUS} : ビルド成功"
        gcloud builds describe ${BUILD_ID}

        # API 実行（デプロイした docker image 実行）
        docker run -it --rm -d --name ${CONTAINER_NAME} gcr.io/${PROJECT_ID}/${IMAGE_NAME}
        docker logs ${CONTAINER_NAME}

        # テスト実行（リクエスト処理）
        python api/request.py --host 0.0.0.0 --port 5000 --request_value 1 --debug
        python api/request.py --host 0.0.0.0 --port 5000 --request_value 0 --debug
        break
    elif [ ${BUILD_STATUS} = "FAILURE" ] ; then
        echo "${BUILD_STATUS} : ビルド失敗"
        gcloud builds describe ${BUILD_ID}
        break
    elif [ ${BUILD_STATUS} = "CANCELLED" ] ; then
        echo "${BUILD_STATUS} : ユーザーによるビルドのキャンセル"
        gcloud builds describe ${BUILD_ID}
        break
    elif [ ${BUILD_STATUS} = "TIMEOUT" ] ; then
        echo "${BUILD_STATUS} : ビルドのタイムアウト"
        gcloud builds describe ${BUILD_ID}
        break
    elif [ ${BUILD_STATUS} = "FAILED" ] ; then
        echo "${BUILD_STATUS} : ステップのタイムアウト"
        gcloud builds describe ${BUILD_ID}
        break
    fi
done
