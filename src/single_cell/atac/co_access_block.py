# from flask import g
# from db.dao import chr_group_track_dao, chr_group_track_block_dao, feature_location_dao
# import json, os
# import pyarrow.feather as feather
# from path_config import track_folder
# from track.util import abstract_block_util
#
#
#
#
#
# block_line_count = 100
#
#
#
#
# def add_block_statistic(session, track_id, chromosome, line_count, block_source_file):
#     ref_length = chromosome.seq_length
#     block_length = (ref_length // line_count + 1) * block_line_count
#     block_count = ref_length // block_length + 1
#     chr_group_track_block_dao.add_statistic(session, track_id, chromosome.id, None, block_count, block_length, line_count, None, block_source_file)
#
#
#
# def get_block_statistics(track):
#     statistics = []
#     chromosomes = chr_group_track_dao.get_track_chromosomes(g.list_session, track.id)
#     if len(chromosomes) > 0:
#         for chromosome in chromosomes:
#             block_info = chr_group_track_block_dao.get_chr_statistic(track.id, chromosome.id)
#             statistic = {"chr_id": chromosome.id, "chr_name": chromosome.view_name, "feature_count": block_info.feature_count,
#                          "block_count": block_info.block_count, "block_step": block_info.block_step }
#             statistics.append(statistic)
#     return statistics
#
#
#
# def write_block_data(sc_id, track_id, chr_id, chr_name, block_index, block_step, ref_length):
#     sc = sc_dao.get_single_cell(g.session, sc_id)
#     data = []
#     if sc:
#         block_start = block_index * block_step
#         block_end = block_start + block_step
#         if block_end >= ref_length:
#             block_end = ref_length
#         block_info = chr_group_track_block_dao.get_chr_statistic(track_id, chr_id)
#         chr_co_access_file = block_info.block_source_file
#         df = feather.read_feather(chr_co_access_file, columns=["peak1_pos", "peak2_pos", "score"], memory_map=True)
#         r = df[((df["peak1_pos"] >= block_start) & (df["peak1_pos"] <= block_end)) | ((df["peak2_pos"] >= block_start) & (df["peak2_pos"] <= block_end))]
#         line_list = r.values.tolist()
#         for line in line_list:
#             # track_id, chr_id, middle_pos
#             peak1 = feature_location_dao.get_peak_by_middle_pos(g.session, sc.track_id, chr_id, str(int(line[0])))
#             peak2 = feature_location_dao.get_peak_by_middle_pos(g.session, sc.track_id, chr_id, str(int(line[1])))
#             # ["peak1_pos", "peak2_pos", "score", "peak1_name", "peak2_name"]
#             if peak1 and peak2:
#                 r = [line[0], line[1], line[2], peak1.view_name, peak2.view_name]
#                 data.append(r)
#         data_str = json.dumps(data)
#         block_folder = os.path.join(track_folder, track_id, "block", chr_name)
#         block_file = abstract_block_util.write_expand_block_file(block_folder, str(block_index), data_str)
#         chr_group_track_block_dao.add_block(g.session, track_id, chr_id, None, block_start, block_end, block_index, block_file, "full")
#     return data
#
#
#
#
#
