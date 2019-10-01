import os
from flask import Flask, request, jsonify, send_from_directory, abort
from db import db
from flask_login import LoginManager
from flask_migrate import Migrate
from flask_bcrypt import Bcrypt


def get_sql_position():
    path = os.path.join(os.path.dirname(__file__), 'sql_path.txt')
    if not os.path.exists(path):
        raise ValueError("No 'sql_path.txt' found! Please place a sql_path.txt in the same directory as main.py"
                         "with one line: The path to the database!")
    with open(path) as f:
        return f.readline().strip()


app = Flask(__name__, static_folder="static")
app.config['SQLALCHEMY_DATABASE_URI'] = "sqlite:///" + get_sql_position()
app.secret_key = "ReallySecret2"
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

db.init_app(app)
db.app = app
login_manager = LoginManager()
login_manager.init_app(app)

migrate = Migrate(app, db)

bcrypt = Bcrypt(app)
