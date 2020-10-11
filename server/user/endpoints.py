import os
import uuid
from datetime import datetime

from flask import jsonify, request, Flask, abort
from flask_login import current_user, login_user
from flask_user import login_required, UserManager, EmailManager
from sqlalchemy.exc import IntegrityError

from db import db
from user.models import User, Role


def init_user_endpoints(app: Flask):

    app.config['MAIL_SERVER'] = 'smtp-relay.sendinblue.com'
    app.config['MAIL_PORT'] = 587
    app.config['MAIL_USE_SSL'] = False
    app.config['MAIL_USE_TLS'] = False
    app.config['MAIL_USERNAME'] = 'gedemagt@gmail.com'
    app.config['MAIL_PASSWORD'] = os.getenv("SMTP_PASS")
    app.config['MAIL_DEFAULT_SENDER'] = '"ChaosCompanion" <noreply@chaos.com>'

    app.config['USER_APP_NAME'] = 'Chaos Companion'
    app.config['USER_ENABLE_EMAIL'] = True
    app.config['USER_ENABLE_USERNAME'] = True
    app.config['USER_EMAIL_SENDER_NAME'] = 'Chaos Companion'
    app.config['USER_EMAIL_SENDER_EMAIL'] = 'noreply@chaos.com'

    user_manager = UserManager(app, db, User)
    email_manager = EmailManager(app)

    @app.route('/user/current_info', methods=['GET'])
    @login_required
    def user_info():
        return jsonify(current_user.to_json())

    @app.route('/add_user', methods=['POST'])
    def add_user():
        username = request.json['username'].strip()
        password = request.json['password'].strip()
        email = request.json['email'].strip()
        try:
            u = User(
                username=username,
                password=user_manager.hash_password(password),
                email=email,
                email_confirmed_at=datetime.utcnow(),
                uuid=str(uuid.uuid4())
            )
            u.roles.append(db.session.query(Role).filter_by(name='USER').first())
            db.session.add(u)
            db.session.commit()
            return "OK"
        except IntegrityError:
            abort(400)

    @app.route('/login', methods=['POST'])
    def login():
        username = request.json['username'].strip()
        password = request.json['password'].strip()

        u = db.session.query(User).filter_by(username=username).first()

        if u is None:
            u = db.session.query(User).filter_by(email=username).first()

        if u is None:
            abort(400)

        if not user_manager.password_manager.verify_password(password, u.password):
            abort(400)

        login_user(u)

        return "Success"

    @app.route('/reset_password', methods=['POST'])
    def reset_password():
        email = request.json["email"]
        u = db.session.query(User).filter_by(email=email).first()
        if u:
            email_manager.send_reset_password_email(u, None)
            return "OK"
        return "No user with that email", 400

    @app.route('/get_user/<string:uuid>', methods=['GET'])
    @login_required
    def get_user(uuid):

        u = db.session.query(User).filter_by(uuid=uuid).first()

        r = {u.id: u.to_json()}

        return jsonify(r), 200

    @app.route('/get_users', methods=['GET'])
    @login_required
    def get_users():
        r = {u.id: u.to_json() for u in db.session.query(User)}

        return jsonify(r), 200

    @app.route('/delete_user/<string:username>', methods=['POST'])
    @login_required
    def delete_user(username):
        user = db.session.query(User).filter_by(username=username).first()
        if user is not None:
            user.status = 1
            user.edit = datetime.utcnow()
        db.session.commit()

        return "OK", 200

    @app.route('/check_username/<string:name>', methods=['POST'])
    def check_name(name):

        user = db.session.query(User).filter_by(name=name).first()
        if user is None:
            return "OK"
        else:
            abort(400)

    return user_manager, email_manager
