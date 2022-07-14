# 最新は 3.10 だが本番用 distroless イメージの python バージョンが 3.9 なので合わせる
FROM python:3.9-slim-bullseye as base

WORKDIR /app

RUN apt-get update
RUN apt-get install -y --no-install-recommends locales wait-for-it
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8

ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
ENV TZ JST-9

# pip の --root-user-action を使うためアップグレード
RUN pip install --upgrade pip setuptools pip-tools


# 開発環境用ステージ
FROM base as dev
# 開発環境用と本番環境用の依存定義ファイルをすべて使う
COPY requirements/prod.txt requirements/small-test.txt requirements/dev.txt ./requirements/
RUN pip-sync requirements/prod.txt requirements/small-test.txt requirements/dev.txt --pip-args "--root-user-action=ignore --no-cache-dir"


# 本番環境の依存ライブラリ等インストール用ステージ
FROM base as builder
# 本番環境用の依存定義ファイルだけを使う
COPY requirements/prod.txt ./requirements/
RUN pip-sync requirements/prod.txt --pip-args "--root-user-action=ignore --no-cache-dir"


# 本番環境用ステージ
FROM gcr.io/distroless/python3 as prod

# ローカル開発との競合を避けるため WORKDIR は場所を変え /app ではなく /opt/app/ を使う
WORKDIR /opt/app/

# ENV TZ JST-9

# ログをバッファリングせずに標準出力（Knative logs）に出す
ENV PYTHONUNBUFFERED True

# builder ステージからインストール済みライブラリだけ取得する
COPY --from=builder /usr/local/lib/python3.9/site-packages /root/.local/lib/python3.9/site-packages
# Flask サーバの起動に使用する gunicorn コマンドも builder ステージからコピーする
COPY --from=builder /usr/local/bin/gunicorn /opt/app/gunicorn

# ローカルのファイルシステムからプロダクトコードのみをコピーする
COPY stacks /opt/app/stacks

# distroless はシェルが無いので設定ファイルで CloudRun から渡される PORT 環境変数を展開する
CMD ["gunicorn", "--config", "/opt/app/stacks/gunicorn.conf.py"]
