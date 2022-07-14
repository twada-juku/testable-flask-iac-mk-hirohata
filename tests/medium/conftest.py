from stacks import create_app
from stacks.config import TestingConfig
import pytest

@pytest.fixture
def client(tx_session):
    test_app = create_app(config=TestingConfig(), extra_config={
        'SQL_ALCHEMY_SESSION': tx_session
    })
    with test_app.test_client() as client:
        yield client
