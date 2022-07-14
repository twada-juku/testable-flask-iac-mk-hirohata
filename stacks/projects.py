from flask import (
    Blueprint, render_template
)
from .models import Project

def create_bp(sa_session):
    bp = Blueprint('projects', __name__)

    @bp.get('/')
    def index():
        projects = sa_session.query(Project).all()
        return render_template('projects/index.html.jinja', projects=projects)

    @bp.get('/<url_name>')
    def show(url_name):
        project = sa_session.query(Project).filter_by(url_name=url_name).first()
        return render_template('projects/show.html.jinja', project=project)

    return bp
