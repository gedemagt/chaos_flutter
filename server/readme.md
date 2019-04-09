# chaos-server

The server should use python 3

Create a `virtualenv`

 `virtualenv venv -p python3`

Install the requirements

`pip install -r requirements.txt`

Run `python main.py`. If you want to change destination of DB-file, change the path in `sql_path.txt`.

If you need to recreate DB, run `python main.py db`

Notice that old db's and statics will be backed up in `bak`.
