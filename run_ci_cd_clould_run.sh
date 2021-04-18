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
BUILD_ID=`gcloud builds list | sed -n 2p | awk '{print $1}'`

for in `seq 1000`
do
    echo "ビルド実行中..."
    sleep 1
    BUILD_STATUS=`gcloud builds list | sed -n 2p | awk '{print $6}'`

    if [ ${BUILD_STATUS} = "SUCCESS" ] ; then
        echo "ビルド成功"
        gcloud builds describe ${BUILD_ID}

        # テスト実行（リクエスト処理）
        python api/request.py --host ${HOST_ADRESS} --port ${PORT} --request_value 1 --debug
        python api/request.py --host ${HOST_ADRESS} --port ${PORT} --request_value 0 --debug
    elif [ ${BUILD_STATUS} = "FAILURE" ] ; then
        echo "ビルド失敗"
        gcloud builds describe ${BUILD_ID}
    elif [ ${BUILD_STATUS} = "CANCELLED" ] ; then
        echo "ユーザーによるビルドのキャンセル"
        gcloud builds describe ${BUILD_ID}
    elif [ ${BUILD_STATUS} = "TIMEOUT" ] ; then
        echo "ビルドのタイムアウト"
        gcloud builds describe ${BUILD_ID}
    elif [ ${BUILD_STATUS} = "FAILED" ] ; then
        echo "ステップのタイムアウト"
        gcloud builds describe ${BUILD_ID}
    fi
done
