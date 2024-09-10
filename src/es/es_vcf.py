# from es import es_dao
# from es.es_dao import get_index_name
# import json
#
#
#
# vcf_mapping = {
#     "properties": {
#         "feature_name": {
#             "type": "keyword"
#         },
#         "alt_type": {
#             "type": "keyword"
#         },
#         "alt_detail": {
#             "type": "text"
#         },
#         "start": {
#             "type": "long"
#         },
#         "end": {
#             "type": "long"
#         },
#         "desc": {
#             "type": "text"
#         }
#     }
# }
#
#
#
# # "feature_id", "feature_name", "alt_type", "alt_detail", "start", "end", "desc"
# def add_block_records(track_id, chr_name, feature_es_array):
#     index_name = get_index_name(track_id, chr_name, "")
#     es_records = []
#     for f in feature_es_array:
#         es_r = {
#             "_index": index_name,
#             "_id": str(f[0]),
#             "feature_name": str(f[1]),
#             "alt_type": str(f[2]),
#             "alt_detail": json.dumps(f[3]),
#             "start": int(f[4]),
#             "end": int(f[5]),
#             "desc": json.dumps(f[6])
#         }
#         es_records.append(es_r)
#     es_dao.bulk_add_index_data(index_name, vcf_mapping, es_records)
#
#
#
#
# def get_feature_detail(track_id, chr_name, block_index, feature_id):
#     index_name = es_dao.get_index_name(track_id, chr_name, block_index)
#     term = {
#         "_id": feature_id
#     }
#     results = es_dao.equal_search(index_name, term)
#     data = []
#     if len(results) > 0:
#         result= results[0]
#         feature_name = result["_source"]["feature_name"]
#         alt_type = result["_source"]["alt_type"]
#         alt_detail = json.loads(result["_source"]["alt_detail"])
#         start = int(result["_source"]["start"])
#         end = int(result["_source"]["end"])
#         desc = json.loads(result["_source"]["desc"])
#         data = [feature_name, alt_type, alt_detail, start, end, desc]
#     detail_header = ["feature_name", "alt_type", "alt_detail", "start", "end", "desc"]
#     return {"feature_id": feature_id, "header": detail_header, "data": data}
#
#
#
# vcf_sample_mapping = {
#     "properties": {
#         "sample_group_name": {
#             "type": "keyword"
#         },
#         "statistic": {
#             "type": "text"
#         },
#         "start": {
#             "type": "long"
#         },
#         "end": {
#             "type": "long"
#         },
#         "samples": {
#             "type": "text"
#         }
#     }
# }
#
#
#
# # sample_es_array is [f_id, feature_name, st, start, end, sample_children]
# def add_block_samples(track_id, chr_name, sample_es_array):
#     index_name = get_index_name(track_id, chr_name, "")
#     es_records = []
#     for s in sample_es_array:
#         es_r = {
#             "_index": index_name,
#             "_id": str(s[0]),
#             "sample_group_name": str(s[1]),
#             "statistic": str(s[2]),
#             "start": int(s[3]),
#             "end": int(s[4]),
#             "samples": json.dumps(s[5])
#         }
#         es_records.append(es_r)
#     es_dao.bulk_add_index_data(index_name, vcf_sample_mapping, es_records)
#
#
#
#
# def get_sample_detail(track_id, chr_name, block_index, feature_id):
#     index_name = es_dao.get_index_name(track_id, chr_name, block_index)
#     term = {
#         "_id": feature_id
#     }
#     results = es_dao.equal_search(index_name, term)
#     data = []
#     if len(results) > 0:
#         result = results[0]
#         sample_group_name = result["_source"]["sample_group_name"]
#         statistic = result["_source"]["statistic"]
#         start = int(result["_source"]["start"])
#         end = int(result["_source"]["end"])
#         samples = json.loads(result["_source"]["samples"])
#         data = [feature_id, sample_group_name, statistic, start, end, samples]
#     detail_header = ["feature_id", "feature_name", "statistic", "start", "end", "sample_children"]
#     return {"header": detail_header, "data": data}
#
#
#
#
#
#
