from stacks.models import Project
import pytest
pytestmark = [pytest.mark.medium]

@pytest.fixture
def setup_projects(tx_session):
    skyway = Project(name='SkyWay', url_name='skyway')
    nework = Project(name='NeWork', url_name='nework')
    tx_session.add(skyway)
    tx_session.add(nework)
    tx_session.flush()

@pytest.mark.usefixtures('setup_projects')
def test_GET_projects(client, tx_session):
    resp = client.get('/projects', follow_redirects=True)
    body = resp.get_data(as_text=True)
    print(str(body))
    assert 'プロジェクト一覧' in body
    assert 'SkyWay' in body
    assert 'NeWork' in body

@pytest.mark.usefixtures('setup_projects')
def test_GET_project_detail(client, tx_session):
    resp = client.get('/projects/skyway', follow_redirects=True)
    body = resp.get_data(as_text=True)
    print(str(body))
    assert 'プロジェクト詳細' in body
    assert 'SkyWay' in body
    assert 'NeWork' not in body
