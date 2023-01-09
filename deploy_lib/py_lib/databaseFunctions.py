import json

def load_database():
    db_file = open("./db/db.json")
    return json.load(db_file)

def get_ip_by_name(name):
    data = load_database()
    for record in data:
        if record['label'] == name:
            print(record['ipv4'][0])
            return record['ipv4'][0]

def get_name_by_ip(ip):
    data = load_database()
    for record in data:
        if record['ipv4'][0] == ip:
            print(record['label'])
            return record['label']