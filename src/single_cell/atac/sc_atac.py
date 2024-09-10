# import json, traceback
# from flask import g
# from util import id_util
# from db.database_init import get_session
# from old.single_cell_old.trans import gene_exp_matrix
# from old.single_cell_old.atac import motif_matrix
# from old.single_cell_old.atac import peak_matrix, peak_block
# from track.track_type import sc_atac, combine_track, peak, motif, gene_exp, sc_atac_track
# from db.dao import chr_group_track_block_dao, track_dao, chr_group_track_dao, chromosome_dao
# from util import file_util
# from old.single_cell_old.atac import co_access_block
#
#
#
#
#
# # todo
# def create_new_sc_from_file(request):
#     print()
#
#
#
# # todo
# def complete_sc_from_file(request):
#     print()
#
#
#
#
#
# # request
# # {
# #     "species_id": "",
# #     "sc_id": "",
# #     "sc_type": "atac",
# #     "sc_name":"",
# #     "feature_matrix": {"gene_score": "xxx.json", "integration": "xxxx.json", "peak": "xxxx.json", "motif": "xxxx.json"},
# #     "select_meta_columns": ["cluster","seurat_clusters"],
# #     "all_meta_columns":["cluster","nCount_RNA","nFeature_RNA","percent.mt","seurat_clusters", "orig.ident", "RNA_snn_res.0.5"],
# #     "cell_plots":["umap","tsne"]
# # }
# def create_sc_from_signac(request):
#     species_id = request.json["species_id"]
#     single_cell_id = request.json["sc_id"]
#     sc_name = request.json["sc_name"]
#     select_meta_columns = request.json["select_meta_columns"]
#     all_meta_columns = request.json["all_meta_columns"]
#     cell_plots_name_list = request.json["cell_plots"]
#     feature_matrix_dict = request.json["feature_matrix"]
#
#     g.thread_session = get_session()
#     atac_track_id = id_util.generate_uuid()
#     response = {"single_cell_id": single_cell_id, "track_id": atac_track_id}
#     try:
#         # add single cell
#         meta_columns_str = json.dumps(all_meta_columns)
#         track_dao.add_track_with_id(g.thread_session, atac_track_id, species_id, sc_name, sc_atac_track, combine_track, None, "adding", None, None)
#         sc_dao.add_sc(g.thread_session, single_cell_id, sc_atac, species_id, atac_track_id, sc_name, None, meta_columns_str, None, None, "adding")
#
#         # add cell plots
#         for plot_name in cell_plots_name_list:
#             sc_dao.add_cell_plot(g.thread_session, single_cell_id, plot_name, None)
#
#         # add gene exp matrix track
#         for matrix_name, matrix_detail_file in feature_matrix_dict.items():
#             single_cell = sc_dao.get_single_cell(g.thread_session, single_cell_id)
#             matrix_detail_file = "/home/sgs/data" + matrix_detail_file
#             with open(matrix_detail_file) as f:
#                 json_str = f.read()
#                 matrix_detail = json.loads(json_str)
#             f.close()
#             matrix_type = matrix_detail.get("matrix_type")
#             if matrix_type == gene_exp:
#                 gene_exp_matrix.create_matrix_track(g.thread_session, single_cell, matrix_name, matrix_detail, select_meta_columns)
#             elif matrix_type == peak:
#                 peak_matrix.create_matrix_track(g.thread_session, single_cell, matrix_name, matrix_detail, select_meta_columns)
#             elif matrix_type == motif:
#                 motif_matrix.create_matrix(g.thread_session, single_cell, matrix_name, matrix_detail, select_meta_columns)
#
#         track_dao.update_track_progress(g.thread_session, atac_track_id, "done", 100, "create single cell successful")
#         sc_dao.update_sc_status(g.thread_session, single_cell_id, "done")
#         response = {"single_cell_id": single_cell_id, "track_id": atac_track_id, "status": "done"}
#     except Exception as e:
#         traceback.print_exc()
#         error_session = get_session()
#         track_dao.update_track_error_msg(error_session, atac_track_id, str(e))
#         sc_dao.update_sc_status(error_session, single_cell_id, "error")
#         if error_session is not None:
#             error_session.remove()
#     finally:
#         if g.thread_session is not None:
#             g.thread_session.remove()
#     return response
#
#
#
#
#
# def get_peak_data(request):
#     sc_id = request.json["sc_id"]
#     block_index = request.json["block_index"]
#     track_id = request.json["track_id"]
#     chr_id = request.json["chr_id"]
#
#     response = {"data": [], "header": ["peak_name", "start", "end"]}
#     chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
#     chr_group = chr_group_track_dao.get_chr_group(g.session, track_id, chr_id, None)
#     if chromosome and chr_group:
#         block_info = chr_group_track_block_dao.get_chr_statistic(track_id, chr_id)
#         if block_info:
#             block = chr_group_track_block_dao.get_chr_group_block(g.session, track_id, chr_id, block_index, None)
#             if block:
#                 block_data_str = file_util.read_file(block.block_file)
#                 block_data = json.loads(block_data_str)
#             else:
#                 block_data = peak_block.write_block_data(sc_id, track_id, chr_id, chr_group.matrix_chr_name, block_index, block_info.block_step, chromosome.seq_length)
#             response["data"] = block_data
#     return response
#
#
#
# def get_co_access_data(request):
#     sc_id = request.json["sc_id"]
#     block_index = request.json["block_index"]
#     track_id = request.json["track_id"]
#     chr_id = request.json["chr_id"]
#
#     response = {"data": [], "header": ["peak1_pos", "peak2_pos", "score", "peak1_name", "peak2_name"]}
#     chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
#     chr_group = chr_group_track_dao.get_chr_group(g.session, track_id, chr_id, None)
#     if chromosome and chr_group:
#         block_info = chr_group_track_block_dao.get_chr_statistic(track_id, chr_id)
#         if block_info:
#             block = chr_group_track_block_dao.get_chr_group_block(g.session, track_id, chr_id, block_index, None)
#             if block:
#                 block_data_str = file_util.read_file(block.block_file)
#                 block_data = json.loads(block_data_str)
#             else:
#                 block_data = co_access_block.write_block_data(sc_id, track_id, chr_id, chr_group.matrix_chr_name, block_index, block_info.block_step, chromosome.seq_length)
#             response["data"] = block_data
#     return response
#
#
#
#
#
#
