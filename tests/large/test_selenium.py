import pytest
import time
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait as wait
from selenium.webdriver.support import expected_conditions as EC
from stacks.models import Project, Technology
pytestmark = [pytest.mark.large]

def click_and_wait_next_page(driver, element):
    current_url = driver.current_url
    element.click()
    # 待ちが不安定なので明示的に sleep を入れる
    # wait(driver, 10).until(EC.url_changes(current_url))
    time.sleep(0.5)

def click_link_and_wait(driver, link_text):
    click_and_wait_next_page(driver, driver.find_element(by=By.LINK_TEXT, value=link_text))

@pytest.mark.learning
class Seleniumクライアントは:

    def helloエンドポイントにアクセスできること(self, driver):
        url = 'http://web-test:5000/hello'
        print(url)
        driver.get(url)
        assert driver.current_url == url
        html = driver.page_source
        print(html)
        page_h1_title = driver.find_element(by=By.TAG_NAME, value='h1').text
        assert 'Hello, Flask!' in page_h1_title

@pytest.fixture
def setup_projects(del_session):
    skyway = Project(name='SkyWay', url_name='skyway')
    nework = Project(name='NeWork', url_name='nework')
    del_session.add(skyway)
    del_session.add(nework)
    del_session.commit()

class Projectの:

    @pytest.mark.usefixtures('setup_projects')
    def 一覧画面からプロジェクト名をクリックして詳細に遷移できること(self, driver):
        driver.get('http://web-test:5000/projects')
        assert driver.current_url == 'http://web-test:5000/projects/'
        assert 'プロジェクト一覧' in driver.find_element(by=By.TAG_NAME, value='h1').text

        click_link_and_wait(driver, 'SkyWay')
        assert driver.current_url == 'http://web-test:5000/projects/skyway'
        assert 'SkyWay' in driver.find_element(by=By.TAG_NAME, value='h1').text

@pytest.fixture
def setup_technologies(del_session):
    javascript = Technology(name='JavaScript', url_name='javascript')
    nginx = Technology(name='Nginx', url_name='nginx')
    del_session.add(javascript)
    del_session.add(nginx)
    del_session.commit()

class Technologyの:

    @pytest.mark.usefixtures('setup_technologies')
    def 一覧画面から技術名をクリックして詳細に遷移できること(self, driver):
        driver.get('http://web-test:5000/technologies')
        assert driver.current_url == 'http://web-test:5000/technologies/'
        assert '技術一覧' in driver.find_element(by=By.TAG_NAME, value='h1').text

        click_link_and_wait(driver, 'JavaScript')
        assert driver.current_url == 'http://web-test:5000/technologies/javascript'
        assert 'JavaScript' in driver.find_element(by=By.TAG_NAME, value='h1').text

        click_link_and_wait(driver, '技術一覧')
        assert driver.current_url == 'http://web-test:5000/technologies/'

        click_link_and_wait(driver, 'Nginx')
        assert driver.current_url == 'http://web-test:5000/technologies/nginx'

    @pytest.mark.usefixtures('setup_technologies')
    def 一覧画面から新規登録画面に遷移して技術を登録できること(self, driver):
        driver.get('http://web-test:5000/technologies')

        click_link_and_wait(driver, '技術新規登録')
        assert driver.current_url == 'http://web-test:5000/technologies/new'
        driver.find_element(by=By.NAME, value='name').send_keys("うぇぶあーるてぃーしー")
        driver.find_element(by=By.NAME, value='url_name').send_keys("webrtc")

        click_and_wait_next_page(driver, driver.find_element(by=By.NAME, value='submit-button'))
        assert driver.current_url == 'http://web-test:5000/technologies/webrtc'
        assert 'うぇぶあーるてぃーしー' in driver.find_element(by=By.TAG_NAME, value='h1').text
