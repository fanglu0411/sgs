# from es import es_dao
# from es.es_dao import get_index_name
# import json
#
#
#
# gff_mapping = {
#     "properties": {
#         "attributes": {
#             "type": "text"
#         },
#         "sub_feature": {
#             "type": "text"
#         },
#         "children": {
#             "type": "text"
#         },
#         "desc": {
#             "type": "text"
#         }
#     }
# }
#
#
# import time
# def add_block_records(track_id, chr_name, feature_es_array):
#     start_time = time.time()
#
#     index_name = get_index_name(track_id, chr_name, "")
#     es_records = []
#     for f in feature_es_array:
#         attributes = {"attributes": f[9]}
#         attributes = json.dumps(attributes)
#         sub_feature = {"sub_feature": f[10]}
#         sub_feature = json.dumps(sub_feature)
#         children = {"children": f[11]}
#         children = json.dumps(children)
#         # feature_name, feature_type, start, end, source score strand phase
#         desc = {"desc": [f[2], f[0], f[4], f[5], f[3], f[6], f[7], f[8]]}
#         desc = json.dumps(desc)
#         es_r = {
#             "_index": index_name,
#             "_id": str(f[1]),
#             "attributes": attributes,
#             "sub_feature": sub_feature,
#             "children": children,
#             "desc": desc
#         }
#         es_records.append(es_r)
#     es_dao.bulk_add_index_data(index_name, gff_mapping, es_records)
#     cost_time = time.time() - start_time
#     print("elastic search add_block_records  %s cost %s second" % ("bed2big", cost_time))
#
#
#
# def get_feature_detail(track_id, chr_name, block_index, feature_id):
#     index_name = es_dao.get_index_name(track_id, chr_name, block_index)
#     term = {
#         "_id": feature_id
#     }
#     results = es_dao.equal_search(index_name, term)
#
#     data = []
#     if len(results) > 0:
#         result= results[0]
#         attributes = result["_source"]["attributes"]
#         attributes = json.loads(attributes)
#         attributes = attributes["attributes"]
#         sub_feature = result["_source"]["sub_feature"]
#         sub_feature = json.loads(sub_feature)
#         sub_feature = sub_feature["sub_feature"]
#         children = result["_source"]["children"]
#         children = json.loads(children)
#         children = children["children"]
#         desc = result["_source"]["desc"]
#         desc = json.loads(desc)
#         desc = desc["desc"]
#         # feature_name, feature_type, start, end, source, score, strand, phase
#         feature_name = desc[0]
#         feature_type = desc[1]
#         start = desc[2]
#         end = desc[3]
#         source = desc[4]
#         score = desc[5]
#         strand = desc[6]
#         phase = desc[7]
#         data = [feature_id, feature_name, feature_type, source, start, end, score, strand, phase, attributes, sub_feature, children]
#
#     detail_header = ["feature_id", "feature_name", "feature_type", "source", "start", "end", "score", "strand", "phase", "attributes", "sub_feature", "children"]
#     return {"feature_id": feature_id, "header": detail_header, "data": data}
#
#
#
#
#
# from es import es_dao
# from es.es_dao import get_index_name
# import json
#
#
#
# gff_mapping = {
#     "properties": {
#         "attributes": {
#             "type": "text"
#         },
#         "sub_feature": {
#             "type": "text"
#         },
#         "children": {
#             "type": "text"
#         },
#         "desc": {
#             "type": "text"
#         }
#     }
# }
#
#
# import time
# def add_block_records(track_id, chr_name, feature_es_array):
#     start_time = time.time()
#
#     index_name = get_index_name(track_id, chr_name, "")
#     es_records = []
#     for f in feature_es_array:
#         attributes = {"attributes": f[9]}
#         attributes = json.dumps(attributes)
#         sub_feature = {"sub_feature": f[10]}
#         sub_feature = json.dumps(sub_feature)
#         children = {"children": f[11]}
#         children = json.dumps(children)
#         # feature_name, feature_type, start, end, source score strand phase
#         desc = {"desc": [f[2], f[0], f[4], f[5], f[3], f[6], f[7], f[8]]}
#         desc = json.dumps(desc)
#         es_r = {
#             "_index": index_name,
#             "_id": str(f[1]),
#             "attributes": attributes,
#             "sub_feature": sub_feature,
#             "children": children,
#             "desc": desc
#         }
#         es_records.append(es_r)
#     es_dao.bulk_add_index_data(index_name, gff_mapping, es_records)
#     cost_time = time.time() - start_time
#     print("elastic search add_block_records  %s cost %s second" % ("bed2big", cost_time))
#
#
#
# def get_feature_detail(track_id, chr_name, block_index, feature_id):
#     index_name = es_dao.get_index_name(track_id, chr_name, block_index)
#     term = {
#         "_id": feature_id
#     }
#     results = es_dao.equal_search(index_name, term)
#
#     data = []
#     if len(results) > 0:
#         result= results[0]
#         attributes = result["_source"]["attributes"]
#         attributes = json.loads(attributes)
#         attributes = attributes["attributes"]
#         sub_feature = result["_source"]["sub_feature"]
#         sub_feature = json.loads(sub_feature)
#         sub_feature = sub_feature["sub_feature"]
#         children = result["_source"]["children"]
#         children = json.loads(children)
#         children = children["children"]
#         desc = result["_source"]["desc"]
#         desc = json.loads(desc)
#         desc = desc["desc"]
#         # feature_name, feature_type, start, end, source, score, strand, phase
#         feature_name = desc[0]
#         feature_type = desc[1]
#         start = desc[2]
#         end = desc[3]
#         source = desc[4]
#         score = desc[5]
#         strand = desc[6]
#         phase = desc[7]
#         data = [feature_id, feature_name, feature_type, source, start, end, score, strand, phase, attributes, sub_feature, children]
#
#     detail_header = ["feature_id", "feature_name", "feature_type", "source", "start", "end", "score", "strand", "phase", "attributes", "sub_feature", "children"]
#     return {"feature_id": feature_id, "header": detail_header, "data": data}
#
#
#
#
#
