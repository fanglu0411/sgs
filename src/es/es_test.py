# from es import es_dao
#
#
#
#
# gff_mapping = {
#     "properties": {
#         # "feature_id": {
#         #     "type": "keyword",
#         #     "index": True
#         # },
#         "attributes": {
#             "type": "text"
#         },
#         "sub_feature": {
#             "type": "keyword"
#         },
#         "children": {
#             "type": "keyword"
#         },
#         "desc": {
#             "type": "keyword"
#         }
#     }
# }
#
# # es_dao.clear_all_index()
# # es_dao.list_all_indexes()
# from util.id_util import generate_uuid
#
#
# index_name = "test"
# f_id = "heihei"
# def test_add():
#     r1 = {
#         "_index": index_name,
#         "_id": f_id,
#         "attributes": "ID=NC_000913.3:1..4641652;Dbxref=taxon:511145;Is_circular=true;Name=ANONYMOUS;gbkey=Src;genome=chromosome;mol_type=genomic DNA;strain=K-12;substrain=MG1655",
#         "sub_feature": str([{"feature_id": "exon_1"}]),
#         "children": str([{"feature_id": "transcript_1"}]),
#         # feature_name, feature_type, start, end, source score strand phase
#         "desc": str(["gene1", "gene", 1, 100, "source", 77.7, "+", 0])
#     }
#     r2 = {
#         "_index": index_name,
#         "_id": f_id + "_9",
#         "attributes": "ID=NC_000913.3:1..4641652;Dbxref=taxon:511145;Is_circular=true;Name=ANONYMOUS;gbkey=Src;genome=chromosome;mol_type=genomic DNA;strain=K-12;substrain=MG1655",
#         "sub_feature": str([{"feature_id": "exon_1"}]),
#         "children": str([{"feature_id": "transcript_1"}]),
#         # feature_name, feature_type, start, end, source score strand phase
#         "desc": str(["gene1", "gene", 1, 100, "source", 77.7, "+", 0])
#     }
#     rs = [r1, r2]
#     es_dao.bulk_add_index_data(index_name, gff_mapping, rs)
#
#
# # es_dao.clear_all_index()
# # test_add()
#
# # print("all index  ", es_dao.list_all_indexes())
# # print("mapping  ", es_dao.get_index_mapping(index_name))
# # print("whole index data  ", es_dao.get_whole_index_data(index_name))
#
#
# # term = {
# #         "_id": f_id
# #     }
# # print(f_id, "  ", es_dao.equal_search(index_name, term))
#
#
# # query = {
# #     "feature_id": {
# #         "query": f_id
# #         # "slop": 2
# #     }
# # }
# # print(f_id, "  ", es_dao.equal_search(index_name, query))
#
#
#
