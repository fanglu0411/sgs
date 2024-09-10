# import json, traceback
# from util import file_util
# from track.single.bed.normal import bed_bigwig, bed_block, bed_index
# from old.track.single.bed import bed_paser_old
# from flask import g
# from db.database_init import get_session
# from db.dao import track_dao, chr_group_track_dao, chr_group_track_block_dao, chromosome_dao
# from track.util import track_util
#
#
#
#
#
# def add_bed_track_task(session, species_id, track_id, bed_file):
#     # chr_name_length = chromosome_dao.get_species_all_chr_name_length(session, species_id)
#     track_dao.update_track_progress(session, track_id, "adding", 20, "conversion")
#     group_dfs, chr_f_count_dict, chr_big_file_dict = bed_paser_old.bed2bigwig(session, track_id, bed_file, species_id)
#
#     track_dao.update_track_progress(session, track_id, "adding", 70, "statistic")
#     for chr_name, chr_f_count in chr_f_count_dict.items():
#         chr_db_search_name = track_util.get_chr_search_name(chr_name)
#         chromosome = chromosome_dao.get_chromosome_by_search_name(species_id, chr_db_search_name)
#         group_big_file = chr_big_file_dict.get(chr_name)
#         chr_group_track_dao.add_chr_group(session, track_id, chromosome.id, None, group_big_file, None, None)
#         bed_block.add_block_statistics(session, track_id, chromosome.id, group_dfs.get(chr_name), chr_f_count, chromosome.seq_length)
#     track_dao.update_track_progress(session, track_id, "done", 100, "add bed track successful")
#
#
#
#
#
# def add_bed_track(session, species_id, track_id, bed_file):
#     response = {"track_id": track_id}
#     try:
#         track_dao.update_track_progress(session, track_id, "adding", 10, "index bed file")
#         return_code, error_msg = bed_index.index_bed_file(bed_file, track_id)
#         if str(return_code) == "0":
#             add_bed_track_task(session, species_id, track_id, bed_file)
#         else:
#             track_dao.update_track_error_msg(session, track_id, error_msg)
#     except Exception as e:
#         traceback.print_exc()
#         error_session = get_session()
#         track_dao.update_track_error_msg(error_session, track_id, str(e))
#         if error_session is not None:
#             error_session.remove()
#     finally:
#         if session is not None:
#             session.remove()
#     return response
#
#
#
# def get_track_data(request):
#     track_id = request.json["track_id"]
#     chr_id = request.json["chr_id"]
#     level = str(request.json["level"])
#     result = {"track_id":track_id, "chr_id": chr_id, "data":[]}
#     chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
#     chr_group = chr_group_track_dao.get_chr_group(g.session, track_id, chr_id, None)
#     track = track_dao.get_track(g.session, track_id)
#     if level == "1":
#         ref_start = int(request.json["ref_start"])
#         ref_end = int(request.json["ref_end"])
#         histo_count = int(request.json["histo_count"])
#         #mean std coverage min  max sum, 此处采用sum
#         stats_type = "sum"
#         if "stats_type" in request.json:
#             stats_type = request.json["stats_type"]
#         big_stats = bed_bigwig.read_track_chr_bigwigs(track_id, chromosome, ref_start, ref_end, histo_count, stats_type)
#         result = {"data":big_stats, "header": ["values"]}
#
#     elif level == "3":
#         block_index = int(request.json["block_index"])
#         block_info = chr_group_track_block_dao.get_chr_statistic(g.session, track_id, chr_id)
#         if block_info:
#             block = chr_group_track_block_dao.get_chr_group_block(g.session, track_id, chr_id, block_index, None)
#             if block:
#                 block_data_str = file_util.read_file(block.block_file)
#                 block_data = json.loads(block_data_str)
#             else:
#                 block_data = bed_block.write_block_data(track.track_file, chr_id, track_id, chr_group.matrix_chr_name, block_index, block_info.block_step, chromosome.seq_length)
#
#             view_header = ["name", "strand", "color", "start", "end", "bio_type", "subfeature"]
#             result = {"header": view_header, "data": block_data}
#     return result
#
#
#
#
# def get_track_statistics(track):
#     statistics = []
#     if track.status == "done":
#         chromosomes = chr_group_track_dao.get_track_chromosomes(g.list_session, track.id)
#         if len(chromosomes) > 0:
#             for chromosome in chromosomes:
#                 block_info = chr_group_track_block_dao.get_chr_statistic(g.list_session, track.id, chromosome.id)
#                 statistic = {"chr_id": chromosome.id, "feature_count": block_info.feature_count, "average_f_length": block_info.average_feature_length}
#                 statistics.append(statistic)
#     return statistics
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
