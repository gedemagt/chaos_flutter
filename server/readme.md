# chaos-server

The server should use python 3

Create a `virtualenv`

 `virtualenv venv -p python3`

Install the requirements

`pip install -r requirements.txt`

If you need to update database schema to newest version, set FLASK_APP and migrate
```
export FLASK_APP=main.py
flask db upgrade
```

If you make changes to the schema, please make a migration (and check the script in migration/versions!)
```
flask db migrate
flask db upgrade
```


Run `python main.py`. If you want to change destination of DB-file, change the path in `sql_path.txt`.

If you need to recreate DB, run `python main.py db`

Notice that old db's and statics will be backed up in `bak`.


