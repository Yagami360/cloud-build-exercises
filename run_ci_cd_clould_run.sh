#!/bin/sh
set -eu
GITHUB_REPOGITRY_NAME=cloud-build-exercises
GITHUB_USER_NAME=Yagami360
CLOUD_BUILD_YAML_FILE_PATH="cloudbuild/cloudbuild_cloud_run.yml"   # ビルド構成ファイルのパス

TRIGER_BRANCH_NAME=cloud_run        # CI/CD トリガーを発行する git ブランチ名
PROJECT_ID=my-project2-303004       # GCP のプロジェクト名
SERVICE_NAME=cloud-build-sample     # Clould Run の名前

#------------------------------------------
# CI/CD を行うトリガーとビルド構成ファイルの反映
#------------------------------------------
gcloud beta builds triggers create github \
    --repo-name=${GITHUB_REPOGITRY_NAME} \
    --repo-owner=${GITHUB_USER_NAME} \
    --branch-pattern=${TRIGER_BRANCH_NAME} \
    --build-config=${CLOUD_BUILD_YAML_FILE_PATH}

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
sleep 10

#-----------------------
# ビルド待ち＆テスト処理
#-----------------------
while :
do
    BUILD_STATUS=`gcloud builds list | sed -n 2p | sed 's/ (+. more//g' | awk '{print $6}'`
    echo "${BUILD_STATUS} : ビルド実行中..."
    sleep 5

    if [ ${BUILD_STATUS} = "SUCCESS" ] ; then
        echo "${BUILD_STATUS} : ビルド成功"
        #BUILD_ID=`gcloud builds list | sed -n 2p | sed 's/ //g' | awk '{print $1}'`
        #gcloud builds describe ${BUILD_ID}

        # テスト実行（リクエスト処理）
        CLOUD_RUN_URL=`gcloud run services list --platform managed | grep ${SERVICE_NAME} | awk '{print $4}'`
        echo "CLOUD_RUN_URL : ${CLOUD_RUN_URL}"
        python api/request.py --url ${CLOUD_RUN_URL} --use_url --request_value 1 --debug
        python api/request.py --url ${CLOUD_RUN_URL} --use_url --request_value 0 --debug
        break
    elif [ ${BUILD_STATUS} = "FAILURE" ] ; then
        echo "${BUILD_STATUS} : ビルド失敗"
        BUILD_ID=`gcloud builds list | sed -n 2p | sed 's/ //g' | awk '{print $1}'`
        gcloud builds describe ${BUILD_ID}
        break
    elif [ ${BUILD_STATUS} = "CANCELLED" ] ; then
        echo "${BUILD_STATUS} : ユーザーによるビルドのキャンセル"
        BUILD_ID=`gcloud builds list | sed -n 2p | sed 's/ //g' | awk '{print $1}'`
        gcloud builds describe ${BUILD_ID}
        break
    elif [ ${BUILD_STATUS} = "TIMEOUT" ] ; then
        echo "${BUILD_STATUS} : ビルドのタイムアウト"
        BUILD_ID=`gcloud builds list | sed -n 2p | sed 's/ //g' | awk '{print $1}'`
        gcloud builds describe ${BUILD_ID}
        break
    elif [ ${BUILD_STATUS} = "FAILED" ] ; then
        echo "${BUILD_STATUS} : ステップのタイムアウト"
        BUILD_ID=`gcloud builds list | sed -n 2p | sed 's/ //g' | awk '{print $1}'`
        gcloud builds describe ${BUILD_ID}
        break
    fi
done
