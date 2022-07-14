#!/bin/sh

set -e

# DB サーバの立ち上がりを待つ
wait-for-it db-dev:5432
wait-for-it fake-gcs-server:4443

# fake-gcs-server の使うディレクトリを作成
mkdir -p tests/misc/fake-gcs/dev-bucket

# migration は手動で行う
# alembic upgrade head

exec "$@"
