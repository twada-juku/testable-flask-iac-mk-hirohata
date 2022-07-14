動作確認
=======================

## 1. `.env` ファイルの準備

パスワード等の秘匿情報を記載するファイル `.env` を作成
（このファイルはバージョン管理システムに登録しません）

```sh
$ touch .env
```

`.env` ファイルの中に `DEV_DB_PASSWORD` を1行加える
```
DEV_DB_PASSWORD=何かパスワードを書いてください
```

`.env` ファイルの中に `SECRET_KEY` を1行加える
```
SECRET_KEY=長めの文字列を書いてください
```


## 2. ビルドしてテスト

### Docker イメージのビルド

```sh
$ docker buildx bake --load -f docker-bake.hcl
```

### migration を反映してテストDBの設計を最新まで上げる

```sh
$ docker compose run --rm test alembic upgrade head
```

### テストの実行

```sh
$ python -m pytest
```

### テストが終わったら付随するコンテナの終了

```sh
$ docker compose stop
```


## 3. Google Cloud 上にインフラを構築


### インフラ操作関係の Docker イメージのビルド

```sh
$ docker buildx bake --load -f docker-bake.hcl iac-image
```

### 作業開始

iacコンテナに入る

```sh
$ docker compose run --rm iac bash
```

以降の作業は全て iac コンテナ内で行います。
（iac コンテナ内での作業は `(iac)$` と表現します）

### gcloud init

コンテナ内で GCP 認証とプロジェクト紐付け

```sh
(iac)$ gcloud init --console-only
```

提示された URL にアクセスして認証を行う


### Terraform の初期設定スクリプト実行

#### 自動化関係のファイルの生成

```sh
(iac)$ ./iac/setup_env.sh GitHubアカウント名 GitHubリポジトリ名
（例: ./iac/setup_env.sh twada twada-juku/testable-flask-iac-twada）
```

このコマンドで下記の自動化関係のファイルが生成されます。これらのファイルは GitHub にコミットして使います。

- `.ci_env`
- `iac/staging/terraform.tf`
- `iac/production/terraform.tf`
- `iac/services/Makefile`
- `iac/production/Makefile`


#### terraform の初期設定

```sh
(iac)$ ./iac/setup_gcp_terraform.sh GitHubアカウント名
（例: ./iac/setup_gcp_terraform.sh twada）
```

このコマンドで Terraform を実行するためのサービスアカウントを作成し、権限などを付与します。


### Terraform の実行

#### GCP の各種サービスの有効化

twada塾では GCP のプロジェクトを共有しているのでプロジェクトで誰か一人がやればいい作業ですが、重複して実行しても問題はありません

```sh
(iac)$ cd iac/services
(iac)$ make init
(iac)$ make plan
(iac)$ make apply
(iac)$ cd -
```

### Terraform を実行して GCP 上に各自の本番環境を作成

この作業で GCP 上に各自の本番環境を作成します。

```sh
(iac)$ cd iac/production
(iac)$ make init
(iac)$ make plan
(iac)$ make apply
(iac)$ cd -
```

なお、DB インスタンス作成には15分くらいかかります。最初に本番 DB のパスワード入力を求められます。


### iac コンテナから出る

```sh
(iac)$ exit
```


## 4. GitHub Actions で CI/CD 環境を構築

### GitHub Actions の Secrets に下記の情報を登録

- `SECRET_KEY` Flask に渡す秘匿文字列
- `DEV_DB_PASSWORD` テストDBのパスワード
- `PROD_DB_PASSWORD` 本番DBのパスワード

あとは main ブランチやプルリクエストに git push するだけです。
プルリクエストでは CI とステージング環境へのデプロイが走り、 main ブランチではデプロイが走ります。

確認のために、まずは main ブランチで初回 deploy を行ってください。
main ブランチの動作が確認できたら、プルリクエストの動作も確認してみてください。

GitHub Actions の実行結果画面を確認し、 Cloud Run のデプロイタスクが生成した URL にアクセスして本番環境の動作確認をしてください。


ここまでで、動作確認は完了です。



プロジェクト構造
=======================

