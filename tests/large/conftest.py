import pytest
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker
from stacks.models import Project, Technology, Choice
from selenium import webdriver

@pytest.fixture(scope='session')
def driver():
    """E2E テストで使用する Selenium WebDriver のインスタンス"""
    selenium_driver = webdriver.Remote(
        # ホスト名は docker-compose のサービス名と対応している
        command_executor="http://selenium-chrome:4444/wd/hub",
        options=webdriver.ChromeOptions(),
    )
    selenium_driver.implicitly_wait(10)
    yield selenium_driver
    selenium_driver.quit()

@pytest.fixture
def del_session(sa_engine):
    """各テスト終了時に DELETE ALL する SQLAlchemy session を生成する"""
    session = scoped_session(sessionmaker(bind=sa_engine))
    yield session
    # FK の被依存側から全件消去していく
    # TODO: ORM のメタデータから削除対象の列挙を自動化したい
    session.query(Choice).delete()
    session.query(Technology).delete()
    session.query(Project).delete()
    session.commit()
    session.close()
