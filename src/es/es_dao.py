# from es.es_client import ESEngine
# from elasticsearch import helpers
#
#
#
# def drop_create_index(index_name):
#     es = ESEngine()
#     client = es.client
#     is_index_exist = client.indices.exists(index_name)
#     if is_index_exist:
#         client.indices.delete(index=index_name)
#     client.indices.create(index=index_name)
#
#
# def is_index_exists(index_name):
#     es = ESEngine()
#     client = es.client
#     return  client.indices.exists(index_name)
#
#
# def create_index(index_name, mapping):
#     es = ESEngine()
#     client = es.client
#     is_index_exist = client.indices.exists(index_name)
#     if not is_index_exist:
#         client.indices.create(index=index_name)
#         client.indices.put_mapping(index=index_name, body=mapping)
#
#
#
# def list_all_indexes():
#     client = ESEngine().client
#     alias = sorted(client.indices.get_alias().keys())
#     return alias
#
#
# def get_index_mapping(index_name):
#     client = ESEngine().client
#     m = client.indices.get_mapping(index=index_name)
#     return m
#
#
#
# def delete_track_index(track_id, chr_name):
#     es = ESEngine()
#     client = es.client
#     index_name = get_index_name(track_id, chr_name, "")
#     is_index_exist = client.indices.exists(index_name)
#     if is_index_exist:
#         print("delete index: ", index_name)
#         client.indices.delete(index=index_name)
#
#
#
# def clear_all_index():
#     client = ESEngine().client
#     alias = list_all_indexes()
#     for index_name in alias:
#         print("deleted index: ", index_name)
#         client.indices.delete(index=index_name)
#
#
#
# def bulk_add_index_data(index_name, mapping, es_records):
#     create_index(index_name, mapping)
#     client = ESEngine().client
#     helpers.bulk(client, es_records)
#
#
#
# def get_whole_index_data(index_name):
#     client = ESEngine().client
#     query = {
#         "size": 1000,
#         "query": {
#             "match_all": {}
#         }
#     }
#     result = client.search(index=index_name, body=query)
#     count_q = {
#             "query": {
#                 "match_all": {}
#             }
#         }
#     count = client.count(index=index_name, body=count_q)
#     return result['hits']['hits'], count['count']
#
#
#
#
# # term 精确查询 term:{term_key: term_value}
# def equal_search(index_name, term: dict):
#     client = ESEngine().client
#     query = {
#         "query": {
#             "match_phrase": term
#             # "term": term
#         }
#     }
#     result = client.search(index=index_name, body=query)
#     return result['hits']['hits']
#
#
#
# # match 模糊查询
# def like_search(index_name, match: dict):
#     client = ESEngine().client
#     query = {
#         "query": {
#             "match": match
#         }
#     }
#     result = client.search(index=index_name, body=query)
#     return result['hits']['hits']
#
#
# def search_by_multi_match(index_name, matches: dict):
#     client = ESEngine().client
#     query = {
#         "query": {
#             "multi_match": matches
#         }
#     }
#     result = client.search(index=index_name, body=query)
#     return result['hits']['hits']
#
#
#
# def get_index_name(track_id, chr_name, block_index):
#     # return (track_id + "_" + chr_name + "_" + str(block_index)).lower()
#     return (track_id + "_" + chr_name ).lower()
#
#
#
#
