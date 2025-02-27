import uuid


def generate_uuid():
    uid = str(uuid.uuid4().hex)
    suid = ''.join(uid.split('-'))
    return suid

