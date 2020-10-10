from datetime import datetime

from flask_login import login_user

from competition import competition
from random import randint
from flask import Flask, request, jsonify, send_from_directory, abort
from db import db
from flask_user import current_user, login_required, roles_required, UserManager, UserMixin, EmailManager
from flask_migrate import Migrate
import os


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


class User(db.Model, UserMixin):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
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


# Define the Role data-model
class Role(db.Model):
    __tablename__ = 'roles'
    id = db.Column(db.Integer(), primary_key=True)
    name = db.Column(db.String(50), unique=True)


# Define the UserRoles association table
class UserRoles(db.Model):
    __tablename__ = 'user_roles'
    id = db.Column(db.Integer(), primary_key=True)
    user_id = db.Column(db.Integer(), db.ForeignKey('users.id', ondelete='CASCADE'))
    role_id = db.Column(db.Integer(), db.ForeignKey('roles.id', ondelete='CASCADE'))


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


def init_flask_app(static_folder, db_path, secret):
    app = Flask(__name__, static_folder=static_folder)

    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + db_path
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.secret_key = secret
    app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024

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
    migrate = Migrate(app, db)
    db.init_app(app)
    db.app = app

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

        # The Home page is accessible to anyone

    @app.route('/user/current_info', methods=['GET'])
    @login_required
    def user_info():
        return jsonify({"gym": current_user.gym,
                       "date": str(current_user.date),
                       "edit": str(current_user.edit),
                       "status": current_user.status,
                       "name": current_user.username,
                       "role": next(x.name for x in current_user.roles),
                       "email": current_user.email})

    @app.route('/', methods=['GET'])
    def index():
        with open("privacy.html") as f:
            return f.read()

    @app.route('/privacy', methods=['GET', 'POST'])
    def privacy():
        return app.send_static_file("privacy.html")

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

    @app.route('/reset_passsword', methods=['POST'])
    def reset_password():
        email = request.values["email"]
        u = db.session.query(User).filter_by(email=email).first()
        if u:
            email_manager.send_reset_password_email(u, None)
            return "Success"
        return "No user wit email", 400

    @app.route('/add_rute', methods=['POST'])
    @login_required
    def upload():
        uuid = request.json['uuid']
        if db.session.query(Rute).filter_by(uuid=uuid).first() is not None:
            abort(400)

        name = request.json['name']
        image = request.json['image']
        author = request.json['author']
        sector = request.json['sector']
        gym = request.json['gym']
        date = request.json['date']
        edit = request.json['edit']
        date = datetime.strptime(date, '%Y-%m-%d %H:%M:%S')
        edit = datetime.strptime(edit, '%Y-%m-%d %H:%M:%S')
        grade = request.json.get('grade', 0)
        tag = request.json.get('tag', "[]")
        coordinates = request.json.get("coordinates", "[]")

        db.session.add(Rute(uuid=uuid, name=name, coordinates=coordinates, author=author, sector=sector, date=date, edit=edit, image=image, grade=grade, gym=gym, tag=tag))
        db.session.commit()

        return str(db.session.query(Rute).order_by(Rute.id.desc()).first().id)

    @app.route('/add_image/<string:uuid>', methods=['POST'])
    @login_required
    def upload_image(uuid):
        f = request.files['data']
        filename = os.path.join(app.static_folder, "{}.jpg".format(uuid))
        if os.path.exists(filename):
            abort(400)
        f.save(filename)
        db.session.add(Image(uuid=uuid, url=filename))
        db.session.commit()
        return "Succes"

    @app.route("/complete", methods=['POST'])
    @login_required
    def complete():
        try:
            rute = request.json["rute"]
            user = request.json["user"]
            tries = request.json["tries"]

            u = db.session.query(User).filter_by(uuid=user).first().id
            r = db.session.query(Rute).filter_by(uuid=rute).first().id
            complete = db.session.query(Complete).filter_by(user=u, rute=r).first()

            if complete is None:
                db.session.add(Complete(tries=tries,
                                        user=db.session.query(User).filter_by(uuid=user).first().id,
                                        rute=db.session.query(Rute).filter_by(uuid=rute).first().id
                                        ))
            else:
                complete.tries = tries

            db.session.commit()
            return "Succes"

        except KeyError:
            abort(400)

    @app.route('/save_rute', methods=['POST'])
    @login_required
    def save_rute():

        uuid = request.json['uuid']

        coordinates = request.json['coordinates']
        edit = request.json['edit']
        edit = datetime.strptime(edit, '%Y-%m-%d %H:%M:%S')
        rute = db.session.query(Rute).filter_by(uuid=uuid).first()
        if rute is None:
            abort(400)
        rute.coordinates = coordinates
        if "name" in request.json:
            rute.name = request.json["name"]
        if "gym" in request.json:
            rute.gym = request.json["gym"]
        if 'grade' in request.json:
            rute.grade = request.json['grade']
        if 'sector' in request.json:
            rute.sector = request.json['sector']
        if 'tag' in request.json:
            rute.tag = request.json['tag']
        rute.edit = edit
        db.session.commit()
        return "Succes"

    @app.route('/add_gym', methods=['POST'])
    @login_required
    def add_gym():
        name = request.json['name']
        uuid = request.json['uuid']
        sectors = request.json['sectors']
        tags = request.json['tags']
        admin = request.json['admin']

        if db.session.query(Gym).filter_by(name=name).first() is not None:
            abort(400)

        db.session.add(Gym(uuid=uuid, name=name, admin=admin, sectors=sectors, tags=tags))
        db.session.commit()
        return "Succes"

    @app.route('/save_gym', methods=['POST'])
    @login_required
    def save_gym():
        name = request.json['name']
        uuid = request.json['uuid']
        sectors = request.json['sectors']
        tags = request.json['tags']
        edit = request.json['edit']
        edit = datetime.strptime(edit, '%Y-%m-%d %H:%M:%S')

        gym = db.session.query(Gym).filter_by(uuid=uuid).first()
        if gym is None:
            abort(400)

        gym.name = name
        gym.sectors = sectors
        gym.tags = tags
        gym.edit = edit

        db.session.commit()
        return "Succes"

    @app.route('/check_username/<string:name>', methods=['POST'])
    def check_name(name):

        user = db.session.query(User).filter_by(name=name).first()
        if user is None:
            return "Success"
        else:
            abort(400)

    @app.route('/get_rutes', methods=['GET', 'POST'])
    @login_required
    def get_rutes():

        query = db.session.query(Rute)

        last_sync = '1900-02-13 22:25:33'
        if request.json and 'last_sync' in request.json:
            last_sync = request.json.get('last_sync')
            query = query.filter(Rute.edit > last_sync)

        if "gym" in request.headers:
            query = query.filter(Rute.gym == request.headers["gym"])

        r = {str(rute.id): {"author": rute.author,
                            "grade": rute.grade,
                            "date": str(rute.date),
                            "edit": str(rute.edit),
                            "coordinates": rute.coordinates,
                            "gym": rute.gym,
                            "sector": rute.sector,
                            "name": rute.name,
                            "image": rute.image,
                            "uuid": rute.uuid,
                            "tag": rute.tag,
                            "status": rute.status,
                            "completes": [{
                                "user": u.uuid,
                                "tries": c.tries,
                                "date": str(c.date)
                            } for c,u in db.session.query(Complete,User).join(Complete, User.id == Complete.user).filter(Complete.rute == rute.id)]}
             for rute in query}

        r.update({"last_sync": str(datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'))})
        return jsonify(r), 200

    @app.route('/download/<string:uuid>', methods=['GET', 'POST'])
    @login_required
    def download_image(uuid):

        img = db.session.query(Image).filter_by(uuid=uuid).first()
        if img is None:
            abort(400)
        expected_path = os.path.join(app.static_folder, os.path.basename(img.url))
        if not os.path.exists(expected_path):
            abort(400)
        return send_from_directory(app.static_folder, os.path.relpath(expected_path, app.static_folder))

    @app.route('/delete/<string:uuid>', methods=['GET', 'POST'])
    @login_required
    def delete_image(uuid):
        rute = db.session.query(Rute).filter_by(uuid=uuid).first()
        if rute is not None:
            rute.status = 1
            rute.edit = datetime.utcnow()
        db.session.commit()
        return "Succes", 200

    @app.route('/delete_gym/<string:uuid>', methods=['POST'])
    @login_required
    def delete_gym(uuid):
        gym = db.session.query(Gym).filter_by(uuid=uuid).first()
        if gym is not None:
            gym.status = 1
            gym.edit = datetime.utcnow()
        db.session.commit()
        return "Succes", 200

    @app.route('/delete_user/<string:username>', methods=['POST'])
    @login_required
    def delete_user(username):
        user = db.session.query(User).filter_by(username=username).first()
        if user is not None:
            user.status = 1
            user.edit = datetime.utcnow()
        db.session.commit()

        return "Succes", 200


    @app.route('/check_gymname/<string:name>', methods=['POST'])
    def check_gymname(name):

        gym = db.session.query(Gym).filter_by(name=name).first()
        if gym is None:
            return "Success"
        else:
            abort(400)

    @app.route('/get_gyms', methods=['GET'])
    @login_required
    def get_gyms():
        r = {gym.id: {"lat": gym.lat,
                      "date": str(gym.date),
                      "edit": str(gym.edit),
                      "status": gym.status,
                      "lon": gym.lon,
                      "name": gym.name,
                      "uuid": gym.uuid,
                      "admin": gym.admin,
                      "n_rutes": db.session.query(Rute).filter_by(gym=gym.uuid, status=0).count(),
                      "tags": gym.tags,
                      "sectors": gym.sectors}
             for gym in db.session.query(Gym)}
        return jsonify(r), 200

    @app.route('/get_gym/<string:uuid>', methods=['GET'])
    @login_required
    def get_gym(uuid):

        gym = db.session.query(Gym).filter_by(uuid=uuid).first()
        r = {uuid: {"lat": gym.lat,
                    "date": str(gym.date),
                    "edit": str(gym.edit),
                    "status": gym.status,
                    "lon": gym.lon,
                    "name": gym.name,
                    "uuid": gym.uuid,
                    "n_rutes": db.session.query(Rute).filter_by(gym=gym.uuid, status=0).count(),
                    "admin": gym.admin,
                    "tags": gym.tags,
                    "sectors": gym.sectors}}
        return jsonify(r), 200

    @app.route('/get_users', methods=['GET'])
    @login_required
    def get_users():
        r = {user.id: {"gym": user.gym,
                       "date": str(user.date),
                       "name": user.username,
                       "email": user.email,
                       "role": user.role}
             for user in db.session.query(User)}

        return jsonify(r), 200

    @app.route('/get_user/<string:username>', methods=['GET'])
    @login_required
    def get_user(username):

        user = db.session.query(User).filter_by(username=username).first()

        r = {user.id: {"gym": user.gym,
                       "date": str(user.date),
                       "name": user.username,
                       "role": user.role,
                       "email": user.email}}

        return jsonify(r), 200

    @app.route('/get_comp/<int:pin>', methods=['GET'])
    def get_comp(pin):
        comp = db.session.query(competition.Competition).filter_by(pin=pin).first()
        if comp is None:
            abort(400)

        r = {"uuid": comp.uuid,
             "name": comp.name,
             "date": str(comp.date),
             "edit": str(comp.edit),
             "start": str(comp.start),
             "stop": str(comp.stop),
             "type": comp.type,
             "admins": comp.admins.split(","),
             "pin": comp.pin,
             "rutes": [rute.uuid for rute, _ in db.session.query(Rute, competition.CompetitionRutes).filter(
                 competition.CompetitionRutes.comp == comp.uuid).filter(competition.CompetitionRutes.rute == Rute.uuid).filter(Rute.status != 1)]
             }

        return jsonify(r), 200

    @app.route('/get_participated_comps/<string:user>', methods=['GET'])
    def get_participated_comps(user):
        comp = db.session.query(competition.CompetitionParticipation).filter_by(user=user)

        comps = list(set([c.comp for c in comp]))

        return jsonify(comps), 200

    @app.route('/get_comps', methods=['GET'])
    def get_comps():
        r = [{"uuid": comp.uuid,
              "name": comp.name,
              "date": str(comp.date),
              "edit": str(comp.edit),
              "start": str(comp.start),
              "stop": str(comp.stop),
              "type": comp.type,
              "admins": comp.admins.split(","),
              "pin": comp.pin,
              "rutes": [rute.uuid for rute, _ in db.session.query(Rute, competition.CompetitionRutes).filter(
                  competition.CompetitionRutes.comp == comp.uuid).filter(competition.CompetitionRutes.rute == Rute.uuid).filter(Rute.status != 1)]
              } for comp in db.session.query(competition.Competition)]
        #print(r)
        return jsonify(r), 200

    @app.route('/get_part', methods=['POST'])
    def get_participation():
        comp = request.json['comp']
        user = request.json['user']
        rute = request.json['rute']

        p = db.session.query(competition.CompetitionParticipation).filter_by(comp=comp, user=user, rute=rute).first()
        if p is None:
            tries = 0
            completed = 0
            date = "1970-01-01 00:00:00"
        else:
            tries = p.tries
            completed = p.completed
            date = str(p.date)

        r = {"user": user,
             "comp": comp,
             "rute": rute,
             "tries": tries,
             "completed": completed,
             "date": date}

        return jsonify(r), 200

    def parse_or_now(key, container):
        if key in container:
            return datetime.strptime(container[key],'%Y-%m-%d %H:%M:%S')
        else:
            return datetime.utcnow()

    @app.route('/update_part', methods=['POST'])
    def update_participation():
        comp = request.json['comp']
        user = request.json['user']
        rute = request.json['rute']
        tries = request.json['tries']
        date = parse_or_now("date", request.json)
        edit = parse_or_now("edit", request.json)
        completed = request.json['completed']

        part = db.session.query(competition.CompetitionParticipation).filter_by(comp=comp, user=user, rute=rute).first()
        if part is None:
            db.session.add(competition.CompetitionParticipation(comp=comp, user=user, rute=rute, tries=tries, completed=completed, date=date, edit=edit))
            db.session.commit()
        else:
            part.tries = tries
            part.completed = completed
            part.edit = edit
            db.session.commit()

        return "Success", 200

    @app.route('/add_rute_comp', methods=['POST'])
    def add_rute():
        comp = request.json['comp']
        rute = request.json['rute']
        date = parse_or_now("date", request.json)

        db.session.add(competition.CompetitionRutes(comp=comp, rute=rute, date=date))
        db.session.commit()

        return "Success", 200

    @app.route('/update_comp', methods=['POST'])
    def update_comp():
        uuid = request.json['uuid']
        name = request.json['name']
        date = parse_or_now("date", request.json)
        edit = parse_or_now("edit", request.json)
        start = parse_or_now("start", request.json)
        stop = parse_or_now("stop", request.json)
        type = request.json['type']
        admins = request.json['admins']

        comp = db.session.query(competition.Competition).filter_by(uuid=uuid).first()
        if comp is None:
            pin = randint(1000, 9999)
            while db.session.query(competition.Competition).filter_by(pin=pin).first():
                pin = randint(1000, 9999)
            db.session.add(competition.Competition(uuid=uuid, name=name, edit=edit, start=start, stop=stop, type=type, admins=admins, date=date, pin=pin))
            db.session.commit()
        else:
            pin = comp.pin
            comp.name = name
            comp.edit = edit
            comp.start = start
            comp.stop = stop
            comp.type = type
            comp.admins = admins
            db.session.commit()

        return "{}".format(pin), 200

    @app.route('/get_stats/<int:pin>', methods=['GET'])
    def get_stats(pin):
        comp = db.session.query(competition.Competition).filter_by(pin=pin).first()
        if comp is None:
            abort(400)

        r = [{"user": p.user,
              "rute": p.rute,
              "tries": p.tries,
              "date": str(p.date),
              "completed": p.completed} for p in db.session.query(competition.CompetitionParticipation).filter(
            competition.CompetitionParticipation.comp == comp.uuid)]

        return jsonify(r), 200

    return app
