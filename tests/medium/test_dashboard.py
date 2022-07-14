import pytest
pytestmark = [pytest.mark.medium]

def トップページにダッシュボードが表示されること(client):
    resp = client.get('/', follow_redirects=True)
    body = resp.get_data(as_text=True)
    assert '技術スタック共有' in body
