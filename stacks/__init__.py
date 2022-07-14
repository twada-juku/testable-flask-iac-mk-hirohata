import os

from flask import Flask, render_template
from flask_wtf.csrf import CSRFProtect
from .db import create_session
from .config import environments
from . import projects, technologies

# create_app 関数は Flask の Application Factory パターンを踏襲
# https://flask.palletsprojects.com/en/2.0.x/tutorial/factory/#the-application-factory
def create_app(config=None, extra_config=None):
    app = Flask(__name__, instance_relative_config=True)
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    if config is None:
        ConfigClass = environments[app.config['ENV']]
        config = ConfigClass()
    app.config.from_object(config.configure(app))

    if extra_config is not None:
        app.config.from_mapping(extra_config)

    CSRFProtect().init_app(app)
    sa_session = create_session(app.config)

    @app.get('/hello')
    def hello():
        return render_template('/hello.html.jinja')

    @app.get('/')
    def dashboard():
        return render_template('/dashboard.html.jinja')

    app.register_blueprint(projects.create_bp(sa_session), url_prefix='/projects')
    app.register_blueprint(technologies.create_bp(sa_session, app.config), url_prefix='/technologies')

    return app
