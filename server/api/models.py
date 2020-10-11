from datetime import datetime

from db import db


class Gym(db.Model):
    __tablename__ = 'gyms'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String)
    uuid = db.Column(db.String, unique=True)
    lat = db.Column(db.String)
    lon = db.Column(db.String)
    admin = db.Column(db.String)
    sectors = db.Column(db.String)
    tags = db.Column(db.String)
    date = db.Column(db.DateTime, default=datetime.utcnow)
    edit = db.Column(db.DateTime, default=datetime.utcnow)
    status = db.Column(db.Integer, default=0)

    def to_json(self):
        return {"lat": self.lat,
                "date": str(self.date),
                "edit": str(self.edit),
                "status": self.status,
                "lon": self.lon,
                "name": self.name,
                "uuid": self.uuid,
                "n_rutes": db.session.query(Rute).filter_by(gym=self.uuid, status=0).count(),
                "admin": self.admin,
                "tags": self.tags,
                "sectors": self.sectors}


class Rute(db.Model):
    __tablename__ = 'rutes'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String)
    uuid = db.Column(db.String, unique=True)
    image = db.Column(db.String)
    coordinates = db.Column(db.String, default="{}")
    author = db.Column(db.Integer, db.ForeignKey('users.id'))
    gym = db.Column(db.Integer, db.ForeignKey('gyms.id'))
    sector = db.Column(db.String)
    tag = db.Column(db.String)
    date = db.Column(db.DateTime, default=datetime.utcnow)
    edit = db.Column(db.DateTime, default=datetime.utcnow)
    grade = db.Column(db.String, default="NO_GRADE")
    status = db.Column(db.Integer, default=0)


class Image(db.Model):
    __tablename__ = 'images'
    id = db.Column(db.Integer, primary_key=True)
    uuid = db.Column(db.String, unique=True)
    url = db.Column(db.String, unique=True)
    date = db.Column(db.DateTime, default=datetime.utcnow)


class Comment(db.Model):
    __tablename__ = 'comments'
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.String)
    uuid = db.Column(db.String, unique=True)
    author = db.Column(db.Integer, db.ForeignKey('users.id'))
    rute = db.Column(db.Integer, db.ForeignKey('rutes.id'))
    date = db.Column(db.DateTime, default=datetime.utcnow)


class Complete(db.Model):
    __tablename__ = 'completes'
    id = db.Column(db.Integer, primary_key=True)
    tries = db.Column(db.Integer)
    user = db.Column(db.Integer, db.ForeignKey('users.id'))
    rute = db.Column(db.Integer, db.ForeignKey('rutes.id'))
    date = db.Column(db.DateTime, default=datetime.utcnow)


class Rating(db.Model):
    __tablename__ = 'ratings'
    id = db.Column(db.Integer, primary_key=True)
    rating = db.Column(db.String)
    uuid = db.Column(db.String, unique=True)
    author = db.Column(db.Integer, db.ForeignKey('users.id'))
    rute = db.Column(db.Integer, db.ForeignKey('rutes.id'))
    date = db.Column(db.DateTime, default=datetime.utcnow)