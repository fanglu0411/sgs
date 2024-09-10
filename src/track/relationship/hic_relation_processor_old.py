#
# from db.dao import chromosome_dao, track_dao, feature_relationship_dao, chr_group_track_dao, chr_group_track_block_dao
# from track.relationship.hic.interaction import hic_relation_parser_old
# from flask import g
# from util import id_util
# from track.track_type import  hic_interactive_track, compare_track
#
#
#
#
#
# # is longrange or biginteract
# def add_hic_interactive_track(species_id, track_name, track_file):
#     file_type = hic_relation_parser_old.get_file_type(track_file)
#     relations = []
#     chr_id_count_dict = {}
#     chromosomes = chromosome_dao.get_all_chromosome(g.session, species_id)
#     chr_name_id_dict = {}
#     for chromosome in chromosomes:
#         chr_name_id_dict[matrix_chr_name] = chromosome.id
#     track_id = track_dao.add_track(g.session, species_id, track_name, hic_interactive_track, compare_track, track_file, "hic interactive track", "adding", None, "")
#     if file_type == "bed":
#         relations, chr_id_count_dict = hic_relation_parser_old.read_bed_file(track_file, chr_name_id_dict)
#     elif file_type == "big":
#         relations, chr_id_count_dict = hic_relation_parser_old.read_big_file(track_file, chr_name_id_dict)
#     for chr_id, f_count in chr_id_count_dict.items():
#         chr_group_track_dao.add_chr_group(g.session, track_id, chr_id, None, None, None, None)
#         chr_group_track_block_dao.add_statistic(g.session, track_id, chr_id, None, None, None, f_count, 0, None)
#     relations_db = []
#     for relation in relations:
#         relation_id = id_util.generate_uuid()
#         item = {"id": relation_id, "track_id": track_id, "chr1_id": relation[0], "chr2_id": relation[1],
#                 "feature1_start": relation[2], "feature1_end": relation[3],
#                 "feature2_start": relation[4], "feature2_end": relation[5], "relation_score": relation[6],
#                 "relation_name": relation[7]}
#         relations_db.append(item)
#     feature_relationship_dao.bulk_add_relations(g.session, relations_db)
#     track_dao.update_track_status(g.session, track_id, "done")
#
#     return {"track_id": track_id}
#
#
#
#
# def get_hic_interactive_data(request):
#     track_id = request.json["track_id"]
#     chr1_id = request.json["chr1_id"]
#     chr2_id = request.json["chr2_id"]
#     chromosome1 = chromosome_dao.get_chromosome(g.session, chr1_id)
#     chromosome2 = chromosome_dao.get_chromosome(g.session, chr2_id)
#     if not chromosome1 or not chromosome2:
#         return {"error": "no chromosome"}
#     chr1_start = 0
#     chr1_end = chromosome1.seq_length
#     chr2_start = 0
#     chr2_end = chromosome2.seq_length
#     if "chr1_start" in request.json:
#         chr1_start = str(request.json["chr1_start"])
#     if "chr1_end" in request.json:
#         chr1_end = str(request.json["chr1_end"])
#     if "chr2_start" in request.json:
#         chr2_start = str(request.json["chr2_start"])
#     if "chr2_end" in request.json:
#         chr2_end = str(request.json["chr2_end"])
#
#     relations = feature_relationship_dao.get_relations(g.session, track_id, chr1_id, chr2_id, chr1_start, chr1_end, chr2_start, chr2_end)
#     data = []
#     for relation in relations:
#         data.append([relation.feature1_start, relation.feature1_end, relation.feature2_start, relation.feature2_end, relation.relation_score, relation.relation_name])
#     header = ["chr1_start", "chr1_end", "chr2_start", "chr2_end", "interaction_score", "relation_name"]
#     return {"header": header, "data": data}
#
#
#
#
# def get_circle_relationships(request):
#     track_id = request.json["track_id"]
#     chr_id = request.json["chr_id"]
#     relation_dict = feature_relationship_dao.get_chr_relations(g.session, track_id, chr_id)
#     header = {"relation_chr_id": ["chr1_start", "chr1_end", "chr2_start", "chr2_end", "interaction_score"]}
#     result = {"header": header, "data": relation_dict}
#     return result
#
#
#
# def get_track_statistics(track):
#     statistics = []
#     if track.status == "done":
#         chromosomes = chr_group_track_dao.get_track_chromosomes(g.session, track.id)
#         if len(chromosomes) > 0:
#             for chromosome in chromosomes:
#                 statistic = {"chr_id": chromosome.id}
#                 statistics.append(statistic)
#     return statistics
#
#
#
#
#
