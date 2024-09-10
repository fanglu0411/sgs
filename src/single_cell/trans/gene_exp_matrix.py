# import json, os
# from flask import g
# from db.dao import track_dao, feature_location_dao
# from old.single_cell_old.trans import trans_track_block
# from track.track_type import single_track, sc_cluster_histo_track, gene_exp
# import pyarrow.feather as feather
# from old.single_cell_old.parser import matrix_meta_plot_parser, feature_util
# from util import id_util
# from path_config import sc_image_folder, sc_image_url
# import pandas as pd
# import numpy as np
# # from multiprocessing import Pool, cpu_count
# from old.single_cell_old.image import image_type
# from old.single_cell_old import sc_marker
# from flask import Response
# from db.database_init import get_session
# import traceback
#
#
#
#
#
# # gene_score_matrix_detail.json or integration_matrix_detail.json (matrix_detail_file)
# # {
# #   "matrix": "/hg19/sc/seurat/all_file.feather",
# #   "matrix_type": "peak",
# #   "marker": "/hg19/sc/seurat/markers.tsv",
# #   "feature_names": []
# # }
# def create_matrix_track(session, single_cell, matrix_name, matrix_detail, select_meta_columns):
#     if matrix_detail:
#         track_dao.update_track_progress(g.thread_session, single_cell.track_id, "adding", 10, "create RNA seq sub track")
#         exp_track_id = id_util.generate_uuid()
#         merge_matrix_file = matrix_detail.get("matrix")
#         try:
#             # rstudio路径映射到api
#             merge_matrix_file = "/home/sgs/data" + merge_matrix_file
#             gene_names = matrix_detail.get("feature_names")
#             # 基因名转小写
#             lower_gene_names = []
#             for gene_name in gene_names:
#                 lower_gene_names.append(gene_name.lower())
#             lower_gene_names_str = json.dumps(lower_gene_names)
#
#             marker_file = None
#             if "marker" in matrix_detail.keys():
#                 marker_file = matrix_detail.get("marker")
#                 marker_file = "/home/sgs/data" + marker_file
#
#             matrix_id = sc_dao.add_matrix(session, single_cell.id, matrix_name, gene_exp, None, merge_matrix_file, lower_gene_names_str, marker_file)
#             # add cluster histogram sub track   {chr_id: [[gene_name, start, end], []...], ...}
#             chr_f_locs_dict = feature_util.get_gene_location(g.thread_session, lower_gene_names, single_cell.species_id)
#             track_dao.add_track_with_matrix(g.thread_session, exp_track_id, single_cell.species_id, matrix_id, matrix_name, sc_cluster_histo_track,
#                                             single_track, None, None, "adding", single_cell.track_id, None)
#
#             trans_track_block.add_block_statistic(g.thread_session, exp_track_id, chr_f_locs_dict)
#             # update single cell all_meta_columns_groupby
#             if not single_cell.all_meta_columns_groupby:
#                 cell_meta_df = feather.read_feather(merge_matrix_file, columns=select_meta_columns, memory_map=True)
#                 # cell_meta_df.index.name = "cell"
#                 all_columns_groupby = matrix_meta_plot_parser.group_by_column_values(cell_meta_df)
#                 all_columns_groupby_str = json.dumps(all_columns_groupby)
#                 select_meta_columns_str = json.dumps(select_meta_columns)
#                 sc_dao.update_sc(g.thread_session, single_cell.id, {"all_meta_columns_groupby": all_columns_groupby_str, "select_meta_columns": select_meta_columns_str})
#
#             track_dao.update_track_status(g.thread_session, exp_track_id, "done")
#         except Exception as e:
#             traceback.print_exc()
#             error_session = get_session()
#             track_dao.update_track_error_msg(error_session, exp_track_id, str(e))
#             track_dao.update_track_error_msg(error_session, single_cell.track_id, str(e))
#             if error_session is not None:
#                 error_session.remove()
#
#
#
#
# default_gene_column_name = ["feature", "gene", "gene_name", "gene_id", "symbol"]
#
# # request
# # {
# #     "sc_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #     "mod_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #     "column_name": "Cluster",
# #     "column_value": "3T3",
# #     "plot_name": "umap"
# # }
# # response
# # {
# #     "marker_genes": [
# #         {
# #             "Cluster": "3T3",
# #             "P-value": 0.0,
# #             "gene": "st6galnac3",
# #             "image_id": "3cde90f56c3e4d128d6e558953ff9037",
# #             "image_url": "",
# #             "thumb_image_url": ""
# #         }
# #     ]
# # }
# def marker_gene_table(request):
#     response_table = []
#     sc_id = request.json["sc_id"]
#     plot_name = request.json["plot_name"]
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
#     plots = sc_dao.get_cell_plots(g.session, sc_id)
#     if single_cell and matrix and plots:
#         cell_plot_names = []
#         for p in plots:
#             cell_plot_names.append(p.name)
#         group_names = json.loads(single_cell.select_meta_columns)
#         matrix_gene_list = json.loads(matrix.matrix_features)
#
#         if group_name in group_names and plot_name in cell_plot_names:
#             # get marker features from marker_feature_file
#             if matrix.marker_file:
#                 marker_genes_df = pd.read_csv(matrix.marker_file, sep="\t")
#                 marker_columns = marker_genes_df.columns.tolist()
#                 feature_column_name = ""
#                 for column in marker_columns:
#                     if column.lower() in default_gene_column_name:
#                         feature_column_name = column
#                         break
#                 # marker_feature_df = marker_features_df[marker_features_df[feature_column_name].isin([feature_name])]
#                 # 查询前先转成str
#                 if group_name in marker_columns:
#                     # todo 规范矩阵格式 不能含有对象类型
#                     marker_gene_df = marker_genes_df[marker_genes_df[group_name].apply(str) == group_value]
#                     matched_marker_gene_df, rec_count = sc_marker.page_marker_df(marker_gene_df, page_num, page_size)
#                     matched_marker_gene_df = matched_marker_gene_df.replace(np.nan, "")
#
#                     # gene	celltype	RNA.avgExpr	RNA.logFC	RNA.statistic	RNA.auc	RNA.pval	RNA.padj	RNA.pct_in	RNA.pct_out	gene.1
#                     # AL627309.1	CD14 Mono	0.013711322325727275	0.011839564655609595	10804397	0.5081899821298107	7.28744844635817e-19	3.800972248503606e-18	1.90032269630692	0.2623638987275351	AL627309.1
#                     # AL627309.5	CD14 Mono	0.08875323109637744	0.07781092127891631	11781182	0.5541335319359375	1.7012872784042793e-124	3.085783132553969e-123	12.37002509860165	1.5479470024924569	AL627309.5
#                     matched_marker_gene_df.set_index(feature_column_name, inplace=True)
#                     matched_marker_gene_df_t = matched_marker_gene_df.T
#                     matched_marker_gene_df_t.columns = matched_marker_gene_df_t.columns.map(lambda x: x.lower())  # after set_index, to_dict need to make index as key first
#                     matched_marker_gene_dict = matched_marker_gene_df_t.to_dict()
#                     matched_marker_gene_names = list(matched_marker_gene_dict.keys())
#                     if len(matched_marker_gene_names) > 0:
#                         matched_genes_db = feature_location_dao.get_f_locations_by_f_names(g.session, matched_marker_gene_names, single_cell.species_id, "gene")
#                         gene_search_view_name_dict = {}
#                         for gene_db in matched_genes_db:
#                             if gene_db.search_name in matched_marker_gene_names:
#                                 gene_search_view_name_dict[gene_db.search_name] = gene_db.view_name
#                         saved_images = sc_dao.get_features_images(g.session, sc_id, matrix_id, image_type.scatter, matched_marker_gene_names, plot_name, group_name, group_value)
#                         saved_images_dict = {}
#                         for saved_image in saved_images:
#                             if saved_image.feature_name not in saved_images_dict.keys():
#                                 saved_images_dict[saved_image.feature_name.lower()] = saved_image
#                         un_saved_images = []
#                         for search_name, view_name in gene_search_view_name_dict.items():
#                             if search_name in matrix_gene_list:
#                                 if search_name in saved_images_dict.keys():
#                                     image = saved_images_dict[search_name]
#                                     image_id = image.id
#                                     image_url = image.image_url
#                                     thumb_image_url = image.thumb_image_url
#                                 else:
#                                     image_id = id_util.generate_uuid()
#                                     image_file = str(image_id) + ".jpg"
#                                     thumb_image_file = str(image_id) + ".thumb.jpg"
#                                     image_url = os.path.join(sc_image_url, sc_id, image_file)
#                                     thumb_image_url = os.path.join(sc_image_url, sc_id, thumb_image_file)
#                                     image_folder = os.path.join(sc_image_folder, sc_id)
#                                     if not os.path.exists(image_folder):
#                                         os.makedirs(image_folder)
#                                     image_file = os.path.join(image_folder, image_file)
#                                     thumb_image_file = os.path.join(image_folder, thumb_image_file)
#                                     image_dict = {"id": image_id, "sc_id": sc_id, "matrix_id": matrix_id,
#                                                   "image_type": image_type.scatter, "feature_name": view_name,
#                                                   "group_name": group_name, "group_value": group_value,
#                                                   "tags": plot_name, "image_path": image_file,
#                                                   "thumb_image_path": thumb_image_file,
#                                                   "image_url": image_url, "thumb_image_url": thumb_image_url,
#                                                   "status": "adding"}
#                                     un_saved_images.append(image_dict)
#                                 gene_name_dict = {"gene": view_name}
#                                 response_item =  dict(gene_name_dict, **matched_marker_gene_dict.get(search_name))
#                                 response_item["image_url"] = image_url
#                                 response_item["thumb_image_url"] = thumb_image_url
#                                 response_item["image_id"] = image_id
#                                 response_table.append(response_item)
#
#                         # add incomplete images to database
#                         if len(un_saved_images)>0:
#                             sc_dao.bulk_feature_images(g.session, un_saved_images)
#     result = {"marker_genes": response_table, "rec_count": rec_count}
#     response = Response(json.dumps(result), mimetype='application/json')
#     return response
#
#
#
#
#
#
