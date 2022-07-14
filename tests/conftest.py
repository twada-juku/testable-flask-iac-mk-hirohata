# borrowed from https://gist.github.com/kissgyorgy/e2365f25a213de44b9a2
from sqlalchemy import create_engine
from sqlalchemy.orm import Session
import pytest
import os

@pytest.fixture(scope='session')
def sa_engine(pytestconfig):
    """pytest のセッションで共有する SQLAlchemy engine インスタンスを生成"""
    echo = False
    # pytest 実行時に -v -s オプションが付けられたときは SQL を標準出力に出す
    if pytestconfig.getoption('verbose') > 0 and pytestconfig.getoption('capture') == 'no':
        echo = True
    return create_engine(os.environ['DATABASE_URL'], echo=echo)

@pytest.fixture
def tx_session(sa_engine):
    """各テスト終了時にロールバックするトランザクションに包まれた SQLAlchemy session を生成する"""
    connection = sa_engine.connect()
    # begin the nested transaction
    transaction = connection.begin()
    # use the connection with the already started transaction
    session = Session(bind=connection)
    yield session
    session.close()
    # roll back the broader transaction
    transaction.rollback()
    # put back the connection to the connection pool
    connection.close()
