# from old.single_cell_old.parser.coverage_util import duplicate_df, split_range, count_coverage, df2bigwig
# import pandas as pd
# from db.dao import track_dao, chromosome_dao, chr_group_track_dao
# import os, json
# from path_config import sc_folder
# from flask import g
# from track.single.big import big_parser
# from track.util import track_util
#
#
# def create_group_coverage_tracks(session, group_name, group_value, group_fragment_file, species_id, sc_id, track_id):
#     df = pd.read_csv(group_fragment_file, sep="\t", names=["Chromosome", "Start", "End", "cell", "count"])
#     dfs = {k: v for k, v in df.groupby("Chromosome")}
#     for chr_name, chr_df in dfs.items():
#         # chr_df = chr_df[chr_df.select_dtypes(include=[np.number]).ge(0).all(1)]
#
#         group_value_folder = os.path.join(sc_folder, sc_id, track_id, group_name, group_value)
#         if not os.path.exists(group_value_folder):
#             os.makedirs(group_value_folder)
#         chr_db_search_name = track_util.get_chr_search_name(chr_name)
#         chromosome = chromosome_dao.get_chromosome_by_search_name(species_id, chr_db_search_name)
#         if chromosome:
#             # chr_df = chr_df.iloc[: -9020687]
#             # print(chr_df)
#
#             chr_df["Start"] = chr_df["Start"].astype("int64")
#             chr_df["End"] = chr_df["End"].astype("int64")
#             chr_df["count"] = chr_df["count"].astype("int64")
#             df_dup = duplicate_df(chr_df)
#             df_split = split_range(df_dup)
#             df_dup = df_dup[["Chromosome", "Start", "End", "cell"]]
#             df_result = count_coverage(df_split, df_dup, "count")
#             big_file = os.path.join(group_value_folder, chr_name)
#             big_file = big_file + ".bigwig"
#             df2bigwig(df_result, big_file, chromosome.seq_length, chr_name)
#             interval_count, max_value = big_parser.chr_intervals_and_max(big_file, chr_name, chromosome.seq_length)
#             statistic = {"max_value": max_value, "interval_count": interval_count}
#             statistic_str = json.dumps(statistic)
#             chr_group_track_dao.add_chr_group(session, track_id, chromosome.id, group_name, big_file, statistic_str, group_value)
#
#
#
#
#
#
# # {
# #     "track_id": "682721c460834f488c8b300dcf3c50a6",
# #     "chr_id": "7573a70d63484460b6b9e89f3bed57a2",
# #     "ref_start": 100,
# #     "ref_end": 100000,
# #     "group_name": "predicted_id",
# #     "level": 3
# # }
# # or
# # {
# #     "track_id": "682721c460834f488c8b300dcf3c50a6",
# #     "chr_id": "ae1921170f77414e9c94213fe045345c",
# #     "ref_start": 100,
# #     "ref_end": 1000000,
# #     "group_name": "predicted_id",
# #     "histo_count": 50,
# #     "stats_type": "max",
# #     "level": 1
# # }
# def get_group_coverage_data(track_id, chr_id, ref_start, ref_end, group_name, level, group_values, histo_count, stats_type):
#
#     response = {"data": [], "header": []}
#     chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
#     chr_group = chr_group_track_dao.get_chr_group(g.session, track_id, chr_id, group_name)
#     track = track_dao.get_track(g.session, track_id)
#     if track and chr_group:
#         data = {}
#         items = chr_group_track_dao.get_chr_group_all_value(g.session, track_id, chr_id, group_name)
#         new_items = []
#         if group_values:
#             if len(group_values) > 0:
#                 for item in items:
#                     if item.group_value in group_values:
#                         new_items.append(item)
#         else:
#             new_items = items
#         if level == "1":
#             if not stats_type:
#                 stats_type = "max"
#             for item in new_items:
#                 big_file = item.group_track_file
#                 stats = big_parser.get_stats_data(big_file, chromosome.view_name, ref_start, ref_end, histo_count, stats_type)
#                 data[item.group_value] = stats
#             response = {"data": data, "header": ["value"]}
#
#         elif level == "3":
#             for item in new_items:
#                 big_file = item.group_track_file
#                 histo_list = big_parser.get_interval_data(big_file, chromosome.view_name, ref_start, ref_end)
#                 data[item.group_value] = histo_list
#
#             response = {"data": data, "header": ["start", "end", "value"]}
#     return response
#
#
#
# def answer_group_coverage_request(request):
#     track_id = request.json["track_id"]
#     chr_id = request.json["chr_id"]
#     ref_start = request.json["ref_start"]
#     ref_end = request.json["ref_end"]
#     group_name = request.json["group_name"]
#     level = str(request.json["level"])
#     group_values = None
#     if "group_values" in request.json:
#         group_values = request.json["group_values"]
#     histo_count = None
#     if "histo_count" in request.json:
#         histo_count = request.json["histo_count"]
#     stats_type = None
#     if "stats_type" in request.json:
#         stats_type = request.json["stats_type"]
#     response = get_group_coverage_data(track_id, chr_id, ref_start, ref_end, group_name, level, group_values, histo_count, stats_type)
#     return response
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
#                 # {"group_name": [{"group_value": "CD14_Mono", "feature_count": 100, "max_value": 10}, {}] }  todo
#                 group_statistic = {}
#                 group_names = chr_group_track_dao.get_chr_all_group_names(g.list_session, track.id, chromosome.id)
#                 for group_name in group_names:
#                     group_value_statistics = []
#                     group_values = chr_group_track_dao.get_chr_group_all_value(g.list_session, track.id, chromosome.id, group_name)
#                     for group_value in group_values:
#                         s = json.loads(group_value.statistic)
#                         group_value_statistics.append(s)
#
#                     group_statistic[group_name] = group_value_statistics
#
#                 statistic = {"chr_id": chromosome.id, "groups": group_statistic}
#                 statistics.append(statistic)
#     return statistics
#
#
#
#
# # ll = [["chr1", 100, 200, "cell1", 0], ["chr1", 50, 90, "cell2", 0], ["chr1", 220, 600, "cell2", 0]]
# #
# # df_ll = pd.DataFrame(ll, columns=["Chromosome", "Start", "End", "cell", "count"])
# # print(df_ll)
# # df_dup = duplicate_df(df_ll)
# # print(df_dup)
# # df_split = split_range(df_dup)
# # print(df_split)
# # df_result = count_coverage(df_split, df_dup, "count")
# # print(df_result)
# #
# #
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
