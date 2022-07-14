from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.sql import func

Base = declarative_base()

class Project(Base):
    __tablename__ = 'projects'
    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False)
    url_name = Column(String(255), nullable=False, unique=True, index=True)
    choices = relationship('Choice', back_populates='project')
    technologies = association_proxy('choices', 'technology', creator=lambda tech: Choice(technology=tech))

    def __repr__(self):
        return "<Project(id='%s', name='%s', url_name='%s')>" % (self.id, self.name, self.url_name)

class Technology(Base):
    __tablename__ = 'technologies'
    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False)
    url_name = Column(String(255), nullable=False, unique=True, index=True)
    icon_url = Column(Text(), nullable=True)
    choices = relationship('Choice', back_populates='technology')
    projects = association_proxy('choices', 'project', creator=lambda pj: Choice(project=pj))

    def __repr__(self):
        return "<Technology(id='%s', name='%s', url_name='%s')>" % (self.id, self.name, self.url_name)

class Choice(Base):
    __tablename__ = 'choices'
    id = Column(Integer, primary_key=True)
    project_id = Column(Integer, ForeignKey('projects.id'), nullable=False)
    technology_id = Column(Integer, ForeignKey('technologies.id'), nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    project = relationship('Project', back_populates='choices')
    technology = relationship('Technology', back_populates='choices')

    def __repr__(self):
        return "<Choice(id='%s', project_id='%d', technology_id='%d')>" % (self.id, self.project_id, self.technology_id)
