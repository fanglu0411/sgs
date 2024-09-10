# import os, json
# from flask import g
# from db.dao import chr_group_track_dao, chr_group_track_block_dao
# import pyarrow.feather as feather
# from path_config import track_folder
# from track.util import abstract_block_util
#
#
#
#
#
#
# block_peak_count = 100
#
#
#
#
# def add_block_statistic(session, track_id, chromosome, peak_count, block_source_file):
#     ref_length = chromosome.seq_length
#     block_length = (ref_length // peak_count + 1) * block_peak_count
#     block_count = ref_length // block_length + 1
#     chr_group_track_block_dao.add_statistic(session, track_id, chromosome.id, None, block_count, block_length, peak_count, None, block_source_file)
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
#             statistic = {"chr_id": chromosome.id, "chr_name": chromosome.view_name, "feature_count": block_info.feature_count,
#                          "block_count": block_info.block_count, "block_step": block_info.block_step }
#             statistics.append(statistic)
#     return statistics
#
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
#         chr_peak_file = block_info.block_source_file
#         df = feather.read_feather(chr_peak_file, columns=["peak_name", "start", "end"], memory_map=True)
#         r = df[((df["start"] >= block_start) & (df["start"] <= block_end)) | ((df["end"] >= block_start) & (df["end"] <= block_end))]
#         data = r.values.tolist()
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
#
#
#
