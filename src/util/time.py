import time


def fuc_timer(function):
    def wrapper(*args, **kwargs):
        fuc_start = time.time()
        res = function(*args, **kwargs)
        cost_time = time.time() - fuc_start
        print("%s cost %s second" % (function.__name__, cost_time))
        return res
    return wrapper



# @fuc_timer
# def test():
#     time.sleep(3)






