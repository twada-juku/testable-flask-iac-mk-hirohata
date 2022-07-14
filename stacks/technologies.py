import os
from flask import (
    Blueprint, render_template, url_for, redirect
)
from flask_wtf import FlaskForm
from flask_wtf.file import FileField, FileAllowed
from wtforms import StringField
from wtforms.validators import DataRequired
from google.cloud import storage
from .models import Technology
from .validators import unique_attr


def create_bp(sa_session, config):
    bp = Blueprint('technologies', __name__)

    # storage.Client はこのあたりで作れるのではないか

    # sa_session を使うのでここに書かなければならない
    class NewTechnologyForm(FlaskForm):
        name = StringField('名称', validators=[DataRequired()])
        url_name = StringField('短縮名', validators=[
            DataRequired(),
            unique_attr(model=Technology, attr='url_name', session=sa_session)
        ])
        icon = FileField('アイコン画像', validators=[
            FileAllowed(['jpg', 'jpeg', 'png'], '拡張子 jpg,jpeg,png のみ使用可能です')
        ])

    @bp.get('/')
    def index():
        technologies = sa_session.query(Technology).all()
        return render_template('technologies/index.html.jinja', technologies=technologies)

    @bp.get('/new')
    def new():
        form = NewTechnologyForm()
        return render_template('technologies/new.html.jinja', form=form)

    @bp.get('/<url_name>')
    def show(url_name):
        technology = sa_session.query(Technology).filter_by(url_name=url_name).first()
        return render_template('technologies/show.html.jinja', technology=technology)

    @bp.post('/')
    def create():
        form = NewTechnologyForm()
        if not form.validate_on_submit():
            return render_template('technologies/new.html.jinja', form=form)
        url_name = form.url_name.data
        icon_url = None
        uploaded_file = form.icon.data
        if uploaded_file:
            ext = os.path.splitext(uploaded_file.filename)[-1].lower()
            if 'CLOUD_STORAGE_BUCKET_NAME' in config and 'GCS_API_ENDPOINT' in config:
                client_options = { "api_endpoint": config['GCS_API_ENDPOINT'] }
                storage_client = storage.Client(client_options=client_options)
                bucket = storage_client.get_bucket(config['CLOUD_STORAGE_BUCKET_NAME'])
                blob_name = f'technologies/{url_name}{ext}'
                blob = bucket.blob(blob_name)
                blob.upload_from_file(uploaded_file, predefined_acl='publicRead')
                icon_url = blob.public_url
        tech = Technology(name=form.name.data, url_name=url_name, icon_url=icon_url)
        sa_session.add(tech)
        sa_session.commit()
        return redirect(url_for('technologies.show', url_name=tech.url_name))

    return bp
