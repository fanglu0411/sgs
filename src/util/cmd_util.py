
import sys, os, traceback, uuid
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
from subprocess import check_output



def call_cmd(cmd_str):
    try:
        md5 = str(uuid.uuid3(uuid.NAMESPACE_DNS, cmd_str)).replace("-", "")
        lock_file = os.path.join("/tmp/", md5 + ".lock")
        cmd_str = "touch  " + lock_file + ";" + cmd_str + ";" + "rm -rf " + lock_file
        if not os.path.exists(lock_file):
            check_output(cmd_str, shell=True)
    except Exception as e:
        traceback.print_exc()