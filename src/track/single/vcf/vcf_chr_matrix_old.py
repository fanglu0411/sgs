# import json, os, vaex
# from db.dao import  chr_group_track_block_dao, chromosome_dao
# import pyarrow.feather as feather
# from track.single.vcf.parser import sample_parser, alt_parser
# import pandas as pd
#
#
#
#
#
# # response
# # records: ["feature_id", "feature_name", "ref_start", "ref_end", "alt_type", "alt_base", "alt", "ref_seq", "qual", "filter", "info", "alt_detail"]
# # alt_type: "SNV,DEL"
# # alt_detail: ["cat->ca", "cat->a"]
# def get_block_records_from_feather_file(track, chr_id, block_start, block_end):
#     # ["feature_id", "feature_name", "ref_start", "ref_end", "alt_type", "alt_base", "alt", "ref_seq", "qual", "filter", "info", "alt_detail"]
#     records = []
#     chr_block = chr_group_track_block_dao.get_chr_statistic(track["id"], chr_id)
#     if chr_block:
#         chr_matrix_file = chr_block["block_source_file"]
#         if os.path.exists(chr_matrix_file):
#             chr_df = feather.read_feather(chr_matrix_file, columns=["feature_id", "feature_name", "ref_start", "ref_end", "alt_type", "alt_base", "alt", "ref_seq", "qual", "filter", "info"], memory_map=True)
#             # chr_df = feather.read_feather(chr_matrix_file, columns=["pos", "feature_id", "feature_name", "alt_type", "alt_base", "ref_start", "ref_end", "info"], memory_map=True)
#             block_f_df = chr_df[ ((chr_df["ref_start"] >= block_start) & (chr_df["ref_start"] <= block_end)) | ((chr_df["ref_end"] >= block_start) & (chr_df["ref_end"] <= block_end))]
#             rec_lines = block_f_df.values.tolist()
#             for rec_line in rec_lines:
#                 alt_type = str(rec_line[4])
#                 alt_base_str = str(rec_line[5])
#                 alt_base_array = alt_parser.split_alt_base(alt_base_str)
#                 alt_detail = {alt_type: alt_base_array}
#                 # records.append([rec_line[1], rec_line[2], rec_line[3], alt_detail, rec_line[5], rec_line[6], rec_line[4], rec_line[7]])
#                 record = list(rec_line)
#                 record.append(alt_detail)
#                 records.append(record)
#     return records
#
#
#
#
#
# def get_block_samples_from_h5_folder(track, chr_id, block_start, block_end, chr_view_name):
#     sample_features = []
#     chr_block = chr_group_track_block_dao.get_chr_statistic(track["id"], chr_id)
#     if chr_block:
#         h5_folder = chr_block["block_source_file"]
#         if os.path.exists(h5_folder):
#             file_names = os.listdir(h5_folder)
#             path_names = [os.path.join(h5_folder, file_name) for file_name in file_names]
#             df_vaex_all = vaex.open_many(path_names)
#             # ["chr_view_name", "feature_id", "feature_name", "pos", "ref_start", "ref_end", "format", "samples"]
#             block_vaex = df_vaex_all[ (((df_vaex_all.pos >= block_start) & (df_vaex_all.pos <= block_end)) | ((df_vaex_all.pos >= block_start) & (df_vaex_all.pos <= block_end)))
#                                       & (df_vaex_all.chr_view_name == chr_view_name)]
#             pandas_columns = ["feature_id", "feature_name", "pos", "ref_start", "ref_end", "format", "samples"]
#             block_df = block_vaex.to_pandas_df(pandas_columns)
#             sample_lines = block_df.values.tolist()
#             samples_dict = {}
#             for sample_line in sample_lines:
#                 pos = sample_line[2]
#                 if not pos in samples_dict.keys():
#                     samples_dict[pos] = sample_line
#             sample_records = samples_dict.values()
#             for sample_record in sample_records:
#                 sample_feature =  sample_parser.sample_line2track_feature(sample_record)
#                 sample_features.append(sample_feature)
#     return sample_features
#
#
#
#
# # feature_id, feature_name, ref_start, ref_end, alt_type, alt_base, info
# def get_vcf_coverage_track_detail(match_features, chr_view_name):
#     # merge multi alt features
#     alt_type_base_str_dict = {}
#     for match_f in match_features:
#         alt_type = match_f[5]
#         alt_base_str = match_f[6]
#         alt_type_base_str_dict[alt_type] = alt_base_str
#     alt_detail_dict = alt_parser.get_alt_detail(alt_type_base_str_dict)
#     f_array = match_features[0]
#     attributes_dict = alt_parser.get_attribute_dict(f_array)
#     info_dict = alt_parser.get_info_dict(str(f_array[11]))
#     alt_detail_dict["attributes"] = attributes_dict
#     alt_detail_dict["info"] = info_dict
#     position = chr_view_name + ":" + str(f_array[3]) + "-" + str(f_array[4])
#     result = {"feature_id": f_array[0], "feature_name": f_array[1], "position": position, "alt detail": alt_detail_dict}
#     return result
#
#
#
#
#
# column_name_mapping = {
#     "pos": "pos",
#     "id": "feature_name",
#     "ref": "ref_seq",
#     "alt": "alt",
#     "qual": "qual",
#     "filter": "filter",
#     "info": "info"
# }
#
#
#
# # [feature_id, feature_name, pos, ref_start, ref_end, alt_type, alt_base, alt, ref_seq, qual, filter, info, info_key1, info_key2...]
# def filter_chr_vcf_records(filters, chr_matrix_file, page_num, page_size, track_start):
#     page_records = []
#     rec_count = 0
#     pre_query = ""
#     or_query_list = []
#     filter_count = len(filters)
#     filter_index = 0
#     chr_df = feather.read_feather(chr_matrix_file, memory_map=True)
#     all_columns = list(chr_df.columns)
#     info_tags = all_columns[12: ]
#     if filter_count > 0:
#         for condition in filters:
#             column = condition.get("column")
#             column_name = column_name_mapping.get(column)
#             tag = condition.get("tag")
#             operator = condition.get("operator")
#             value = condition.get("value")
#             pre_logic_operator = condition.get("pre_logic_operator")
#             if tag:
#                 column_name = tag
#             if chr_df[column_name].dtype == object:
#                 current_query = "(" + column_name + " " + operator + " \"" + str(value) + "\")"
#             else:
#                 current_query = "(" + column_name + " " + operator + " " + str(value) + " )"
#             if pre_logic_operator == "and":
#                 pre_query = "(" + pre_query + " and " + current_query + ")"
#             elif pre_logic_operator == "or":
#                 or_query_list.append(pre_query)
#                 pre_query = current_query
#             else:
#                 pre_query = current_query
#             filter_index = filter_index + 1
#             if filter_index == filter_count:
#                 or_query_list.append(pre_query)
#
#         if len(or_query_list) > 1:
#             all_query_str = "or".join(or_query_list)
#         else:
#             all_query_str = pre_query
#         print(all_query_str)
#         # filter_df = chr_df.query("(pos > 1000 and pos < 2000) or (pos > 3000 and pos < 5000)")
#         filter_df = chr_df.query(all_query_str)
#         # filter_df = chr_df.query("TSA ==\"SNV\" ")
#         filter_df = filter_df.copy()
#     else:
#         filter_df = chr_df
#     if not filter_df.empty:
#         # 去重复
#         filter_df.drop_duplicates(subset=["pos"], keep="first", inplace=True)
#         rec_count = int(filter_df.shape[0])
#         # 分页
#         if page_num > 0:
#             page_num = page_num - 1
#             start_index = page_num * page_size
#             end_index = start_index + page_size
#             page_marker_df = filter_df.iloc[start_index: end_index]
#             # # [feature_id, feature_name, pos, ref_start, ref_end, alt_type, alt_base, alt, ref_seq, qual, filter, info, info_key1, info_key2...]
#             # ["pos", "id", "ref", "alt", "qual", "filter", "info"]
#             page_marker_df = page_marker_df[["pos", "feature_name", "ref_seq", "alt", "qual", "filter", "info"]]
#             page_records = page_marker_df.values.tolist()
#         elif page_num == -1:
#             # 获取当前track位置所在的页数范围
#             if track_start > 0:
#                 pos_list = pd.Series.to_list(filter_df["pos"])
#                 pos_list.append(track_start)
#                 pos_list.sort()
#                 track_start_index = pos_list.index(track_start)
#                 page_num = track_start_index // page_size
#                 page_start = page_num * page_size
#                 page_end = page_start + page_size
#                 page_marker_df = filter_df.iloc[page_start: page_end]
#                 page_marker_df = page_marker_df[["pos", "feature_name", "ref_seq", "alt", "qual", "filter", "info"]]
#                 page_records = page_marker_df.values.tolist()
#     return page_records, rec_count, info_tags, page_num
#
#
#
#
# def search_chr_features(track, feature_id, page_num, page_size):
#     chromosomes = chromosome_dao.get_species_chromosomes(track.species_id)
#     all_df = pd.DataFrame()
#     if chromosomes:
#         for chromosome in chromosomes:
#             block_statistic = chr_group_track_block_dao.get_chr_statistic(track.id, chromosome["id"])
#             if block_statistic:
#                 chr_feather_file = block_statistic["block_source_file"]
#                 chr_df = feather.read_feather(chr_feather_file, columns=["feature_name", "ref_start", "ref_end"], memory_map=True)
#                 filter_df = chr_df.loc[chr_df['feature_name'].str.contains(feature_id, case=False)]
#                 filter_df["chr_id"] = str(chromosome["id"])
#                 if not filter_df.empty:
#                     print(chromosome["search_name"], " match")
#                     all_df = pd.concat([all_df, filter_df], axis=0)
#     rec_count = all_df.shape[0]
#     page_num = page_num - 1
#     start_index = page_num * page_size
#     end_index = start_index + page_size
#     page_marker_df = all_df.iloc[start_index: end_index]
#     feature_locations = page_marker_df.values.tolist()
#     return feature_locations, rec_count
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
