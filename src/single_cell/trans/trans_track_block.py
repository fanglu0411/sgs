# from flask import g
# import json, os
# from old.single_cell_old.parser import matrix_meta_plot_parser
# from path_config import track_folder
# from track.util import abstract_block_util
# from db.dao import chromosome_dao, chr_group_track_block_dao, feature_location_dao, track_dao, chr_group_track_dao
#
# block_gene_count = 100
#
#
#
# def add_block_statistic(session, track_id, chr_genes_dict: dict):
#     for chr_id, gene_locs in chr_genes_dict.items():
#         chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
#         chr_group_track_dao.add_chr_group(session, track_id, chr_id,  None, None, None, None)
#         all_gene_length = 0
#         gene_count = 0
#         for gl in gene_locs:
#             gene_length = int(gl[2]) - int(gl[1])
#             gene_count = gene_count + 1
#             all_gene_length = all_gene_length + gene_length
#         gene_mean_length = all_gene_length // gene_count
#         ref_length = chromosome.seq_length
#         chr_gene_count = len(gene_locs)
#         block_length = (ref_length // chr_gene_count + 1) * block_gene_count
#         block_count = ref_length // block_length + 1
#         chr_group_track_block_dao.add_statistic(session, track_id, chr_id, None, block_count, block_length, gene_count, gene_mean_length, None)
#
#
#
#
#
# def get_expand_block_folder(track_id, chr_name, group_name):
#     expand_block_folder = os.path.join(track_folder, track_id, "block", "expand", chr_name, group_name)
#     if not os.path.exists(expand_block_folder):
#         os.makedirs(expand_block_folder)
#     return expand_block_folder
#
#
#
#
# # response
# # {
# #    "predicted_id": [
# #       {
# #          "gene_name": "pou3f3",
# #          "start": 104854115,
# #          "end": 104858574,
# #          "exp_value": [
# #             0.49034352354698135,
# #             0.7403236931173222,
# #             0.6174910560138338,
# #             0.5580390773933162
# #          ]
# #       }
# #    ]
# # }
#
# def write_block_data(sc_id, track_id, chr_id, chr_name, block_index, block_step, ref_length, group_name):
#     track = track_dao.get_track(g.session, track_id)
#     sc = sc_dao.get_single_cell(g.session, sc_id)
#     group_exp_dict = {}
#     if sc and track:
#         matrix = sc_dao.get_matrix(g.session, track.matrix_id)
#         expression_gene_list = json.loads(matrix.matrix_features)
#         block_start = block_index * block_step
#         block_end = block_start + block_step
#         if block_end >= ref_length:
#             block_end = ref_length
#         gene_locs = feature_location_dao.get_region_features(g.session, chr_id, block_start, block_end, "gene")
#         if len(gene_locs) > 0:
#             block_gene_dict = {}
#             for gl in gene_locs:
#                 if gl.search_name in expression_gene_list:
#                     block_gene_dict[gl.search_name] = [gl.ref_start, gl.ref_end]
#             if len(block_gene_dict.keys()) > 0:
#                 group_gene_dict = matrix_meta_plot_parser.f_median_group_by_column_value(block_gene_dict, group_name, matrix.matrix_meta_plot_file)
#                 genes_express = []
#                 for gene_name, item in group_gene_dict.items():
#                     gep = {"gene_name": gene_name, "start": item.get("start"), "end": item.get("end"), "exp_value": item.get("expression")}
#                     genes_express.append(gep)
#                 group_exp_dict[group_name] = genes_express
#             # write to file and save file path to db
#             group_exp_data_str = json.dumps(group_exp_dict)
#             block_folder = os.path.join(track_folder, track_id, "block", "expand", chr_name, group_name)
#             if not os.path.exists(block_folder):
#                 os.makedirs(block_folder)
#             block_file = abstract_block_util.write_expand_block_file(block_folder, str(block_index), group_exp_data_str)
#             chr_group_track_block_dao.add_block(g.session, track_id, chr_id, None, block_start, block_end, block_index, block_file, "full")
#     return group_exp_dict
#
#
#
#
