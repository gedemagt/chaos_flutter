from flaskapp import init_flask_app
import os
import meinheld
meinheld.set_max_content_length(2**10 * 2**10 * 2**10 * 1) # 1 GB


static = os.getenv("CHAOS_STATIC", "/res/static")

if not os.path.exists(static):
    os.mkdir(static)


app =  init_flask_app(static, os.getenv("CHAOS_DB_PATH","/res/chaos-db.db"), os.getenv("CHAOS_SECRET","ReallySecret!"))



if __name__ == "__main__":
    app.run()
