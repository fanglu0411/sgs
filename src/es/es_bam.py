# from es import es_dao
# from es.es_dao import get_index_name
# import json
#
#
# bam_mapping = {
#     "properties": {
#         "detail": {
#             "type": "text"
#         }
#     }
# }
#
#
#
# def add_block_records(track_id, chr_name, block_index, feature_es_array):
#     index_name = get_index_name(track_id, chr_name, block_index)
#     es_records = []
#     for f in feature_es_array:
#         detail = {"detail": f[1]}
#         detail_str = json.dumps(detail)
#         es_r = {
#             "_index": index_name,
#             "_id": str(f[0]),
#             "detail": detail_str
#         }
#         es_records.append(es_r)
#     es_dao.bulk_add_index_data(index_name, bam_mapping, es_records)
#
#
#
#
# def get_feature_detail(track_id, chr_name, block_index, feature_id):
#     index_name = get_index_name(track_id, chr_name, block_index)
#     data = []
#     if es_dao.is_index_exists(index_name):
#         term = {
#             "_id": feature_id
#         }
#         results = es_dao.equal_search(index_name, term)
#         data = []
#         if len(results) > 0:
#             result= results[0]
#             detail_str = result["_source"]["detail"]
#             detail = json.loads(detail_str)
#             data = [feature_id, detail.get("detail").get("basic_info"), detail.get("detail").get("attribute_info")]
#
#     detail_header = ["feature_id", "basic_info", "attribute_info"]
#     return {"header": detail_header, "data": data}
#
#
#
#
#
#
