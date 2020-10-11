from admin import init_admin_panel
from flask import Flask

from api.endpoints import init_api_endpoints
from api.models import Gym, Rute
from user.endpoints import init_user_endpoints
from user.models import *
from flask_migrate import Migrate
import os


def init_flask_app(static_folder, db_path, secret):
    app = Flask(__name__, static_folder=static_folder)

    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + db_path
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.secret_key = secret
    app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024

    migrate = Migrate(app, db)
    db.init_app(app)
    db.app = app

    init_admin_panel(app, db, [User, Gym, Rute])
    user_manager, email_manager = init_user_endpoints(app)
    init_api_endpoints(app)

    if not os.path.exists(db_path):

        print("Creates database")
        db.create_all()

        db.session.add(Role(name='USER'))

        user = User(
            username="admin",
            password=user_manager.hash_password('changeme'),
            email='gedemagt+chaostest@gmail.com',
            email_confirmed_at=datetime.utcnow(),
            gym="UnknowGym"
        )
        user.roles.append(Role(name='ADMIN'))
        db.session.add(user)
        db.session.commit()

    @app.route('/', methods=['GET'])
    def index():
        with open("privacy.html") as f:
            return f.read()

    @app.route('/privacy', methods=['GET', 'POST'])
    def privacy():
        return app.send_static_file("privacy.html")

    return app
