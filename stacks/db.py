import os
from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker

def create_session(config):
    """SQLAlchemy の session を作成する。
    config 引数に既に（テスト用の） Session が格納されている場合はそちらを優先する"""
    if config is not None and 'SQL_ALCHEMY_SESSION' in config:
        return config['SQL_ALCHEMY_SESSION']
    engine = create_engine(config['DATABASE_URL'])
    sa_session = scoped_session(sessionmaker(bind=engine))
    return sa_session
