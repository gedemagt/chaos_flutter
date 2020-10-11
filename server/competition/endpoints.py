from random import randint

from flask import Flask, abort, jsonify, request

from api.models import Rute
from competition.models import *


def init_competition_endpoints(app: Flask):
    @app.route('/get_comp/<int:pin>', methods=['GET'])
    def get_comp(pin):
        comp = db.session.query(Competition).filter_by(pin=pin).first()
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
             "rutes": [rute.uuid for rute, _ in db.session.query(Rute, CompetitionRutes).filter(
                 CompetitionRutes.comp == comp.uuid).filter(
                 CompetitionRutes.rute == Rute.uuid).filter(Rute.status != 1)]
             }

        return jsonify(r), 200

    @app.route('/get_participated_comps/<string:user>', methods=['GET'])
    def get_participated_comps(user):
        comp = db.session.query(CompetitionParticipation).filter_by(user=user)

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
              "rutes": [rute.uuid for rute, _ in db.session.query(Rute, CompetitionRutes).filter(
                  CompetitionRutes.comp == comp.uuid).filter(
                  CompetitionRutes.rute == Rute.uuid).filter(Rute.status != 1)]
              } for comp in db.session.query(Competition)]

        return jsonify(r), 200

    @app.route('/get_part', methods=['POST'])
    def get_participation():
        comp = request.json['comp']
        user = request.json['user']
        rute = request.json['rute']

        p = db.session.query(CompetitionParticipation).filter_by(comp=comp, user=user, rute=rute).first()
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
            return datetime.strptime(container[key], '%Y-%m-%d %H:%M:%S')
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

        part = db.session.query(CompetitionParticipation).filter_by(comp=comp, user=user, rute=rute).first()
        if part is None:
            db.session.add(
                CompetitionParticipation(comp=comp, user=user, rute=rute, tries=tries, completed=completed,
                                                     date=date, edit=edit))
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

        db.session.add(CompetitionRutes(comp=comp, rute=rute, date=date))
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

        comp = db.session.query(Competition).filter_by(uuid=uuid).first()
        if comp is None:
            pin = randint(1000, 9999)
            while db.session.query(Competition).filter_by(pin=pin).first():
                pin = randint(1000, 9999)
            db.session.add(Competition(uuid=uuid, name=name, edit=edit, start=start, stop=stop, type=type,
                                                   admins=admins, date=date, pin=pin))
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
        comp = db.session.query(Competition).filter_by(pin=pin).first()
        if comp is None:
            abort(400)

        r = [{"user": p.user,
              "rute": p.rute,
              "tries": p.tries,
              "date": str(p.date),
              "completed": p.completed} for p in db.session.query(CompetitionParticipation).filter(
            CompetitionParticipation.comp == comp.uuid)]

        return jsonify(r), 200