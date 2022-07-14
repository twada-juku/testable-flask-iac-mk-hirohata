from stacks.models import Technology
import pytest
import os
from io import BytesIO
pytestmark = [pytest.mark.medium]

@pytest.fixture
def setup_technologies(tx_session):
    javascript = Technology(name='JavaScript', url_name='javascript')
    nginx = Technology(name='Nginx', url_name='nginx')
    tx_session.add(javascript)
    tx_session.add(nginx)
    tx_session.flush()

@pytest.mark.usefixtures('setup_technologies')
def 技術一覧画面に既にある技術が表示されること(client):
    resp = client.get('/technologies', follow_redirects=True)
    body = resp.get_data(as_text=True)
    assert '技術一覧' in body
    assert 'JavaScript' in body
    assert 'Nginx' in body

@pytest.mark.usefixtures('setup_technologies')
def 詳細画面にURLで示された技術の詳細が表示されること(client):
    resp = client.get('/technologies/javascript', follow_redirects=True)
    body = resp.get_data(as_text=True)
    assert '技術詳細' in body
    assert 'JavaScript' in body
    assert 'Nginx' not in body

def 技術新規登録画面に入力項目が表示されていること(client):
    resp = client.get('/technologies/new', follow_redirects=True)
    body = resp.get_data(as_text=True)
    print(body)
    assert '技術新規登録' in body
    assert '名称' in body
    assert '短縮名' in body

def 技術新規登録のPOSTリクエストを元にTechnologyが一件登録されること(client, tx_session):
    url_name = 'webrtc'
    technology = tx_session.query(Technology).filter_by(url_name=url_name).first()
    assert technology is None
    client.post('/technologies/', data=dict(
        name='WebRTC',
        url_name=url_name
    ), follow_redirects=True)
    technology = tx_session.query(Technology).filter_by(url_name=url_name).first()
    assert technology is not None
    assert technology.name == 'WebRTC'
    assert technology.url_name == 'webrtc'

@pytest.mark.usefixtures('setup_technologies')
def バリデーションに違反した場合には新規入力画面の当該の項目にエラーが表示されること(client):
    resp = client.post('/technologies/', data=dict(
        name='Nginx',
        url_name='nginx'
    ), follow_redirects=True)
    body = resp.get_data(as_text=True)
    print(body)
    assert '短縮名の値が既に使われています' in body

def 技術新規登録画面でアイコン画像が添付されるとアイコンURLが登録されること(client, tx_session):
    url_name = 'python'
    img_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'python_logo.png')
    with open(img_path, 'rb') as f:
        client.post('/technologies/', data=dict(
            name='Python',
            url_name=url_name,
            icon=(BytesIO(f.read()), 'python_logo.png')
        ), follow_redirects=True, content_type='multipart/form-data')
        technology = tx_session.query(Technology).filter_by(url_name=url_name).first()
        assert technology.name == 'Python'
        assert technology.url_name == 'python'
        assert technology.icon_url == 'http://localhost:4443/test-bucket/technologies/python.png'
