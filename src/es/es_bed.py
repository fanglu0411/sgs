# from es import es_dao
# from es.es_dao import get_index_name
# import json
#
#
#
# #定义bed mapping字段
# #["name", "chr", "start", "end" , "score", "strand"]
# bed_mapping = {
#     "properties":{
#         "feature_name":{
#             "type":"keyword"
#         },
#         "chr":{
#             "type":"keyword"
#         },
#         "start":{
#             "type":"long"
#         },
#         "end":{
#             "type":"long"
#         },
#         "score":{
#             "type":"long"
#         },
#         "strand":{
#             "type":"text"
#         }
#     }
# }
#
#
#
# #定义block添加函数
# #["feature_name", "chr", "start", "end" , "score", "strand"]
# def add_block_records(track_id, chr_name, block_index, feature_es_array):
#     index_name = get_index_name(track_id, chr_name, block_index)
#     es_records = []
#     for f in feature_es_array:
#         es_r = {
#             "_index": index_name,
#             "_id":str(f[0]),
#             "feature_name":str(f[0]),
#             "chr":str(f[1]),
#             "start":str(f[2]),
#             "end":str(f[3]),
#             "score":str(f[4]),
#             "strand":str(f[5])
#         }
#         es_records.append(es_r)
#     #将数据添加到es中
#     es_dao.bulk_add_index_data(index_name, bed_mapping, es_records)
#
#
#
# #["feature_name", "chr", "start", "end" , "score", "strand"]
# def get_feature_detail(track_id, chr_name, block_index, feature_id):
#     #获得es index的名称
#     index_name = es_dao.get_index_name(track_id, chr_name, block_index)
#     term = {
#         "_id":feature_id
#     }
#     results = es_dao.equal_search(index_name, term)
#     data = []
#     if len(results) > 0:
#         result = results[0]
#         feature_name = result["_source"]["feature_name"]
#         chr = result["_source"]["chr"]
#         start = result["_source"]["start"]
#         end = result["_source"]["end"]
#         score = result["_source"]["score"]
#         strand = result["_source"]["strand"]
#         data = [feature_name, chr, start, end, score, strand]
#     detail_header = ["feature_name", "chr", "start", "end", "score", "strand"]
#     return {"feature_id":feature_id, "header":detail_header, "data":data}
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
