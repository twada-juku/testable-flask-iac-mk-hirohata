#!/bin/sh

set -e

# Cloud SQL Proxy の立ち上がりを待つ
wait-for-it db-prod:5432

# DB 定義を最新まで上げる
# alembic upgrade head

exec "$@"
