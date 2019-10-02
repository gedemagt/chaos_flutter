



from flaskapp import init_flask_app


if __name__ == "__main__":

    import os
    import argparse

    parser = argparse.ArgumentParser()

    parser.add_argument("--static", help="Path to static directory. Defaults to $(pwd)/static", default="static")
    parser.add_argument("--db", help="Path to database", default="chaos_db.db")
    parser.add_argument("--recreate-db", help="Path to database", action="store_true")
    parser.add_argument("--secret", help="Flask secret", default="ReallySecret2")
    parser.add_argument("--port", help="Port to run on", default=5000)

    args = parser.parse_args()


    db_path = args.db

    if not os.path.exists(args.static):
        os.mkdir(args.static)

    print(args.static)
    print(args.db)

    app =  init_flask_app(args.static, db_path, args.secret)

    app.run(debug=True, host="0.0.0.0", port=args.port)
