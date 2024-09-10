# from db.dao import feature_location_dao
# import pandas as pd
#
#
#
#
# # gene	1771017030_C09	1771017028_G05	1771052132_B02  1771052132_B03
# # gene-b0001	0	0	0   0
# # gene-b0002	0	0	0   0
# # return chr_gls_dict:  {chr_id: [[gene_name, start, end], []...], ...}
# # todo 改成矩阵运算
# def get_gene_location(session, expression_gene_list, sp_id):
#     chr_gls_dict = {}
#     gls = feature_location_dao.get_f_locations_by_f_names(session, expression_gene_list, sp_id, "gene")
#     for gl in gls:
#         if gl.search_name in expression_gene_list:
#             chr_id = gl.chr_id
#             rec = [gl.search_name, gl.ref_start, gl.ref_end]
#             if chr_id in chr_gls_dict.keys():
#                 chr_gls_dict[chr_id].append(rec)
#             else:
#                 chr_gls_dict[chr_id] = [rec]
#
#     return chr_gls_dict
#
#
#
#
# def get_peak_location(peak_name):
#     peak_loc = str(peak_name).split("-")
#
#     return peak_loc
#
#
#
#
#
#
# # 判断 marker_file 与 meta_file 的哪一列对应(cluster, age ...)
# def get_marker_column(marker_file, cell_meta_columns):
#     meta_marker_colum = ""
#     marker_genes_df = pd.read_csv(marker_file, sep="\t")
#     columns = list(marker_genes_df.columns)
#     for c in columns:
#         if c in cell_meta_columns:
#             meta_marker_colum = c
#             break
#     return meta_marker_colum
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
