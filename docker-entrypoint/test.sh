#!/bin/sh

set -e

# 各サーバの立ち上がりを待つ
wait-for-it selenium-chrome:4444
wait-for-it fake-gcs-server:4443
wait-for-it db-test:5433
wait-for-it web-test:5000

# fake-gcs-server の使うディレクトリを作成
mkdir -p tests/misc/fake-gcs/test-bucket

# DB 定義を最新まで上げる
# alembic upgrade head

exec "$@"
