import os
from datetime import datetime

from flask import Flask, request, abort, jsonify, send_from_directory
from flask_user import login_required

from api.models import Rute, Gym, Image, Complete
from db import db
from user.models import User


def init_api_endpoints(app: Flask):

    @app.route('/rute', methods=['POST'])
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

        db.session.add(
            Rute(uuid=uuid, name=name, coordinates=coordinates, author=author, sector=sector, date=date, edit=edit,
                 image=image, grade=grade, gym=gym, tag=tag))
        db.session.commit()

        return str(db.session.query(Rute).order_by(Rute.id.desc()).first().id)

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
        return "OK"

    @app.route('/delete/<string:uuid>', methods=['GET', 'POST'])
    @login_required
    def delete_image(uuid):
        rute = db.session.query(Rute).filter_by(uuid=uuid).first()
        if rute is not None:
            rute.status = 1
            rute.edit = datetime.utcnow()
        db.session.commit()
        return "OK", 200

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
                            } for c, u in
                                db.session.query(Complete, User).join(Complete, User.id == Complete.user).filter(
                                    Complete.rute == rute.id)]}
             for rute in query}

        r.update({"last_sync": str(datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'))})
        return jsonify(r), 200

    @app.route('/get_gym/<string:uuid>', methods=['GET'])
    @login_required
    def get_gym(uuid):

        gym = db.session.query(Gym).filter_by(uuid=uuid).first()
        r = {uuid: gym.to_json()}
        return jsonify(r), 200

    @app.route('/get_gyms', methods=['GET'])
    @login_required
    def get_gyms():
        r = {gym.id: gym.to_json() for gym in db.session.query(Gym)}
        return jsonify(r), 200

    @app.route('/check_gymname/<string:name>', methods=['POST'])
    def check_gymname(name):

        gym = db.session.query(Gym).filter_by(name=name).first()
        if gym is None:
            return "OK"
        else:
            abort(400)

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
        return "OK"

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
        return "OK"

    @app.route('/delete_gym/<string:uuid>', methods=['POST'])
    @login_required
    def delete_gym(uuid):
        gym = db.session.query(Gym).filter_by(uuid=uuid).first()
        if gym is not None:
            gym.status = 1
            gym.edit = datetime.utcnow()
        db.session.commit()
        return "OK", 200

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
        return "OK"

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
            return "OK"

        except KeyError:
            abort(400)