```
.
├── .ci_env
├── .dockerignore
├── .env
├── .gcloud-config
├── .github
│   ├── actions
│   │   ├── gauth
│   │   │   └── action.yml
│   │   └── resource-names
│   │       └── action.yml
│   └── workflows
│       ├── build-images.yml
│       ├── cd.yml
│       ├── ci.yml
│       ├── deploy-cloudrun.yml
│       ├── large-test.yml
│       ├── medium-test.yml
│       ├── migrate-db.yml
│       ├── provisioning.yml
│       └── small-test.yml
├── .gitignore
├── .terraform-account-credential.json
├── Dockerfile
├── README.md
├── alembic.ini
├── docker-bake.ci.hcl
├── docker-bake.hcl
├── docker-compose.ci.yml
├── docker-compose.prod.yml
├── docker-compose.yml
├── docker-entrypoint
│   ├── dev.sh
│   ├── medium-test-on-ci.sh
│   ├── prod.sh
│   └── test.sh
├── iac
│   ├── Dockerfile
│   ├── production
│   │   ├── .terraform.lock.hcl
│   │   ├── Makefile
│   │   ├── main.tf
│   │   └── terraform.tf
│   ├── services
│   │   ├── .terraform.lock.hcl
│   │   ├── Makefile
│   │   ├── main.tf
│   │   └── terraform.tfstate
│   ├── setup_env.sh
│   ├── setup_gcp_terraform.sh
│   └── staging
│       ├── .terraform.lock.hcl
│       ├── main.tf
│       └── terraform.tf
├── instance
├── migrations
│   ├── env.py
│   ├── script.py.mako
│   └── versions
│       ├── 20210609_234814_17b191d162a9_create_projects.py
│       ├── 20210610_003109_f4577bb3e45c_create_technologies.py
│       ├── 20210610_005157_aae63862196e_create_choices.py
│       └── 20211119_004445_242bd665c08a_add_icon_url_to_technologies.py
├── pytest.ini
├── requirements
│   ├── dev.in
│   ├── dev.txt
│   ├── prod.in
│   ├── prod.txt
│   ├── small-test.in
│   └── small-test.txt
├── stacks
│   ├── __init__.py
│   ├── config.py
│   ├── db.py
│   ├── gunicorn.conf.py
│   ├── models.py
│   ├── projects.py
│   ├── static
│   │   └── dashboard.css
│   ├── technologies.py
│   ├── templates
│   │   ├── _formhelpers.html.jinja
│   │   ├── base.html.jinja
│   │   ├── dashboard.html.jinja
│   │   ├── hello.html.jinja
│   │   ├── projects
│   │   │   ├── index.html.jinja
│   │   │   └── show.html.jinja
│   │   └── technologies
│   │       ├── index.html.jinja
│   │       ├── new.html.jinja
│   │       └── show.html.jinja
│   └── validators.py
└── tests
    ├── __init__.py
    ├── conftest.py
    ├── large
    │   ├── __init__.py
    │   ├── conftest.py
    │   └── test_selenium.py
    ├── medium
    │   ├── __init__.py
    │   ├── conftest.py
    │   ├── python_logo.png
    │   ├── test_dashboard.py
    │   ├── test_projects.py
    │   └── test_technologies.py
    ├── misc
    │   └── fake-gcs
    │       ├── dev-bucket
    │       └── test-bucket
    │           └── .keep
    └── small
        ├── __init__.py
        └── test_models.py
```


手元のマシンでの開発
=======================

### Docker イメージをキャッシュ無しでフルリビルドするときは

```sh
$ docker buildx bake --no-cache --load -f docker-bake.hcl
```


ローカルテスト環境（test）
---------------------------------------

#### テスト環境のインタラクティブシェルに入る

```sh
$ docker compose run --rm test bash
```

#### インタラクティブシェル内でテストの実行

```sh
$ pytest tests/
```


ローカル動作確認環境（dev）
---------------------------------------

### 開発DBを最新まで上げる

```sh
$ docker compose run --rm dev alembic upgrade head
```

### 開発サーバ起動

```sh
$ docker compose up web-dev
```

http://localhost:5050 でアクセス。Ctrl-C で終了。

### 付随するコンテナの終了

```sh
$ docker compose stop
```


MIGRATION について
---------------------------------------

### alembic のドキュメント

- [Alembic Documentation](https://alembic.sqlalchemy.org/en/latest/index.html)
- [Alembic Tutorial](https://alembic.sqlalchemy.org/en/latest/tutorial.html)


### 対話的に操作する

対話的に操作する際には対象の環境(`dev` または `test`)のインタラクティブシェルに入る

```
$ docker compose run --rm dev bash
$ docker compose run --rm test bash
```

### migration の実行

```sh
$ alembic upgrade head
```

### バージョンを一つ戻す

```sh
$ alembic downgrade -1
```

### バージョン履歴を見る

```sh
$ alembic history --verbose
```

### 生成される差分があるか(=手元のモデルのコードとDBの間に差分があるか)チェック

```sh
$ alembic-autogen-check --config alembic.ini
```

### migration ファイルの生成

```sh
$ alembic revision --autogenerate -m 'migration_名を_英語で_つける'
```
# testable-flask-iac-mk-hirohata
