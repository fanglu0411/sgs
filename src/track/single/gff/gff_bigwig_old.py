# from flask import g
# from track.single.gff import gff_path
# from db.dao import chr_group_track_dao, chromosome_dao
#
# import json, pyBigWig, os
# from util import file_util
# from pyranges import PyRanges
# from track.util.bigwig import coverage
#
#
#
#
#
#
# def gff2bigwig_binsize(session, track_id, chr_root_df_dict, chr_search_view_name_mapping, chr_name_obj_dict):
#     chr_length_dict = {}
#     big_folder = gff_path.get_big_folder(track_id)
#
#     for chr_search_name, chr_root_f_df in chr_root_df_dict.items():
#         chromosome = chr_name_obj_dict[chr_search_name]
#         chr_length = chromosome.seq_length
#         chr_length_dict[chr_search_name] = chr_length
#
#     sub_bw_file_chr_dict, sub_bw_file_binsize_dict, chr_binsize_level_dict = coverage.df2big(chr_root_df_dict, chr_length_dict, chr_search_view_name_mapping, big_folder)
#
#
#     for sub_bw_file, chr_search_name in sub_bw_file_chr_dict.items():
#         chromosome = chr_name_obj_dict[chr_search_name]
#         chr_view_name = chr_search_view_name_mapping[chr_search_name]
#         bin_size = sub_bw_file_binsize_dict[sub_bw_file]
#         chr_binsize_level = chr_binsize_level_dict[chr_search_name]
#         statistics = {"binsize": chr_binsize_level}
#         statistics_str = json.dumps(statistics)
#         chr_group_track_dao.add_chr_group(session, track_id, chromosome.id, "binsize", sub_bw_file, statistics_str, bin_size)
#
#
#
#
#
# # chr_root_df_dict: ["chr", "feature_type", "ref_start", "ref_end", "name"]
# # pyrange.to_bigwig
# def gff2bigwig(session, track_id, chr_root_df_dict, chr_view_name_dict, chr_name_obj_dict):
#     for chr_search_name, chr_root_f_df in chr_root_df_dict.items():
#         chromosome = chr_name_obj_dict[chr_search_name]
#         chr_view_name = chr_view_name_dict[chr_search_name]
#         to_bigwig_df = chr_root_f_df[["ref_start", "ref_end"]]
#         to_bigwig_df = to_bigwig_df.rename(columns={"ref_start": "Start", "ref_end": "End"})
#         # to_bigwig_df["Chromosome"] = chr_view_name
#         to_bigwig_df.insert(0, 'Chromosome', chr_view_name)
#         # to_bigwig_df["Counts"] = 1
#         print(to_bigwig_df)
#         pr = PyRanges(to_bigwig_df)
#         chr_big_file = gff_path.get_chr_big_file(track_id, chr_search_name)
#         pr.to_bigwig(chr_big_file, {chr_view_name: chromosome.seq_length})
#         print(pr)
#         chr_group_track_dao.add_chr_group(session, track_id, chromosome.id, "gene", chr_big_file, None, None)
#
#
#
# def gff2bigwig_binsize(session, track_id, chr_root_df_dict, chr_view_name_dict, chr_name_obj_dict, chr_average_f_length_dict):
#     for chr_search_name, chr_root_f_df in chr_root_df_dict.items():
#         chr_view_name = chr_view_name_dict[chr_search_name]
#         chr_average_f_length = chr_average_f_length_dict[chr_search_name]
#         chr_root_df = chr_root_df_dict[chr_search_name]
#         chr_root_df_count = chr_root_df[["ref_start", "ref_end"]]
#         chromosome = chr_name_obj_dict[chr_search_name]
#         chr_length = chromosome.seq_length
#         bin_size = 2*chr_average_f_length
#         print("bin_size: ", bin_size)
#         bin_start = 0
#
#         chroms = []
#         starts = []
#         ends = []
#         counts = []
#         if chr_average_f_length:
#             while bin_start < chr_length:
#                 bin_end = bin_start + bin_size
#                 if bin_end > chr_length:
#                     bin_end = chr_length
#                 bin_f_df = chr_root_df_count[(chr_root_df_count["ref_start"] >= bin_start) & (chr_root_df_count["ref_end"] <= bin_end)]
#                 chroms.append(chr_view_name)
#                 starts.append(bin_start)
#                 ends.append(bin_end)
#                 counts.append(float(bin_f_df.shape[0]))
#                 # bin_start = bin_end + 1
#                 bin_start = bin_end
#             chr_big_file = gff_path.get_chr_big_file(track_id, chr_search_name)
#             # todo root f_type
#             chr_group_track_dao.add_chr_group(session, track_id, chromosome.id, "gene", chr_big_file, None, None)
#             if os.path.exists(chr_big_file):
#                 file_util.delete_file(chr_big_file)
#             big_writer = None
#             try:
#                 big_writer = pyBigWig.open(chr_big_file, "w")
#                 big_writer.addHeader([(chr_view_name, chr_length)], maxZooms=0)
#                 big_writer.addEntries(chroms, starts, ends=ends, values=counts)
#             except RuntimeError as re:
#                 print(re)
#             finally:
#                 if big_writer:
#                     big_writer.close()
#
#
# from math import floor, ceil
# def read_chr_bigwigs(track_id, chr_id, start, end, histo_count, stats_type):
#     all_big_stats = {}
#     chr_groups = chr_group_track_dao.get_chr_all_group(g.session, track_id, chr_id)
#     for chr_group in chr_groups:
#         big_type = chr_group.group_name
#         big_file = chr_group.group_track_file
#         chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
#         big_reader = pyBigWig.open(big_file)
#         if end > (chromosome.seq_length -1):
#             end = chromosome.seq_length -1
#         if stats_type == "sum":
#             ss = big_reader.stats(chr_group.matrix_chr_name, start, end, nBins=histo_count)
#             stats = []
#             for s in ss:
#                 stats.append(ceil(s))
#         else:
#             stats = big_reader.stats(chr_group.matrix_chr_name, start, end, type=stats_type, nBins=histo_count)
#         all_big_stats[big_type] = stats
#         big_reader.close()
#     return all_big_stats
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
