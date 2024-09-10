# import json, os
# from old.single_cell_old.parser import matrix_meta_plot_parser, feature_util
# from flask import g
# from util import id_util, file_util
# from path_config import sc_folder
# import pandas as pd
# from db.database_init import get_session
# from db.dao import track_dao
# from db.table import SingleCell
# from old.single_cell_old.trans import trans_track_block, gene_exp_matrix
# from track.track_type import single_track, sc_cluster_histo_track, sc_transcript_track, combine_track, sc_transcript, gene_exp
# import traceback
#
#
#
#
# # {
# #     "species_id": "",
# #     "sc_type": "transcript",
# #     "sc_name": "",
# #     "cell_meta_file": "cell_meta.tsv",
# #     "feature_matrix": [{"name": "gene_score", "file": "mouse_exp.tsv" , "marker": "marker_gene.txt"}],
# #     "cell_plots": {"umap": "umap.coords.tsv", "lsi": "si.coords.tsv"}
# # }
# def create_new_sc_from_file(request):
#     sc_name = request.json["sc_name"]
#     species_id = request.json["species_id"]
#     cell_meta_file = request.json["cell_meta_file"]
#     gene_matrix_list = request.json["feature_matrix"]
#     cell_plots = request.json["cell_plots"]
#
#     track_id = id_util.generate_uuid()
#     single_cell_id = id_util.generate_uuid()
#     response = {"sc_id": single_cell_id}
#     try:
#         # add single cell
#         cell_meta_file = file_util.decompress_file(cell_meta_file)
#         cell_meta_columns = []
#         cell_meta_df = pd.read_csv(cell_meta_file, sep="\t", index_col=0)
#         if cell_meta_df is not None:
#             cell_meta_columns = list(cell_meta_df.columns)
#         meta_columns = json.dumps(cell_meta_columns)
#
#         track_dao.add_track_with_id(g.session, track_id, species_id, sc_name, sc_transcript_track, combine_track, None, "adding", None, None)
#         sc_dao.add_sc(g.session, single_cell_id, sc_transcript, species_id, track_id, sc_name, cell_meta_file, meta_columns, None, None, "adding")
#
#         # add cell plots
#         for plot_name, plot_file in cell_plots.items():
#             plot_file = file_util.decompress_file(plot_file)
#             sc_dao.add_cell_plot(g.session, single_cell_id, plot_name, plot_file)
#
#         # add gene matrix
#         for gene_matrix in gene_matrix_list:
#             matrix_name = gene_matrix.get("name")
#             matrix_file = gene_matrix.get("file")
#             # matrix_file = file_util.get_file_base_name(matrix_file)
#             marker_file = gene_matrix.get("marker")
#             # marker_file = file_util.get_file_base_name(marker_file)
#             matrix_meta_plot_folder = os.path.join(sc_folder, single_cell_id, matrix_name)
#             if not os.path.exists(matrix_meta_plot_folder):
#                 os.makedirs(matrix_meta_plot_folder)
#             matrix_meta_plot_file = os.path.join(matrix_meta_plot_folder, "matrix_meta_plot.f")
#             sc_dao.add_matrix(g.session, single_cell_id, matrix_name, gene_exp, matrix_file,  matrix_meta_plot_file, None, marker_file)
#         response = {"sc_id": single_cell_id, "cell_meta_columns": cell_meta_columns}
#         track_dao.update_track_progress(g.session, track_id, "done", 100, "create single cell successful")
#     except Exception as e:
#         track_dao.update_track_error_msg(None, track_id, str(e))
#         traceback.print_exc()
#     return response
#
#
#
# # {
# #     "sc_id": "",
# #     "sc_type": "transcript",
# #     "cell_meta_columns": [
# #         "Cluster",
# #         "sample",
# #         "cell_type"
# #     ]
# # }
# def complete_file_sc_task(sc: SingleCell, select_cell_meta_columns):
#     try:
#         g.thread_session = get_session()
#         # update single cell
#         cell_meta_df = pd.read_csv(sc.meta_file, usecols=select_cell_meta_columns, sep="\t")
#         # cell_meta_df = feather.read_feather(sc.meta_file, columns=select_cell_meta_columns, memory_map=True)
#         # cell_meta_df.index.name = "cell"
#         all_columns_groupby = matrix_meta_plot_parser.group_by_column_values(cell_meta_df)
#         all_columns_groupby_str = json.dumps(all_columns_groupby)
#         select_meta_columns_str = json.dumps(select_cell_meta_columns)
#         sc_dao.update_sc(g.thread_session, sc.id, {"all_meta_columns_groupby": all_columns_groupby_str, "select_meta_columns": select_meta_columns_str})
#
#         # update feature matrix
#         gene_matrix_list = sc_dao.get_sc_feature_matrix(g.thread_session, sc.id, "gene")
#         meta_file = sc.meta_file
#         cell_plot_file_map = {}
#         plots = sc_dao.get_cell_plots(g.thread_session, sc.id)
#         for plot in plots:
#             cell_plot_file_map[plot.name] = plot.plot_file
#         for gene_matrix in gene_matrix_list:
#             matrix_f_list = matrix_meta_plot_parser.merge_cell_meta_plot(cell_plot_file_map, meta_file, gene_matrix.matrix_file,
#                                                                          gene_matrix.matrix_meta_plot_file, select_cell_meta_columns)
#             matrix_f_list_str = json.dumps(matrix_f_list)
#             sc_dao.update_matrix(g.thread_session, gene_matrix.id, {"matrix_features": matrix_f_list_str})
#
#             # add cluster histogram sub track   {chr_id: [[gene_name, start, end], []...], ...}
#             chr_f_locs_dict = feature_util.get_gene_location(g.thread_session, matrix_f_list, sc.species_id)
#             if chr_f_locs_dict:
#                 sub_track_id = id_util.generate_uuid()
#                 track_dao.add_track_with_matrix(g.thread_session, sub_track_id, sc.species_id, gene_matrix.id, gene_matrix.name,
#                                                 sc_cluster_histo_track, single_track, None, None, "adding", sc.track_id, None)
#                 trans_track_block.add_block_statistic(g.thread_session, sub_track_id, chr_f_locs_dict)
#                 track_dao.update_track_status(g.thread_session, sub_track_id, "done")
#
#         track_dao.update_track_progress(g.thread_session, sc.track_id, "done", 100, None)
#         sc_dao.update_sc_status(g.thread_session, sc.id, "done")
#     except Exception as e:
#         track_dao.update_track_error_msg(None, sc.track_id, str(e))
#         traceback.print_exc()
#     if g.thread_session is not None:
#         g.thread_session.remove()
#
#
#
#
#
# # {
# #     "sc_id": "5f2f1b38eef64217ade40be4cfcc6c09",
# #     "cell_meta_columns": [
# #         "Cluster",
# #         "sample"
# #     ]
# # }
# def complete_sc_from_file(request):
#     sc_id = request.json["sc_id"]
#     select_cell_meta_columns = request.json["cell_meta_columns"]
#     sc = sc_dao.get_single_cell(g.session, sc_id)
#     if sc:
#         complete_file_sc_task(sc, select_cell_meta_columns)
#         # task_pool = Pool(1)
#         # task_pool.apply_async(complete_file_sc_task, args=(sc, select_cell_meta_columns))
#         # task_pool.close()
#         sc1 = sc_dao.get_single_cell(g.session, sc_id)
#         return {"single_cell_id": sc_id, "track_id": sc1.track_id, "status": sc1.status}
#     else:
#         return {"error": "no single cell error"}
#
#
#
#
# # {
# #     "species_id": "",
# #     "sc_type": "transcript",
# #     "sc_name": "",
# #     "feature_matrix": {"gene_score": "gene_score_matrix_detail.json", "integration": "integration_matrix_detail.json"},
# #     "select_meta_columns": ["cluster", "seurat_clusters"],
# #     "all_meta_columns":["cluster", "nCount_RNA", "nFeature_RNA", "percent.mt", "seurat_clusters", "orig.ident", "RNA_snn_res.0.5"],
# #     "cell_plots":["umap", "tsne"]
# # }
# def create_sc_from_seurat(request):
#     species_id = request.json["species_id"]
#     single_cell_id = request.json["sc_id"]
#     sc_name = request.json["sc_name"]
#     select_meta_columns = request.json["select_meta_columns"]
#     all_meta_columns = request.json["all_meta_columns"]
#     cell_plots_name_list = request.json["cell_plots"]
#     feature_matrix_dict = request.json["feature_matrix"]
#
#     parent_track_id = id_util.generate_uuid()
#     response = {"single_cell_id": single_cell_id, "track_id": parent_track_id}
#     try:
#         g.thread_session = get_session()
#         # add single cell
#         meta_columns_str = json.dumps(all_meta_columns)
#         track_dao.add_track_with_id(g.thread_session, parent_track_id, species_id, sc_name, sc_transcript_track, combine_track, None, "adding", None, None)
#         sc_dao.add_sc(g.thread_session, single_cell_id, sc_transcript, species_id, parent_track_id, sc_name, None, meta_columns_str, None, None, "adding")
#
#         # add cell plots
#         for plot_name in cell_plots_name_list:
#             sc_dao.add_cell_plot(g.thread_session, single_cell_id, plot_name, None)
#
#         # add gene exp matrix track
#         track_dao.update_track_progress(g.session, parent_track_id, "adding", 30, "parse expression matrix")
#         for matrix_name, matrix_detail_file in feature_matrix_dict.items():
#             single_cell = sc_dao.get_single_cell(g.thread_session, single_cell_id)
#             matrix_detail_file = "/home/sgs/data" + matrix_detail_file
#             with open(matrix_detail_file) as f:
#                 json_str = f.read()
#                 matrix_detail = json.loads(json_str)
#             f.close()
#             gene_exp_matrix.create_matrix_track(g.thread_session, single_cell, matrix_name, matrix_detail, select_meta_columns)
#
#         sc_dao.update_sc_status(g.thread_session, single_cell_id, "done")
#         track_dao.update_track_progress(g.session, parent_track_id, "done", 100, "create single cell successful")
#         response = {"single_cell_id": single_cell_id, "track_id": parent_track_id, "status": "done"}
#
#     except Exception as e:
#         track_dao.update_track_error_msg(None, parent_track_id, str(e))
#         traceback.print_exc()
#
#     finally:
#         if g.thread_session is not None:
#             g.thread_session.remove()
#
#     return response
#
#
#
#
#
#
# # todo delete sc 同时删除track
#
#
#
#
#
#
