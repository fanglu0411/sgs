from db.dao import user_dao
import secrets, os
from util import id_util, file_util
from path_config import sc_folder




# is admin user or current feature_comment owner
def validate_token(token, user_id):
    flag = False
    user_db = user_dao.get_user(user_id)
    admin_user = user_dao.get_user_by_name("admin")
    if admin_user:
        if token == admin_user["token"]:
            flag = True
    if user_db:
        if user_db["token"] == token:
            flag = True
    return flag



def add_admin_token():
    user_id = id_util.generate_uuid()
    token = secrets.token_urlsafe() # todo 去掉 - 和 _
    admin_user = user_dao.get_user_by_name("admin")
    if not admin_user:
        admin_User_folder = os.path.join(sc_folder, user_id)
        if not os.path.exists(admin_User_folder):
            file_util.create_folder(admin_User_folder)
        user_dao.add_user_with_id(user_id, "admin", "123456", token, "admin", "")
    else:
        token = admin_user["token"]
    return token




def get_admin_token():
    admin_user = user_dao.get_user_by_name("admin")
    if admin_user:
        token = admin_user["token"]
    else:
        token = None
    return token



def is_admin_user(user_id):
    user_db = user_dao.get_user(user_id)
    if user_db:
        if user_db["role"] == "admin":
            return True
    return False




def is_admin_user_by_token(token):
    user_db = user_dao.get_user_by_token(token)
    if user_db:
        if user_db["role"] == "admin":
            return True
    return False















