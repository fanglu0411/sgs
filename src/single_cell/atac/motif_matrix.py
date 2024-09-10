# import numpy as np
# import pandas as pd
# import json, os, traceback
# from util import id_util
# from track.track_type import motif_view
# from db.dao import track_dao
# from flask import g
# import pyarrow.feather as feather
# from old.single_cell_old.parser import matrix_meta_plot_parser
# from old.single_cell_old.image import image_type
# from path_config import sc_image_folder, sc_image_url
# # from multiprocessing import Pool, cpu_cou
# from old.single_cell_old import sc_marker
# from flask import Response
# from db.database_init import get_session
#
#
#
#
#
# # request
# # {
# # 	"matrix": "/hg19/sc/atac/pbmc500/chromvar_exp.feather",
# # 	"feature_names": ["ma0030.1", "ma0031.1", "ma0051.1", "ma0609.2"],
# # 	"marker": "/hg19/sc/atac/pbmc500/marker_motif.tsv",
# # 	"matrix_type": "motif",
# # 	"motif_pfm": "/hg19/sc/atac/pbmc500/chromvar_pfm.json"
# # }
# def create_matrix(session, single_cell, matrix_name, motif_matrix_detail, select_meta_columns):
#     track_dao.update_track_progress(g.thread_session, single_cell.track_id, "adding", 50, "create motif")
#     motif_names = motif_matrix_detail.get("feature_names")
#     matrix_file = motif_matrix_detail.get("matrix")
#     matrix_file = "/home/sgs/data" + matrix_file
#     marker_file = None
#     try:
#         if "marker" in motif_matrix_detail.keys():
#             marker_file = motif_matrix_detail.get("marker")
#             if marker_file and marker_file != "":
#                 marker_file = "/home/sgs/data" + marker_file
#         # motif 名转小写
#         lower_motif_names = []
#         for n in motif_names:
#             lower_motif_names.append(n.lower())
#         motif_names_str = json.dumps(lower_motif_names)
#         matrix_id = sc_dao.add_matrix(session, single_cell.id, matrix_name, "motif", None, matrix_file, motif_names_str, marker_file)
#
#         # motif logo
#         pfm_file = motif_matrix_detail.get("motif_pfm")
#         if pfm_file:
#             pfm_file = "/home/sgs/data" + pfm_file
#             motif_logo_data_dict_list = []
#             motifs = pd.read_json(pfm_file)
#             motifs.index = ["A", "C", "G", "T"]
#             motifs_dict = motifs.to_dict()
#             for m_name, logo_data in motifs_dict.items():
#
#                 # aa[0] for search,  aa[1] for draw image
#                 aa = m_name.split('_')
#                 motif_dict = {"view_name": str(aa[1]), "view_data": logo_data}
#                 motif_dict_str = json.dumps(motif_dict)
#                 motif_data_id = id_util.generate_uuid()
#                 motif_logo_data_dict = {"id": motif_data_id, "sc_id": single_cell.id, "matrix_id": matrix_id, "feature_name": str(aa[0]),
#                               "bio_type": motif_view, "view_data": motif_dict_str, "status": "done"}
#                 motif_logo_data_dict_list.append(motif_logo_data_dict)
#             sc_dao.bulk_feature_data(session, motif_logo_data_dict_list)
#
#         # update single cell all_meta_columns_groupby
#         if not single_cell.all_meta_columns_groupby:
#             cell_meta_df = feather.read_feather(matrix_file, columns=select_meta_columns, memory_map=True)
#             # cell_meta_df.index.name = "cell"
#             all_columns_groupby = matrix_meta_plot_parser.group_by_column_values(cell_meta_df)
#             all_columns_groupby_str = json.dumps(all_columns_groupby)
#             select_meta_columns_str = json.dumps(select_meta_columns)
#             sc_dao.update_sc(g.thread_session, single_cell.id, {"all_meta_columns_groupby": all_columns_groupby_str, "select_meta_columns": select_meta_columns_str})
#
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
# default_motif_column_name = ["feature", "motif", "motif_name", "gene"]
#
# def marker_motif_table(request):
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
#     if single_cell and matrix:
#         group_names = json.loads(single_cell.select_meta_columns)
#         matrix_motif_list = json.loads(matrix.matrix_features)
#         if group_name in group_names:
#             # motif	predicted_id	p_val	avg_log2FC	pct.1	pct.2	p_val_adj
#             # MA0476.1	CD14 Mono	5.664713179876548e-53	1.8715012857892166	0.933	0.179	3.585763442861855e-50
#             # MA0477.2	CD14 Mono	5.5945626969519344e-52	2.8103204327408173	0.933	0.175	3.5413581871705745e-49
#             if matrix.marker_file:
#                 marker_motif_df = pd.read_csv(matrix.marker_file, sep="\t")
#                 marker_columns = marker_motif_df.columns.tolist()
#                 motif_column_name = ""
#                 for column in marker_columns:
#                     if column.lower() in default_motif_column_name:
#                         motif_column_name = column
#                         break
#                 if group_name in marker_columns:
#                     marker_motif_df = marker_motif_df[marker_motif_df[group_name].apply(str) == group_value]
#                     matched_marker_motif_df, rec_count = sc_marker.page_marker_df(marker_motif_df, page_num, page_size)
#                     matched_marker_motif_df = matched_marker_motif_df.replace(np.nan, "")
#                     matched_marker_motif_df.set_index(motif_column_name, inplace=True)
#                     matched_marker_motif_df = matched_marker_motif_df.T
#                     matched_marker_motif_df.columns = matched_marker_motif_df.columns.map(lambda x: x.lower())
#                     matched_marker_motif_dict = matched_marker_motif_df.to_dict()
#                     matched_marker_motif_names = list(matched_marker_motif_dict.keys())
#                     if len(matched_marker_motif_names) > 0:
#                         has_logo_image = sc_dao.is_feature_data_exist(g.session, matrix_id)
#                         if has_logo_image:
#                             saved_images = sc_dao.get_features_images(g.session, sc_id, matrix_id, image_type.scatter, matched_marker_motif_names, None, group_name, group_value)
#                             saved_images_dict = {}
#                             for saved_image in saved_images:
#                                 if saved_image.feature_name not in saved_images_dict.keys():
#                                     saved_images_dict[saved_image.feature_name.lower()] = saved_image
#                             un_saved_images = []
#
#                             for matched_motif in matched_marker_motif_names:
#                                 if matched_motif in matrix_motif_list:
#                                     if matched_motif in saved_images_dict.keys():
#                                         image = saved_images_dict[matched_motif]
#                                         image_id = image.id
#                                         image_url = image.image_url
#                                         thumb_image_url = image.thumb_image_url
#                                     else:
#                                         image_id = id_util.generate_uuid()
#                                         image_file = str(image_id) + ".jpg"
#                                         thumb_image_file = str(image_id) + ".thumb.jpg"
#                                         image_url = os.path.join(sc_image_url, sc_id, image_file)
#                                         thumb_image_url = os.path.join(sc_image_url, sc_id, thumb_image_file)
#                                         image_folder = os.path.join(sc_image_folder, sc_id)
#                                         if not os.path.exists(image_folder):
#                                             os.makedirs(image_folder)
#                                         image_file = os.path.join(image_folder, image_file)
#                                         thumb_image_file = os.path.join(image_folder, thumb_image_file)
#                                         image_dict = {"id": image_id, "sc_id": sc_id, "matrix_id": matrix_id, "image_type": image_type.motif_logo, "feature_name": matched_motif,
#                                                       "group_name": group_name, "group_value": group_value, "image_path": image_file, "thumb_image_path": thumb_image_file,
#                                                       "image_url": image_url, "thumb_image_url": thumb_image_url, "status": "adding"}
#                                         un_saved_images.append(image_dict)
#
#                                     motif_dict = {"motif": matched_motif}
#                                     response_item = dict(motif_dict, **matched_marker_motif_dict.get(matched_motif))
#                                     response_item["image_url"] = image_url
#                                     response_item["thumb_image_url"] = thumb_image_url
#                                     response_item["image_id"] = image_id
#                                     response_table.append(response_item)
#                             sc_dao.bulk_feature_images(g.session, un_saved_images)
#                         else:
#                             for matched_motif in matched_marker_motif_names:
#                                 if matched_motif in matrix_motif_list:
#                                     response_item = matched_marker_motif_dict.get(matched_motif)
#                                     response_item["motif"] = matched_motif
#                                     response_table.append(response_item)
#     result = {"marker_genes": response_table, "rec_count": rec_count}
#     response = Response(json.dumps(result), mimetype='application/json')
#     return response
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
