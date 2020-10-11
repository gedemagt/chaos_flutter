from flask import Flask, redirect, url_for, request
from flask_admin import Admin
from flask_admin.contrib import sqla
from flask_login import current_user


class LoggedinModelView(sqla.ModelView):

    def is_accessible(self):
        return current_user.is_authenticated

    def inaccessible_callback(self, name, **kwargs):
        # redirect to login page if user doesn't have access
        return redirect(url_for('login', next=request.url))


def init_admin_panel(app: Flask, db, models):

    admin = Admin(app, name='Chaos Companion', template_mode='bootstrap3')

    for m in models:
        admin.add_view(LoggedinModelView(m, db.session))
