from stacks.models import Project, Technology, Choice
import pytest
pytestmark = [pytest.mark.small]

@pytest.fixture
def skyway():
    return Project(name='SkyWay', url_name='skyway')

@pytest.fixture
def nginx():
    return Technology(name='nginx', url_name='nginx')

class skywayがnginxを選択している場合:

    @pytest.fixture(autouse=True)
    def skyway_chooses_nginx(self, skyway, nginx):
        skyway.technologies.append(nginx)

    @pytest.fixture
    def choice(self, skyway):
        return skyway.choices[0]

    class skywayの:
        def choicesに1件入っていること(self, skyway):
            assert len(skyway.choices) == 1
        def technologiesに1件入っていること(self, skyway):
            assert len(skyway.technologies) == 1
        def technologiesに入っているのはnginxであること(self, skyway, nginx):
            assert skyway.technologies[0] is nginx

    class nginxの:
        def choicesに1件入っていること(self, nginx):
            assert len(nginx.choices) == 1
        def choiceはskywayのchoiceと同一インスタンスであること(self, choice, nginx):
            assert nginx.choices[0] is choice
        def projectsに1件入っていること(self, nginx):
            assert len(nginx.projects) == 1
        def projectsに入っているのはskywayであること(self, nginx, skyway):
            assert nginx.projects[0] is skyway

    class skywayのchoiceの:
        def projectはskywayであること(self, choice, skyway):
            assert choice.project is skyway
        def technologyはnginxであること(self, choice, nginx):
            assert choice.technology is nginx
