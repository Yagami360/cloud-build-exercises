#!/bin/sh
set -eu
GITHUB_REPOGITRY_NAME=cloud-build-exercises
GITHUB_USER_NAME=Yagami360
CLOUD_BUILD_YAML_FILE_PATH="cloudbuild/cloudbuild_gke_gpu.yml"    # ビルド構成ファイルのパス
TRUGER_NAME=push-trigger-gke-gpu                                  # CI/CD トリガー名
TRIGER_BRANCH_NAME=gke_gpu                                        # CI/CD トリガーを発行する git ブランチ名

PROJECT_ID=my-project2-303004           # GCP のプロジェクト名
CLUSTER_NAME=cloud-build-gpu-cluster    # GKE クラスタの名前
SERVICE_NAME=cloud-build-gpu-service    # GKE サービス名 
PORT=80

#------------------------------------------
# 各種APIサービスを有効化する。 
#------------------------------------------
# cloudbuild.googleapis.com : Cloud Build API
# container.googleapis.com : Kubernetes Engine AP
# containerregistry.googleapis.com : Container Registry API
# cloudresourcemanager.googleapis.com : Cloud Resource Manager API
gcloud services enable \
    cloudbuild.googleapis.com \
    container.googleapis.com \
    containerregistry.googleapis.com \
    cloudresourcemanager.googleapis.com

#------------------------------------------
# 本レポジトリの Cloud Source Repositories への登録（ミラーリング）
#------------------------------------------
# [ToDo] CLI で自動化

#------------------------------------------
# Cloud Build と GitHub の連携設定
#------------------------------------------
# [ToDo] CLI で自動化 

#------------------------------------------
# CI/CD を行う GCP サービスの IAM 権限設定
#------------------------------------------
set +e
PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} --format='get(projectNumber)')"

# Cloud Build サービスアカウントに「Kubernetes Engine 開発者」のロールを付与
gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} \
    --member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
    --role=roles/container.developer

# Cloud Build サービスアカウントに「Kubernetes Engine 管理者」のロールを付与
gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} \
    --member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
    --role=roles/container.admin

set -e

#------------------------------------------
# CI/CD を行うトリガーとビルド構成ファイルの反映
#------------------------------------------
if [ ! "$(gcloud beta builds triggers list | grep "name: ${TRUGER_NAME}")" ] ;then
    gcloud beta builds triggers create github \
        --name=${TRUGER_NAME} \
        --repo-name=${GITHUB_REPOGITRY_NAME} \
        --repo-owner=${GITHUB_USER_NAME} \
        --branch-pattern=${TRIGER_BRANCH_NAME} \
        --build-config=${CLOUD_BUILD_YAML_FILE_PATH}
fi

#------------------------------------------
# GKE クラスタを作成済みの場合は削除
#------------------------------------------
if [ "$(gcloud container clusters list | grep ${CLUSTER_NAME})" ] ; then
    gcloud container clusters delete ${CLUSTER_NAME} --quiet
    sleep 10
fi

#------------------------------------------
# CI/CD トリガー発行
#------------------------------------------
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

#------------------------------------------
# ビルド待ち＆テスト処理
#------------------------------------------
while :
do
    BUILD_STATUS=`gcloud builds list | sed -n 2p | sed 's/ (+. more//g' | awk '{print $6}'`
    echo "${BUILD_STATUS} : ビルド実行中..."
    sleep 5

    if [ ${BUILD_STATUS} = "SUCCESS" ] ; then
        echo "${BUILD_STATUS} : ビルド成功"

        # クラスタの認証情報を取得する
        gcloud container clusters get-credentials ${CLUSTER_NAME}

        # クラスタの各種情報確認
        kubectl get pods
        kubectl get deployments
        kubectl get service

        # テスト実行（リクエスト処理）
        EXTERNAL_IP=`kubectl describe service ${SERVICE_NAME} | grep "LoadBalancer Ingress" | awk '{print $3}'`
        python api/request.py --host ${EXTERNAL_IP} --port ${PORT} --request_value 1 --debug
        python api/request.py --host ${EXTERNAL_IP} --port ${PORT} --request_value 0 --debug
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
