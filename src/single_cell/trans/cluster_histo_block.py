# from flask import g
# from db.dao import chr_group_track_dao, chr_group_track_block_dao, chromosome_dao
# from old.single_cell_old.trans import trans_track_block
# from util import file_util
# import json
#
#
#
#
#
# def get_block_statistics(track):
#     statistics = []
#     chromosomes = chr_group_track_dao.get_track_chromosomes(g.list_session, track.id)
#     if len(chromosomes) > 0:
#         for chromosome in chromosomes:
#             block_info = chr_group_track_block_dao.get_chr_statistic(track.id, chromosome.id)
#             statistic = {"chr_id": chromosome.id, "feature_count": block_info.feature_count, "average_f_length": block_info.average_feature_length,
#                          "block_count": block_info.block_count, "block_step": block_info.block_step}
#             statistics.append(statistic)
#     return statistics
#
#
#
# def get_block_data(request):
#     sc_id = request.json["sc_id"]
#     block_index = request.json["block_index"]
#     track_id = request.json["track_id"]
#     chr_id = request.json["chr_id"]
#     group_name = None
#     if "group_name" in request.json:
#         group_name = request.json["group_name"]
#     chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
#     if chromosome:
#         block_info = chr_group_track_block_dao.get_chr_statistic(track_id, chr_id)
#         if block_info:
#             block = chr_group_track_block_dao.get_chr_group_block(g.session, track_id, chr_id, block_index, group_name)
#             if block:
#                 block_data_str = file_util.read_file(block.block_file)
#                 block_data = json.loads(block_data_str)
#             else:
#                 block_data = trans_track_block.write_block_data(sc_id, track_id, chr_id, chromosome.search_name,
#                                                                 block_index, block_info.block_step, chromosome.seq_length, group_name)
#             return block_data
#     else:
#         return {"error": "no chromosome"}
#
#
#
#
#
#
