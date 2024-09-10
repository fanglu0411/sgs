# from db.dao import chr_group_track_block_dao
# from track.single.gff.parser import record2dict
# from flask import g
# import os
# import pyarrow.feather as feather
# import pandas as pd
# from track.single.gff.model.gff_feature import GFFFeature
#
#
#
#
#
#
#
# def get_feature_detail_old(track_id, chr_id, feature_id, block_id):
#     data = []
#     feature_id = feature_id.lower()
#     chr_block_statistic = chr_group_track_block_dao.get_chr_statistic(g.session, track_id, chr_id)
#     if chr_block_statistic:
#         chr_matrix_file = chr_block_statistic.block_source_file
#         if os.path.exists(chr_matrix_file):
#             chr_df = feather.read_feather(chr_matrix_file, columns=["chr", "source", "feature_type", "ref_start", "ref_end", "score",
#                                                "strand", "phase", "attribute", "name", "id", "parent"], memory_map=True)
#             chr_root_f_df = chr_df.loc[chr_df["id"] == feature_id]
#             chr_root_f_df = chr_root_f_df[["feature_type", "source", "ref_start", "ref_end", "score", "strand", "phase", "attribute", "name", "id", "parent"]]
#             children_f_df = chr_df.loc[chr_df["parent"] == feature_id]
#             children_f_df = children_f_df[["feature_type", "source", "ref_start", "ref_end", "score", "strand", "phase", "attribute", "name", "id", "parent"]]
#             children_f_df.drop_duplicates()
#             # sub_feature_df of children feature
#             children_f_id_series = children_f_df["id"]
#             children_f_id_list = list(children_f_id_series)
#             children_f_id_list = list(filter(None, children_f_id_list))
#             sub_f_df = chr_df.loc[chr_df["parent"].isin(children_f_id_list)]
#             sub_f_df = sub_f_df[["source", "feature_type", "ref_start", "ref_end", "score", "strand", "phase", "attribute", "name", "id", "parent"]]
#             f_df = pd.concat([chr_root_f_df, children_f_df, sub_f_df], sort=False)
#             records = f_df.values.tolist()
#             # feature_type, feature_id, feature_name, source, start, end, score, strand, phase, attributes, sub_features, children
#             data = record2dict.records2f_detail(records)
#
#     # "feature_id", "feature_name", "feature_type", "source", "start", "end", "score", "strand", "phase", "attributes", "sub_feature", "children"
#     detail_header = ["feature_type", "feature_id", "feature_name", "source", "start", "end", "score", "strand", "phase", "attributes", "sub_feature", "children"]
#     return {"feature_id": feature_id, "header": detail_header, "data": data}
#
#
#
#
#
#
# def records2f_detail(records):
#     f_detail = []
#     f_obj_dict = {}
#     for record in records:
#         record2feature_object(record, f_obj_dict)
#     # add intron
#     for fo in f_obj_dict.values():
#         bio_type = feature_util.get_bio_type(fo.feature_type)
#         if bio_type == gff_gene:
#             feature_util.build_gene_intron(fo)
#         elif bio_type == gff_transcript:
#             feature_util.build_mRNA_intron(fo)
#     for fo in f_obj_dict.values():
#         if len(fo.parents_id) == 0:
#             f_detail = dict_util.feature_obj2es_array(fo)
#     return f_detail
#
#
#
#
#
#
# # source, feature_type, start, end, score, strand, phase, attributes, name, id, parent
# def record2feature_object(record, feature_obj_dict):
#     source = record[0]
#     feature_type = record[1]
#     start = int(record[2])
#     end = int(record[3])
#     score = record[4]
#     strand = record[5]  # '+', '-', '.', '?'
#     phase = record[6] # 0, 1, 2 or "."
#     attributes_str = record[7]
#     name = record[8]
#     f_id = record[9]
#     parent_str = str(record[10])
#     attribute_dict = attribute_str2dict(attributes_str.strip())
#     gff_bio_type = feature_type_parser.get_gff_bio_type(feature_type)
#     if gff_bio_type == "feature":
#         mrna_parser.parse_feature(feature_obj_dict, source, feature_type, start, end, score, strand, phase, attribute_dict, name, f_id, parent_str)
#     elif gff_bio_type == "target" or gff_bio_type == "match":
#         alignment_parser.parse_alignment(feature_obj_dict, source, feature_type, start, end, score, strand, phase, attribute_dict, f_id)
#
#
#
# def get_records_view_data_old(records):
#     f_obj_dict = {}
#     for record in records:
#         record2feature_object(record, f_obj_dict)
#
#     # add intron
#     for fo in f_obj_dict.values():
#         bio_type = feature_util.get_bio_type(fo.feature_type)
#         if bio_type == gff_gene:
#             feature_util.build_gene_intron(fo)
#         elif bio_type == gff_transcript:
#             feature_util.build_mRNA_intron(fo)
#     tree_f_obj_dict = {}
#     for fo in f_obj_dict.values():
#         if len(fo.parents_id) == 0:
#             tree_f_obj_dict[fo.feature_id] = fo
#     feature_view_array = []
#     for fo in tree_f_obj_dict.values():
#         fv = dict_util.feature_obj2view_array(fo)
#         feature_view_array.append(fv)
#     return feature_view_array
#
#
#
# def parse_alignment_old(feature_obj_dict, source, f_type, start, end, score, strand, phase, attributes, match_id):
#     attribute_keys = list(attributes.keys())
#     # name 生成策略
#     match_name = ""
#     name_keys = list(set(default_feature_name_keys).intersection(set(attribute_keys)))
#     if len(name_keys) > 0:
#         name_key = name_keys[0]
#         match_name = attributes.get(name_key)
#         match_name = ",".join(match_name)
#     if match_name == "":
#         id_keys = list(set(default_id_keys).intersection(set(attribute_keys)))
#         if len(id_keys) > 0:
#             id_key = id_keys[0]
#             match_name = attributes.get(id_key)
#             match_name = ",".join(match_name)
#     # Target='NM_153443.4 1 84 +'
#     if "target" in attributes.keys():
#         target_attribute = attributes.get("target")
#         target_array = str(target_attribute[0]).split(" ")
#         target_id = str(target_array[0])
#         t = feature_obj_dict.get(target_id)
#         if t is None:
#             t = GFFFeature.init("alignment", target_id, target_id, [], f_type, source, start, end, score, strand, phase, [], [], [])
#             feature_obj_dict[target_id] = t
#             match_group = GFFFeature.init("alignment", target_id, target_id, [], f_type, source, start, end, score, strand, phase, [], [], [])
#             match = GFFFeature.init("alignment", match_id, match_name, [], f_type, source, start, end, score, strand, phase, [], [], [])
#             match_group.sub_features.append(match)
#             t.children.append(match_group)
#         else:
#             match_groups = t.children
#             for match_group in match_groups:
#                 match_group_id = match_group.feature_id
#                 if target_id == match_group_id:
#                     m = GFFFeature.init("alignment", match_id, match_name, [], f_type, source, start, end, score, strand, phase, [], [], [])
#                     match_group.sub_features.append(m)
#                     if match_group.start > match_group.start:
#                         match_group.start = match_group.start
#                     if match_group.end < match_group.end:
#                         match_group.end = match_group.end
#             if t.start > start:
#                 t.start = start
#             if t.end < end:
#                 t.end = end
#

