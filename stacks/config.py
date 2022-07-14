# Flask の環境毎の設定を行う方法を踏襲
# https://flask.palletsprojects.com/en/2.0.x/config/#development-production
import os
import google.cloud.storage.blob

def _or_die(key):
    if key not in os.environ:
        raise KeyError(f'No {key} set for Flask application')
    return os.environ[key]

class Config:
    @property
    def DATABASE_URL(self):
        return _or_die('DATABASE_URL')

    @property
    def SECRET_KEY(self):
        return _or_die('SECRET_KEY')

    def configure(self, app):
        return self

class DevelopmentConfig(Config):
    DEBUG = True
    TEMPLATES_AUTO_RELOAD = True
    GCS_API_ENDPOINT = 'http://fake-gcs-server:4443'
    CLOUD_STORAGE_BUCKET_NAME = 'dev-bucket'

    def configure(self, app):
        # テンプレートの自動リロード設定
        app.jinja_env.auto_reload = True
        # Blob の public_url が googleの URL になってしまうので fake-gcs-server を指すようにモンキーパッチする
        google.cloud.storage.blob._API_ACCESS_ENDPOINT = 'http://localhost:4443'
        return self

class TestingConfig(DevelopmentConfig):
    TESTING = True
    # Small/Medium Test の際は CSRF protection をオフにする
    WTF_CSRF_ENABLED = False
    CLOUD_STORAGE_BUCKET_NAME = 'test-bucket'

class ProductionConfig(Config):
    GCS_API_ENDPOINT = 'https://storage.googleapis.com'

    @property
    def CLOUD_STORAGE_BUCKET_NAME(self):
        return _or_die('CLOUD_STORAGE_BUCKET_NAME')

environments = {
    'development': DevelopmentConfig,
    'production': ProductionConfig
}
