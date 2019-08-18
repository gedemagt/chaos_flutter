import sqlite3

conn = sqlite3.connect("john.db")

c = conn.cursor()


def delete_gym(uuid):
    # Delete rutes and gyms
    c.execute("DELETE from rute WHERE gym='{}'".format(uuid))
    c.execute("DELETE from gym WHERE uuid='{}'".format(uuid))
    c.commit()
    
def delete_user(uuid):
    # Delete rutes, gyms and user - there MUST be an admin!
    c.execute("DELETE from rute WHERE author='{}'".format(uuid))
    c.execute("DELETE from gym WHERE admin='{}'".format(uuid))
    c.execute("DELETE from user WHERE admin='{}'".format(uuid))
    c.commit()

def delete_rute(uuid):
    c.execute("SELECT image from rute WHERE uuid='{}'".format(uuid))
    c.execute("DELETE from rute WHERE uuid='{}'".format(uuid))
    c.commit()


# Gyms
for gym_uuid,name in c.execute("select uuid,name from gym").fetchall():
    nr = c.execute("select count(*) from rute where gym='{}' group by gym".format(gym_uuid)).fetchone()
    
    print("{}: {}".format(name, nr[0] if nr else 0))


# Users
for uuid,name in c.execute("select uuid,name from user").fetchall():
    nr_rutes = c.execute("select count(*) from rute where author='{}' group by author".format(uuid)).fetchone()
    nr_gyms = c.execute("select count(*) from gym where admin='{}' group by admin".format(uuid)).fetchone()

    
    print("{}: {}   -   {}".format(name, nr_rutes[0] if nr_rutes else 0, nr_gyms[0] if nr_gyms else 0))


from PIL import Image
import os
import json

    
def should_delete(uuid, imageuuid, nr, name):
    with Image.open("static/{}.jpg".format(imageuuid)) as image:
        image.show()
        r = input("{}: {} [yN]".format(name, nr))
        if r.lower() == "y":
            print("Deleting...")
# Wierd rutes
for uuid,name,points,imageuuid in c.execute("select uuid,name,coordinates,image from rute").fetchall():

    points = points.replace("f", "").replace("}{", "},{")
    if points != "[]" and not points.endswith("}]"):
        points = points.replace("]","}]")

    nr_points = len(json.loads(points))

    if any([
            nr_points < 3,
            not name,
            name == "Mysterious Problem",
            not os.path.exists("static/{}.jpg".format(imageuuid))
           ]):
        should_delete(uuid, imageuuid, nr_points, name)