#
# def parse_alignment_old(feature_obj_dict, source, f_type, start, end, score, strand, phase, attributes, match_id):
#     attribute_keys = list(attributes.keys())
#     # name 生成策略
#     match_name = ""
#     name_keys = list(set(default_feature_name_keys).intersection(set(attribute_keys)))
#     if len(name_keys) > 0:
#         name_key = name_keys[0]
#         match_name = attributes.get(name_key)
#         match_name = ",".join(match_name)
#     if match_name == "":
#         id_keys = list(set(default_id_keys).intersection(set(attribute_keys)))
#         if len(id_keys) > 0:
#             id_key = id_keys[0]
#             match_name = attributes.get(id_key)
#             match_name = ",".join(match_name)
#     # Target='NM_153443.4 1 84 +'
#     if "target" in attributes.keys():
#         target_attribute = attributes.get("target")
#         target_array = str(target_attribute[0]).split(" ")
#         target_id = str(target_array[0])
#         t = feature_obj_dict.get(target_id)
#         if t is None:
#             t = GFFFeature.init("alignment", target_id, target_id, [], f_type, source, start, end, score, strand, phase, [], [], [])
#             feature_obj_dict[target_id] = t
#             match = GFFFeature.init("alignment", match_id, match_name, [], f_type, source, start, end, score, strand, phase, [], [], [])
#             t.sub_features.append(match)
#         else:
#             m = GFFFeature.init("alignment", match_id, match_name, [], f_type, source, start, end, score, strand, phase, [], [], [])
#             t.sub_features.append(m)
#             if t.start > t.start:
#                 t.start = t.start
#             if t.end < t.end:
#                 t.end = t.end
#             if t.start > start:
#                 t.start = start
#             if t.end < end:
#                 t.end = end




# from single_cell_old.parser import coverage_util
# # chr_root_df_dict: ["chr", "feature_type", "ref_start", "ref_end", "name"]
# def gff2bigwig_old(session, track_id, chr_root_df_dict, chr_view_name_dict, chr_name_obj_dict):
#     for chr_search_name, chr_root_f_df in chr_root_df_dict.items():
#         chromosome = chr_name_obj_dict[chr_search_name]
#         chr_view_name = chr_view_name_dict[chr_search_name]
#         to_bigwig_df = chr_root_f_df[["feature_type", "ref_start", "ref_end"]]
#         to_bigwig_df = to_bigwig_df.rename(columns={"ref_start": "Start", "ref_end": "End"})
#         to_bigwig_df["Chromosome"] = chr_view_name
#         print(chr_view_name)
#         f_type_dfs = {k: v for k, v in to_bigwig_df.groupby("feature_type")}
#         for f_type, f_type_df in f_type_dfs.items():
#             sub_df = f_type_df[["Chromosome", "Start", "End"]]
#             print(sub_df.shape)
#             df_split = coverage_util.split_range(sub_df)
#             print(df_split.shape)
#             df_split = df_split[["Chromosome", "Start", "End"]]
#             chr_df_result = coverage_util.count_coverage(df_split, sub_df, "count")
#             print(chr_df_result.shape)
#             sub_big_file = gff_path.get_split_big_file(track_id, chromosome.search_name, f_type)
#             chr_group_track_dao.add_chr_group(session, track_id, chromosome.id, f_type, sub_big_file, None, None)
#             coverage_util.df2bigwig(chr_df_result, sub_big_file, chromosome.seq_length, chr_view_name)



















