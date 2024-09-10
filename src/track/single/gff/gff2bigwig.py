#
#
#
#
#
#
#
# # todo 可能换成线段树算法
# def gff2bigwig_old(big_chr_records, track_id, species_id):
#     # fuc_start = time.time()
#     chr_names = chromosome_dao.get_species_all_chr_name(g.thread_session, species_id)
#     for chr_name, big_type_dict in big_chr_records.items():
#         chr_db_search_name = track_util.get_chr_search_name(chr_name)
#         if chr_db_search_name not in chr_names:
#             print(chr_name, " not in species ", species_id)
#             continue
#         chromosome = chromosome_dao.get_chromosome_by_search_name(species_id, chr_db_search_name)
#         if chromosome:
#             for big_type, records in big_type_dict.items():
#                 intervals = {}
#                 for rec in records:
#                     add_rec2bin_intervals(rec, intervals)
#                 sorted_intervals = {}
#                 for k, v in sorted(intervals.items()):
#                     sorted_intervals[k] = v
#                 write_sub_big_intervals(track_id, chromosome, chr_name, big_type, sorted_intervals)
#     # cost_time = time.time() - fuc_start
#     # print(track_id, " %s cost %s second" % ("gff2bigwig", cost_time))
#
#
#
#
# # chr_df columns=["chr_search_name", "feature_type", "ref_start", "ref_end"]
# def gff2bigwig_old2(chr_df, track_id, chromosome, chr_view_name):
#     f_type_dfs = {k: v for k, v in chr_df.groupby("feature_type")}
#     for f_type, f_type_df in f_type_dfs.items():
#         sub_df = f_type_df[["Chromosome", "Start", "End"]]
#         df_split = coverage_util.split_range(sub_df)
#         df_split = df_split[["Chromosome", "Start", "End"]]
#         chr_df_result = coverage_util.count_coverage(df_split, chr_df, "count")
#         sub_big_file = gff_path.get_split_big_file(track_id, chromosome.search_name, f_type)
#         chr_group_track_dao.add_chr_group(g.thread_session, track_id, chromosome.id, f_type, sub_big_file, None, None)
#         coverage_util.df2bigwig(chr_df_result, sub_big_file, chromosome.seq_length, chr_view_name)
#
#
#
#
#
