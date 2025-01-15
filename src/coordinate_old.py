







# @DeprecationWarning
# def get_feature_coord(anndata, feature_name, coord_key):
#     feature_name_index = anndata.var_names
#     match_f = feature_name_index[feature_name_index == feature_name].tolist()
#     result = {"cell_plot_data": []}
#     if len(match_f) > 0:
#         a_feature = anndata[:, [feature_name]]
#         a_feature_exp = a_feature[a_feature.X > 0]
#         coord = a_feature_exp.obsm[coord_key]
#         cell_name_ndarray = a_feature_exp.obs_names.to_numpy()
#         exp_coord = np.column_stack([a_feature_exp.X.toarray(), coord])
#         cell_exp_coord = np.column_stack([cell_name_ndarray, exp_coord])
#         cell_plot_header = ["cell", coord_key + "_x", coord_key + "_y", "express_value"]
#         result = {"cell_plot_header": cell_plot_header, "cell_plot_data": cell_exp_coord.tolist()}
#     return result


# @DeprecationWarning
# def get_column_coord_old(anndata, sc_mod_id, column_name, coord_key):
#     result = {}
#     mod_db = single_cell_mod_dao.get_single_cell_mod(sc_mod_id)
#     if mod_db:
#         gv_dict = json.loads(mod_db["cell_meta_columns_group_value"])
#         column_group_dict = gv_dict[column_name]
#         if column_group_dict["type"] == "list": #"Cluster": {"type": "list", "value": ["3T3", "Oli-neu_1", ...]}
#             group_values = column_group_dict["value"]
#             header_name = ["cell", coord_key+"_x", coord_key+"_y"]
#             result["cell_plot_header"] = {"group": header_name}
#             cell_plot_data_dict = {}
#             for group_value in group_values:
#                 sub_a = anndata[anndata.obs[column_name] == group_value]
#                 # 坐标矩阵
#                 coord = sub_a.obsm[coord_key]
#                 # 细胞名列
#                 cell_name_ndarray = sub_a.obs_names.to_numpy()
#                 # 连接细胞名列和坐标矩阵
#                 cell_coord = np.column_stack([cell_name_ndarray, coord.tolist()])
#                 cell_plot_data_dict[group_value] = cell_coord.tolist()
#             result["cell_plot_data"] = cell_plot_data_dict
#         elif column_group_dict["type"] == "num": #"gene_count": {"type": "num", "value": [10, 200]}
#             coord = anndata.obsm[coord_key]
#             cell_name_ndarray = anndata.obs_names.to_numpy()
#             column_value = anndata.obs[column_name].values
#             cell_coord = np.column_stack([column_value, coord])
#             cell_coord = np.column_stack([cell_name_ndarray, cell_coord])
#
#             header_name = ["cell", "value", coord_key + "_x", coord_key + "_y"]
#             result["cell_plot_header"] = header_name
#             cell_plot_data = {"scope": column_group_dict["value"], "coord": cell_coord.tolist()}
#             result["cell_plot_data"] = cell_plot_data
#     # sc.pl.spatial(anndata, color="clusters")
#     return result
























