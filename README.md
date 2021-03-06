# Clould Build を用いた CI/CD
Clould Build を用いた CI/CD の練習用コード。<br>
Clould Build を用いて、`git push` をトリガーに、各種 GCPリソース（GCE, GKE, CloudFunction など）上で CI/CD 処理を自動的に行う。

<img src="https://user-images.githubusercontent.com/25688193/115104771-94c7d600-9f95-11eb-913c-a43b578b75b5.png" width="500"><br>

## ■ 使用法

<a id="事前準備"></a>

### ◎ 事前準備

1. 本レポジトリの Cloud Source Repositories への登録（ミラーリング）<br>
    1. [Cloud Source Repositories のコンソール画面](https://source.cloud.google.com/onboarding/welcome?hl=ja) に移動し、「リポジトリの追加」画面で、「外部レポジトリを接続」を選択する。<br>
        <img src="https://user-images.githubusercontent.com/25688193/115101103-7d302380-9f7c-11eb-89fa-d76d1546f0af.png" width="400"><br>
    1. 「外部レポジトリを接続」ボタン選択後に移行する画面で、GCP から GitHub アクセスのための認証を行い、Cloud Source Repositories で管理するレポジトリに、本レポジトリを選択する。<br>
        <img src="https://user-images.githubusercontent.com/25688193/115101325-13187e00-9f7e-11eb-88cc-1a804fb70e40.png" width="400"><br>
    1. レポジトリの接続に成功した場合、以下のような画面が表示される。最新の GitHun レポジトリの内容を反映させるためには、「設定 -> GitHub による同期」ボタンをクリックすればよい。<br>
        <img src="https://user-images.githubusercontent.com/25688193/115101438-1fe9a180-9f7f-11eb-9608-063b58a80c77.png" width="400"><br>

1. Cloud Build と GitHub の連携設定<br>
    1. [Cloud Build GitHub アプリ](https://github.com/marketplace/google-cloud-build) を GitHub に認証する。<br>
        <img src="https://user-images.githubusercontent.com/25688193/115101875-7b695e80-9f82-11eb-8dd6-4107b46dbd18.png" width="300"><br>
    1. Cloud Build GitHub アプリの認証完了後、Cloud Build の GitHub レポジトリの接続設定画面が表示されるので、本レポジトリを設定する。<br>
        <img src="https://user-images.githubusercontent.com/25688193/115101942-e61a9a00-9f82-11eb-86a5-1026f41a5fdf.png" width="500"><br>
    1. 本レポジトリが、Private 公開の場合は、[非公開 GitHub リポジトリへのアクセス](https://cloud.google.com/cloud-build/docs/access-private-github-repos?hl=ja) 記載の方法で ssh 鍵等の設定を行い、Cloud Build からアクセスできるようにする。

### ◎ CI/CD 処理

- ローカル環境での CI/CD : <br>
	```sh
	$ sh run_cicd_local.sh
	```

- GCE 環境での CI/CD<br>
    準備中 ...

- Cloud Run 環境での CI/CD<br>
    ```sh
    $ sh run_cicd_clould_run.sh
    ```

- Cloud Function 環境での CI/CD<br>
    ```sh
    $ sh run_cicd_clould_function.sh
    ```

- GKE 環境（CPU動作）での CI/CD<br>
    ```sh
    $ sh run_cicd_gke.sh
    ```

- GKE 環境（GPU動作）での CI/CD<br>
    準備中...
    <!--
    ```sh
    $ sh run_cicd_gke_gpu.sh
    ```
    -->

## ■ ToDO
- [ ] [事前準備](#事前準備)の処理を CLI で自動化する
- [ ] ローカル環境での CI/CD がうまく動作するようにする
- [ ] GCE 環境での CI/CD がうまく動作するようにする
- [ ] GKE 環境での CI/CD において、`cloudbuild_gke.yml` 内で GKE クラスタを作成できるようにする
- [ ] GKE 環境（GPUあり）での CI/CD がうまく動作するようにする
