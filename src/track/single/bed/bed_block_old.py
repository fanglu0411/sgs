# import json
# from track.util import abstract_block_util
# from flask import g
# from track.single.bed.normal import bed_path, bed_index
# from old.track.single.bed import bed_paser_old
# import numpy as np
# from pandas import DataFrame
# from db.dao import chr_group_track_block_dao
#
#
#
#
#
# block_f_count = 500
#
#
#
#
# def add_block_statistics(session, track_id, chr_id, group_df: DataFrame, chr_f_count, chr_ref_length):
#     f_length_column = group_df["End"] - group_df["Start"]
#     average_f_length = int(f_length_column.mean())
#     block_length = (chr_ref_length // chr_f_count + 1) * block_f_count
#     block_count = chr_ref_length // block_length + 1
#     chr_group_track_block_dao.add_statistic(session, track_id, chr_id, None, block_count, block_length, chr_f_count, average_f_length, None)
#
#
#
#
#
#
# ##在expand block中存入数据（this changed)
# #定义自定义类来用于将feature_view_list转换为json格式
# class NpEncoder(json.JSONEncoder):
#     def default(self, obj):
#         if isinstance(obj, np.integer):
#             return int(obj)
#         elif isinstance(obj, np.floating):
#             return float(obj)
#         elif isinstance(obj, np.ndarray):
#             return obj.tolist()
#         else:
#             return super(NpEncoder, self).default(obj)
#
#
#
#
# def write_block_data(bed_file, chr_id, track_id, chr_name, block_index, block_step, ref_length):
#     block_start = block_index * block_step
#     block_end = block_start + block_step
#     if block_end >= ref_length:
#         block_end = ref_length
#     records = bed_index.get_records_from_index_file(track_id, bed_file, chr_name, block_start, block_end)
#
#     # feature_view_array, feature_es_array = bed_paser.parse_records(records)
#
#     feature_view_array = bed_paser_old.parse_records(records)
#
#
#     # database
#     block_data_str = json.dumps(feature_view_array)
#     expand_block_folder = bed_path.get_expand_block_folder(track_id, chr_name)
#     block_file = abstract_block_util.write_expand_block_file(expand_block_folder, str(block_index), block_data_str)
#     chr_group_track_block_dao.add_block(g.session, track_id, chr_id, None, block_start, block_end, block_index, block_file, "full")
#
#     # elasticsearch todo
#     # add_block_records(track_id, chr_name, block_index, feature_es_array)
#
#     return feature_view_array
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
