# import pyarrow.feather as feather
# import json, os, traceback
# from flask import g
# import pandas as pd
# from pandas.core.frame import DataFrame
# from track.track_type import sc_peak_track, single_track, peak, sc_co_access_track, sc_group_coverage_track
# from util import id_util, file_util
# from db.dao import track_dao, chr_group_track_dao, chromosome_dao, feature_location_dao
# from path_config import sc_folder
# from old.single_cell_old.parser import matrix_meta_plot_parser
# from old.single_cell_old.atac import co_access_block
# from old.single_cell_old.atac import group_coverage, peak_block
# import numpy as np
# from track.util import track_util
# from old.single_cell_old import sc_marker
# # from multiprocessing import Pool, cpu_count
# from flask import Response
# from db.database_init import get_session
#
#
#
#
#
# def create_peak_track(peak_matrix_detail, single_cell, matrix_id):
#     chr_peak_count_dict = {}
#     peak_track_id = id_util.generate_uuid()
#     try:
#         track_dao.add_track_with_matrix(g.thread_session, peak_track_id, single_cell.species_id, matrix_id, None,
#                                         sc_peak_track, single_track, None, "peak track", "adding", single_cell.track_id, None)
#         track_dao.update_track_progress(g.thread_session, single_cell.track_id, "adding", 20, "create peak sub_track")
#         peak_names = peak_matrix_detail.get("feature_names")
#         peak_name_df = DataFrame(peak_names, columns=["feature_names"])
#         peak_df = peak_name_df["feature_names"].str.split("-", expand=True)
#
#         peak_df.columns = ["chr", "start", "end"]
#         peak_df["start"] = peak_df["start"].astype("int64")
#         peak_df["end"] = peak_df["end"].astype("int64")
#
#         # co_access position
#         # mean_series = peak_df[["start", "end"]].mean(axis=1)
#         # mean_df = DataFrame(mean_series, columns=["pos"])
#         # mean_df["pos"] = mean_df["pos"].astype("int64")
#
#         peak_df = pd.concat([peak_name_df, peak_df], ignore_index=True, axis=1)
#         peak_df.columns = ["peak_name", "chr", "start", "end"]
#         peak_dfs = {k: v for k, v in peak_df.groupby("chr")}
#         for chr_matrix_name, chr_peak_df in peak_dfs.items():
#             chr_db_search_name = track_util.get_chr_search_name(chr_matrix_name)
#             chromosome = chromosome_dao.get_chromosome_by_search_name(single_cell.species_id, chr_db_search_name)
#             chr_matrix_folder = os.path.join(sc_folder, single_cell.id, peak_track_id, chr_matrix_name)
#             if not os.path.exists(chr_matrix_folder):
#                 os.makedirs(chr_matrix_folder)
#             chr_peak_file = os.path.join(chr_matrix_folder, "peak.f")
#             feather.write_feather(chr_peak_df, chr_peak_file)
#             chr_group_track_dao.add_chr_group(g.thread_session, peak_track_id, chromosome.id, None, None, None, None)
#             peak_count = int(chr_peak_df.shape[0])
#             peak_block.add_block_statistic(g.thread_session, peak_track_id, chromosome, peak_count, chr_peak_file)
#             chr_peak_count_dict[chr_matrix_name] = peak_count
#
#             # todo save peak locations
#             chr_peak_list = chr_peak_df.values.tolist()
#             # [[{"species_id": 1, "track_id": 1, "chr_id": 1, "ref_start": 1, "ref_end": 100, "search_name": "", "view_name": "", "feature_type": "gene"}], ...]
#             peak_loc_list = []
#             for chr_peak in chr_peak_list:
#                 # chr_peak:  ["peak_name", "chr", "start", "end"]
#                 ref_start = int(chr_peak[2])
#                 ref_end = int(chr_peak[3])
#                 middle_pos = (ref_end + ref_start)//2
#                 search_name = str(middle_pos)
#                 peak_loc_dict = {"track_id": single_cell.track_id, "chr_id": chromosome.id, "ref_start": ref_start, "ref_end": ref_end,
#                                  "search_name": search_name, "view_name": str(chr_peak[0]), "feature_type": "peak"}
#                 peak_loc_list.append(peak_loc_dict)
#             feature_location_dao.bulk_chr_f_locations(g.thread_session, peak_loc_list)
#         track_dao.update_track_progress(g.thread_session, peak_track_id, "done", 100, "create peak track successful")
#     except Exception as e:
#         traceback.print_exc()
#         error_session = get_session()
#         track_dao.update_track_error_msg(error_session, single_cell.track_id, str(e))
#         if error_session is not None:
#             error_session.remove()
#
#     return chr_peak_count_dict
#
#
#
#
# # chr_peak_count_dict: {chr_matrix_name: peak_count}
# def create_co_access_track(peak_matrix_detail, single_cell, matrix_id, chr_peak_count_dict):
#     co_access_track_id = id_util.generate_uuid()
#     # chr    peak1_pos    peak2_pos    width    strand    score    group
#     # chr1    9779366    10003229  223864      *  0.153027   23.0
#     co_access_file = peak_matrix_detail.get("co_access")
#     if co_access_file and not co_access_file == "":
#         try:
#             co_access_file = "/home/sgs/data" + co_access_file
#             track_dao.add_track_with_matrix(g.thread_session, co_access_track_id, single_cell.species_id, matrix_id, None, sc_co_access_track,
#                                             single_track, None, "co access track", "adding", single_cell.track_id, None)
#             track_dao.update_track_progress(g.thread_session, single_cell.track_id, "adding", 30, "create co_access sub_track")
#             # "chr", "peak1_pos", "peak2_pos"
#             co_access_df = pd.read_csv(co_access_file, sep="\t", names=["chr", "peak1_pos", "peak2_pos", "with", "strand", "score", "group"], header=1, index_col=False)
#             co_access_df = co_access_df[["chr", "peak1_pos", "peak2_pos", "score"]]
#             chr_co_access_dfs = {k: v for k, v in co_access_df.groupby("chr")}
#             for chr_matrix_name, chr_co_access_df in chr_co_access_dfs.items():
#                 if chr_matrix_name in chr_peak_count_dict.keys():
#                     chr_db_search_name = track_util.get_chr_search_name(chr_matrix_name)
#                     chromosome = chromosome_dao.get_chromosome_by_search_name(single_cell.species_id, chr_db_search_name)
#                     chr_matrix_folder = os.path.join(sc_folder, single_cell.id, co_access_track_id, chr_matrix_name)
#                     if not os.path.exists(chr_matrix_folder):
#                         os.makedirs(chr_matrix_folder)
#                     chr_co_access_file = os.path.join(chr_matrix_folder, "co_access.f")
#                     feather.write_feather(chr_co_access_df, chr_co_access_file)
#                     chr_group_track_dao.add_chr_group(g.thread_session, co_access_track_id, chromosome.id, None, None, None, None)
#                     chr_peak_count = chr_peak_count_dict[chr_matrix_name]
#                     co_access_block.add_block_statistic(g.thread_session, co_access_track_id, chromosome, chr_peak_count, chr_co_access_file)
#             track_dao.update_track_status(g.thread_session, co_access_track_id, "done")
#         except Exception as e:
#             traceback.print_exc()
#             error_session = get_session()
#             track_dao.update_track_error_msg(error_session, single_cell.track_id, str(e))
#             if error_session is not None:
#                 error_session.remove()
#
#
#
# def create_group_coverage_track(session, peak_matrix_detail, single_cell, matrix_id):
#     group_coverage_track_id = id_util.generate_uuid()
#     try:
#         track_dao.add_track_with_matrix(g.thread_session, group_coverage_track_id, single_cell.species_id, matrix_id, None, sc_group_coverage_track,
#                                         single_track, None, "group coverage track", "adding", single_cell.track_id, None)
#         track_dao.update_track_progress(g.thread_session, single_cell.track_id, "adding", 40, "create group coverage sub_track")
#         sc_dao.update_sc_status(g.thread_session, group_coverage_track_id, "add peak coverage track")
#         group_fragment_folder = peak_matrix_detail.get("fragment")
#         for group_name, group_folder in group_fragment_folder.items():
#             group_folder = "/home/sgs/data" + group_folder
#             if os.path.exists(group_folder):
#                 for root, dirs, files in os.walk(group_folder):
#                     for file in files:
#                         group_fragment_file = (os.path.join(root, file))
#                         group_value = file_util.get_file_base_name(file)
#                         group_coverage.create_group_coverage_tracks(session, group_name, group_value, group_fragment_file, single_cell.species_id, single_cell.id, group_coverage_track_id)
#         track_dao.update_track_status(g.thread_session, group_coverage_track_id, "done")
#     except Exception as e:
#         traceback.print_exc()
#         error_session = get_session()
#         track_dao.update_track_error_msg(error_session, single_cell.track_id, str(e))
#         if error_session is not None:
#             error_session.remove()
#
#
#
# # peak_matrix_detail.json
# # {
# #   "matrix": "/hg19/sc/atac/pbmc500/peaks_exp.feather",
# #   "feature_names": ["chr1-565153-565499","chr1-713583-714698","chr1-752530-752930"],
# #   "marker": "/hg19/sc/atac/pbmc500/marker_peaks.tsv",
# #   "matrix_type": "peak",
# #   "co_access": "/hg19/sc/atac/pbmc500/peaks_coaccss.tsv",
# #   "fragment": {
# #     "seurat_clusters": "/hg19/sc/atac/pbmc500/peaks/seurat_clusters/",
# #     "predicted_id": "/hg19/sc/atac/pbmc500/peaks/predicted_id/"}
# # }
# def create_matrix_track(session, single_cell, matrix_name, peak_matrix_detail, select_meta_columns):
#     try:
#         matrix_file = peak_matrix_detail.get("matrix")
#         matrix_file = "/home/sgs/data" + matrix_file
#         peak_names = peak_matrix_detail.get("feature_names")
#
#         marker_file = None
#         if "marker" in peak_matrix_detail.keys():
#             marker_file = peak_matrix_detail.get("marker")
#             marker_file = "/home/sgs/data" + marker_file
#
#         # peak 名转小写
#         lower_peak_names = []
#         for peak_name in peak_names:
#             lower_peak_names.append(peak_name.lower())
#         peak_names_str = json.dumps(lower_peak_names)
#         matrix_id = sc_dao.add_matrix(session, single_cell.id, matrix_name, peak, None, matrix_file, peak_names_str, marker_file)
#
#         # peak sub track
#         chr_peak_count_dict = create_peak_track(peak_matrix_detail, single_cell, matrix_id)
#         if "co_access" in peak_matrix_detail.keys():
#
#             # create co_access sub track
#             create_co_access_track(peak_matrix_detail, single_cell, matrix_id, chr_peak_count_dict)
#
#         # group coverage sub track
#         create_group_coverage_track(session, peak_matrix_detail, single_cell, matrix_id)
#
#         # update single cell all_meta_columns_groupby
#         if not single_cell.all_meta_columns_groupby:
#             cell_meta_df = feather.read_feather(matrix_file, columns=select_meta_columns, memory_map=True)
#             # cell_meta_df.index.name = "cell"
#             all_columns_groupby = matrix_meta_plot_parser.group_by_column_values(cell_meta_df)
#             all_columns_groupby_str = json.dumps(all_columns_groupby)
#             select_meta_columns_str = json.dumps(select_meta_columns)
#             sc_dao.update_sc(g.thread_session, single_cell.id, {"all_meta_columns_groupby": all_columns_groupby_str, "select_meta_columns": select_meta_columns_str})
#     except Exception as e:
#         traceback.print_exc()
#         error_session = get_session()
#         track_dao.update_track_error_msg(error_session, single_cell.track_id, str(e))
#         if error_session is not None:
#             error_session.remove()
#
#
#
#
#
# default_peak_column_name = ["feature", "peak", "peak_name", "gene"]
#
#
# # marker file column and peak_start
# def marker_peak_table(request):
#     response_table = []
#     sc_id = request.json["sc_id"]
#     group_name = request.json["group_name"]
#     group_value = request.json["group_value"]
#     matrix_id = request.json["matrix_id"]
#     page_num = 0
#     rec_count = 0
#     page_size = 10
#     if "page_num" in request.json:
#         page_num = request.json["page_num"]
#     if "page_size" in request.json:
#         page_size = request.json["page_size"]
#
#     single_cell = sc_dao.get_single_cell(g.session, sc_id)
#     matrix = sc_dao.get_matrix(g.session, matrix_id)
#     group_coverage_track = sc_dao.get_matrix_group_coverage_track(g.session, matrix_id)
#     if single_cell and matrix:
#         group_names = json.loads(single_cell.select_meta_columns)
#         matrix_peak_list = json.loads(matrix.matrix_features)
#
#         if group_name in group_names:
#             # get marker features from marker_feature_file
#             if matrix.marker_file and matrix.marker_file != "":
#                 # peak	predicted_id	p_val	avg_log2FC	pct.1	pct.2	p_val_adj
#                 # chr9-137263452-137265457	CD14 Mono	3.478384349471294e-31	0.6595356038349154	0.59	0.052	1.5708035883777416e-26
#                 # chr20-39317448-39319254	CD14 Mono	3.0016985380394005e-27	0.6010477606479909	0.523	0.074	1.3555370427932129e-22
#                 marker_peak_df = pd.read_csv(matrix.marker_file, sep="\t")
#                 marker_columns = marker_peak_df.columns.tolist()
#                 peak_column_name = ""
#                 for column in marker_columns:
#                     if column.lower() in default_peak_column_name:
#                         peak_column_name = column
#                         break
#                 # marker_feature_df = marker_features_df[marker_features_df[feature_column_name].isin([feature_name])]
#
#                 if group_name in marker_columns and peak_column_name != "":
#                     # todo 规范矩阵格式 不能含有对象类型
#                     marker_peak_df = marker_peak_df[marker_peak_df[group_name].apply(str) == group_value]
#                     matched_marker_peak_df, rec_count = sc_marker.page_marker_df(marker_peak_df, page_num, page_size)
#                     matched_marker_peak_df = matched_marker_peak_df.replace(np.nan, "")
#                     matched_marker_peak_df.set_index(peak_column_name, inplace=True)
#                     matched_marker_peak_df = matched_marker_peak_df.T
#                     matched_marker_peak_df.columns = matched_marker_peak_df.columns.map(lambda x: x.lower())
#                     matched_marker_peak_dict = matched_marker_peak_df.to_dict()
#                     matched_marker_peak_names = list(matched_marker_peak_dict.keys())
#                     if len(matched_marker_peak_names) > 0:
#                         # {"peak_name": "", "chr_name": "" , "peak_start": 0 , "peak_end": 100, ...}
#                         for matched_peak in matched_marker_peak_names:
#                             if matched_peak in matrix_peak_list:
#                                 peak_dict = {"peak_name": matched_peak}
#                                 response_item = dict(peak_dict, **matched_marker_peak_dict.get(matched_peak))
#                                 peak_loc = str(matched_peak).split("-")
#                                 chr_name = str(peak_loc[0])
#                                 response_item["peak_start"] = int(peak_loc[1])
#                                 response_item["peak_end"] = int(peak_loc[2])
#                                 response_item["chr_name"] = chr_name
#                                 response_table.append(response_item)
#
#     result = {"marker_peaks": response_table, "group_coverage_track_id": group_coverage_track.id, "group_name": group_name,
#             "matrix_id": matrix_id, "rec_count": rec_count}
#     response = Response(json.dumps(result), mimetype='application/json')
#     return response
#
#
#
#
#
