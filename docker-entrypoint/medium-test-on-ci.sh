#!/bin/sh

set -e

# 各サーバの立ち上がりを待つ
wait-for-it fake-gcs-server:4443
wait-for-it db-test:5433

# fake-gcs-server の使うディレクトリを作成
mkdir -p tests/misc/fake-gcs/test-bucket

exec "$@"
