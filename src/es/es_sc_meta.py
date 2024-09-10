# from es import es_dao
# import json
#
#
#
#
# # meta_data [[cell, cluster, tag1, tag2...]]
# def add_cluster_meta_data(track_id, meta_data, tag_names):
#     index_name = str(track_id)
#     track_mapping = {
#         "properties": {
#         }
#     }
#
#     for tag_name in tag_names:
#         track_mapping.get("properties")[tag_name] = {"type": "text"}
#
#     print(track_mapping)
#
#     es_records = []
#     tag_size = len(tag_names)
#     for f in meta_data:
#
#         cell_name = {tag_names[0]: str(f[0])}
#         cluster_name = {tag_names[1]: f[1]}
#         es_r = {
#             "_index": index_name,
#             "_id": str(f[0]),
#             "cell_name": cell_name,
#             "cluster_name": cluster_name
#         }
#         index = 2
#         for tag_name in tag_names:
#             if index < tag_size:
#                 es_r[tag_name] = str(f[index])
#                 index = index + 1
#         es_records.append(es_r)
#     es_dao.bulk_add_index_data(index_name, track_mapping, es_records)
#
#
#
#
#
#
#
#
