from elasticsearch import Elasticsearch
from util.singleton import singleton



# def singleton(cls):
#     _instance = {}
#
#     def _singleton(*args, **kwargs):
#         if cls not in _instance:
#             _instance[cls] = cls(*args, **kwargs)
#         return _instance[cls]
#
#     return _singleton



# @singleton
# class ESEngine(object):
#     client = None
#
#     def __init__(self):
#         self.client = Elasticsearch("sgs-es:9200", sniff_on_start=True)














