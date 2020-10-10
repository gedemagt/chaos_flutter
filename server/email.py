from datetime import timedelta
from threading import Thread

from flask import request, abort, render_template
from flask_mail import Message
from flask_jwt_extended import JWTManager, create_access_token, decode_token
from flask_mail import Mail


def send_async_email(app, msg, mail):
    with app.app_context():
        mail.send(msg)


def send_email(app, subject, sender, recipients, text_body, html_body):
    msg = Message(subject, sender=sender, recipients=recipients)
    msg.body = text_body
    msg.html = html_body
    Thread(target=send_async_email, args=(app, msg)).start()


def init_email(app, db, user_class, bcrypt):

    app.config["MAIL_SERVER"] = "smtp-relay.sendinblue.com"
    app.config["MAIL_PORT"] = 587
    app.config["MAIL_USERNAME"] = "gedemagt@gmail.com"
    app.config["MAIL_PASSWORD"] = "p1IqPNLDdH6rJBSQ"

    mail = Mail(app)
    jwt = JWTManager(app)

    @app.route('/forgot', methods=['GET'])
    def forgot():
        url = request.host_url + 'reset/'
        user = None
        if "email" in request.json:
            user = db.session.query(user_class).filter_by(email=request.json["email"]).first()
        elif "username" in request.json:
            user = db.session.query(user_class).filter_by(name=request.json["name"]).first()

        if user is None:
            abort(400, "No such user")

        expires = timedelta(hours=24)
        reset_token = create_access_token(str(user.id), expires_delta=expires)
        return send_email(app, '[Chaos Companion] Reset Your Password',
                          sender='support@cc.com',
                          recipients=[user.email],
                          text_body=render_template('email/reset_password.txt',
                                                    url=url + reset_token),
                          html_body=render_template('email/reset_password.html',
                                                    url=url + reset_token))

    @app.route('/reset', methods=['POST'])
    def reset():

        reset_token = request.json.get('reset_token')
        password = request.json.get('password')

        user_id = decode_token(reset_token)['identity']

        user = db.session.query(user_class).filter_by(id=user_id).first()
        if user is None:
            abort(400, "No such user")

        password = bcrypt.generate_password_hash(password).decode('utf-8')
        user.password = password
        db.session.commit()

        return send_email(app, '[Chaos Companion] Password reset successful',
                          sender='support@cc.com',
                          recipients=[user.email],
                          text_body='Password reset was successful',
                          html_body='<p>Password reset was successful</p>')


