# # conda install -c conda-forge pandas
# # pip install feather-format or  conda install -c conda-forge feather-format
# import json
# import pyarrow.feather as feather
# import pandas as pd
# from flask import g
#
#
#
#
#
# # group_dict:  {"column_name": [column_values]}
# def group_by_column_values(cell_meta_df):
#     group_dict = {}
#     columns = list(cell_meta_df.columns)
#     for column in columns:
#         if cell_meta_df[column].dtype.name == "float64":
#             cell_meta_df.dropna(subset=[column], inplace=True)
#             vv = cell_meta_df[column].astype("int").drop_duplicates()
#             vv = vv.apply(str)
#         elif cell_meta_df[column].dtype.name == "int64":
#             cell_meta_df.dropna(subset=[column], inplace=True)
#             vv = cell_meta_df[column].drop_duplicates()
#             vv = vv.apply(str)
#         #     todo 统一处理各种类型
#         elif cell_meta_df[column].dtype.name == "int32":
#             cell_meta_df.dropna(subset=[column], inplace=True)
#             vv = cell_meta_df[column].drop_duplicates()
#             vv = vv.apply(str)
#         else:
#             cell_meta_df.dropna(subset=[column], inplace=True)
#             vv = cell_meta_df[column].drop_duplicates()
#         vv = vv.sort_values()
#         gv = vv.values
#         group_dict[column] = list(gv)
#     return group_dict
#
#
#
#
# def merge_cell_meta_plot(cell_plot_file_map, cell_meta_file, cell_feature_file, matrix_meta_plot_file, cell_meta_columns):
#     feature_list = []
#     if len(cell_plot_file_map.keys()) > 0:
#         # merge plot files
#         plot_df = None
#         plot_file_count = 0
#         plot_column_names = []
#         for plot_name, plot_file in cell_plot_file_map.items():
#             x_column_name = plot_name + "_x"
#             y_column_name = plot_name + "_y"
#             cell_column_name = plot_name + "_cell"
#             plot_column_names.append(x_column_name)
#             plot_column_names.append(y_column_name)
#             if plot_file_count == 0:
#                 plot_df = pd.read_csv(plot_file, sep="\t", names=["cell", x_column_name, y_column_name])
#                 plot_df = plot_df.sort_values(by="cell")
#             else:
#                 plot2_df = pd.read_csv(plot_file, sep="\t", names=[cell_column_name, x_column_name, y_column_name])
#                 plot2_df = plot2_df.sort_values(by=cell_column_name)
#                 # plot2_df = plot2_df[[x_column_name, y_column_name]]
#                 plot_df = plot_df.merge(plot2_df, left_on='cell', right_on=cell_column_name, how="left") # todo left or outer
#             plot_file_count = plot_file_count + 1
#
#         # merge meta file
#         cell_meta_df = pd.read_csv(cell_meta_file, sep="\t", index_col=0)
#         meta_file_columns = list(cell_meta_df.columns)
#         select_columns = []
#         for c in cell_meta_columns:
#             if c in meta_file_columns:
#                 select_columns.append(c)
#         cell_meta_df = cell_meta_df.sort_index()
#         cell_meta_df = cell_meta_df[select_columns]
#         all_info_df = plot_df.merge(cell_meta_df, left_on='cell', right_index=True, how="inner")
#
#         # merge feature file
#         cell_feature_df = pd.read_csv(cell_feature_file, sep="\t", index_col=0)
#         cell_feature_df = cell_feature_df.T
#         cell_feature_df.columns = cell_feature_df.columns.map(lambda x:x.lower())
#         cell_feature_df = cell_feature_df.loc[:, ~cell_feature_df.columns.duplicated()]
#         cell_feature_df = cell_feature_df.sort_index()
#         feature_list = list(cell_feature_df.columns)
#         all_info_df = all_info_df.merge(cell_feature_df, left_on='cell', right_index=True, how="inner")
#
#         # # merge expression files
#         # # exp_df = pd.read_csv(exp_file, sep="\t", index_col=0)
#         # table = csv.read_csv(exp_file)
#         # exp_df = table.to_pandas()
#         # # exp_df = csv.read_csv(exp_file)
#         # exp_df = exp_df.T
#         # exp_df = exp_df.sort_index()
#         # expression_gene_list = list(exp_df.columns)
#         # all_info_df = all_info_df.merge(exp_df, left_on='cell', right_index=True, how="inner")
#
#         all_info_df.index.name = "cell"
#         feather.write_feather(all_info_df, matrix_meta_plot_file)
#
#     return feature_list
#
#
#
# def column_cells_plot(sc, column_name, plot_name, cell_all_info_file):
#     select_columns = json.loads(sc.select_meta_columns)
#     x_plot_column = plot_name+ "_x"
#     y_plot_column = plot_name + "_y"
#     if column_name in select_columns:
#         target_columns = ["cell", x_plot_column, y_plot_column, column_name]
#         cells_plot_df = feather.read_feather(cell_all_info_file, columns=target_columns, memory_map=True)
#         group_cell_plot_data = {}
#         cells_plot_df = cells_plot_df.dropna()
#         # cells_plot.dropna(subset=[group_name], inplace=True)
#         # cells_plot.dropna(subset=[x_plot_column], inplace=True)
#         # cells_plot.dropna(subset=[y_plot_column], inplace=True)
#         # 遇到浮点数,取整去零
#         if cells_plot_df[column_name].dtype.name == "int":
#             cells_plot_df[column_name] = cells_plot_df[column_name].apply(str)
#         elif cells_plot_df[column_name].dtype.name == "float64":
#             cells_plot_df[column_name] = cells_plot_df[column_name].astype("int")
#             cells_plot_df[column_name] = cells_plot_df[column_name].apply(str)
#
#
#         # 如果 xtt 那边过来的不是float类型
#         cells_plot_df[x_plot_column] = cells_plot_df[x_plot_column].astype("float")
#         cells_plot_df[y_plot_column] = cells_plot_df[y_plot_column].astype("float")
#
#         cell_plot_pd = cells_plot_df.T
#         cells_plot_dict = cell_plot_pd.to_dict()
#         for item in cells_plot_dict.values():
#             group = item.get(column_name)
#             if group in group_cell_plot_data.keys():
#                 group_cell_plot_data[group].append([item.get("cell"), item.get(x_plot_column), item.get(y_plot_column)])
#             else:
#                 group_cell_plot_data[group] = [[item.get("cell"), item.get(x_plot_column), item.get(y_plot_column)]]
#         cell_plot_header = {"group": ["cell", x_plot_column, y_plot_column]}
#         return {"cell_plot_header": cell_plot_header, "cell_plot_data": group_cell_plot_data}
#     else:
#         return {"result": "no x, y column"}
#
# # group_cells_plot("cell_class", "VLMC", "/home/sgs/data/test/ecoli_merge.h5")
#
#
#
#
# def feature_cell_plot(matrix, plot_name, feature_name):
#     gene_cell_plot_data = []
#     x_plot_column = plot_name + "_x"
#     y_plot_column = plot_name + "_y"
#     feature_name = feature_name.lower()
#
#     feature_list = json.loads(matrix.matrix_features)
#     if not feature_name in feature_list:
#         return {"result": "no feature in this matrix"}
#     df = feather.read_feather(matrix.matrix_meta_plot_file, columns=[feature_name, "cell", x_plot_column, y_plot_column], memory_map=True)
#     columns = list(df.columns)
#     if feature_name in columns:
#         a = df.loc[df[feature_name] > 0]
#         exp_df = a[["cell", x_plot_column, y_plot_column, feature_name]]
#         exp_df[x_plot_column] = exp_df[x_plot_column].astype("float")
#         exp_df[y_plot_column] = exp_df[y_plot_column].astype("float")
#         exp_df = exp_df.T
#         exp_dict = exp_df.to_dict()
#         for itm in exp_dict.values():
#             gene_cell_plot_data.append([itm.get("cell"), itm.get(x_plot_column), itm.get(y_plot_column), itm.get(feature_name)])
#         cell_plot_header = ["cell", x_plot_column, y_plot_column, "express_value"]
#         return {"cell_plot_header": cell_plot_header, "cell_plot_data": gene_cell_plot_data}
#     else:
#         return {"result": "no feature"}
#
#
#
#
#
#
#
# # request
# # block_f_dict: {"gene1": [start, end]}
#
# # matrix_meta_plot_file
# # cluster    gene-b0002  gene-b0004
# # COP                  0           0
# # MFOL1                0           0
#
# # response
# # result: {"gene1": {"start": 1, "end": 100, "expression": [0, 1, 9]} }
# def f_median_group_by_column_value(block_f_dict, group_name, matrix_meta_plot_file):
#     result = {}
#     df = feather.read_feather(matrix_meta_plot_file, memory_map=True)
#     # df = DataFrame(pd.read_hdf(cell_all_info_file, index_col=0))
#     columns = list(df.columns)
#     # {feature_name: [start, end]}
#     f_dict = {}
#     match_f_columns = []
#     for c in columns:
#         if c in block_f_dict.keys():
#             f_dict[c] = block_f_dict.get(c)
#             match_f_columns.append(c)
#     r = df.groupby([group_name])
#     group_f_matrix = r[match_f_columns].median()
#     # group_value = list(group_gene_matrix.index)
#     for f_name, loc in f_dict.items():
#         start = loc[0]
#         end = loc[1]
#         group_exp = group_f_matrix[f_name]
#         # {"start": 1, "end": 1000, "expression": [0, 0, 0]}
#         result[f_name] = {"start": start, "end": end, "expression": list(group_exp)}
#
#     return result
#
#
#
#
#
#
#
