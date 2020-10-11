from datetime import datetime

from flask_user import UserMixin

from db import db


class User(db.Model, UserMixin):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)

    uuid = db.Column(db.String, unique=True, nullable=False)

    username = db.Column(db.String, unique=True)
    active = db.Column('is_active', db.Boolean(), nullable=False, server_default='1')

    email = db.Column(db.String(255, collation='NOCASE'), nullable=False, unique=True)
    email_confirmed_at = db.Column(db.DateTime())

    password = db.Column(db.String(255), nullable=False, server_default='')

    roles = db.relationship('Role', secondary='user_roles')

    gym = db.Column(db.Integer, db.ForeignKey('gyms.id'))
    date = db.Column(db.DateTime, default=datetime.utcnow)
    edit = db.Column(db.DateTime, default=datetime.utcnow)
    status = db.Column(db.Integer, default=0)

    def to_json(self):
        return {"gym": self.gym,
                "date": str(self.date),
                "edit": str(self.edit),
                "status": self.status,
                "name": self.username,
                "role": next(x.name for x in self.roles),
                "email": self.email,
                "uuid": self.uuid}


class Role(db.Model):
    __tablename__ = 'roles'
    id = db.Column(db.Integer(), primary_key=True)
    name = db.Column(db.String(50), unique=True)


class UserRoles(db.Model):
    __tablename__ = 'user_roles'
    id = db.Column(db.Integer(), primary_key=True)
    user_id = db.Column(db.Integer(), db.ForeignKey('users.id', ondelete='CASCADE'))
    role_id = db.Column(db.Integer(), db.ForeignKey('roles.id', ondelete='CASCADE'))