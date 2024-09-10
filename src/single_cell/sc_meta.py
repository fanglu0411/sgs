# import json
# from flask import g
# import pyarrow.feather as feather
#
#
#
#
# # request
# # {
# #     "sc_id": "f68d4448ee314af2b6ff8693effbbe4a"
# # }
# # response
# # {
# #  "cell_meta_columns": {
# #      "Cell": "n",
# #      "Cluster": "y"}
# #   }
# def get_column_selected_info(request):
#     cell_meta_columns = {}
#     sc_id = request.json["sc_id"]
#     sc = sc_dao.get_single_cell(g.session, sc_id)
#     if sc:
#         select_meta_columns = json.loads(sc.select_meta_columns)
#         all_meta_columns = json.loads(sc.meta_columns)
#         for c in all_meta_columns:
#             if c in select_meta_columns:
#                 cell_meta_columns[c] = "y"
#             else:
#                 cell_meta_columns[c] = "n"
#     result = {"cell_meta_columns": cell_meta_columns}
#     return result
#
#
#
#
# default_cluster_column_name = ["cluster", "cell_class"]
#
# # request
# # {
# #     "sc_id": "",
# #     "matrix_id": "",
# #     "cluster": "3T3"
# # }
# # response
# # {
# #     "cluster_info": [
# #         [
# #             "3T3",
# #             "18",
# #             "H3K27me3_cell_lines_1"
# #         ]
# #     ],
# #     "header": [
# #         "Cluster",
# #         "age",
# #         "sample"
# #     ]
# # }
# def get_column_value_meta_table(request):
#     sc_id = request.json["sc_id"]
#     matrix_id = request.json["matrix_id"]
#     group_name = request.json["group_name"]
#     group_value = request.json["group_value"]
#
#     cluster_info = []
#     meta_columns = []
#     single_cell = sc_dao.get_single_cell(g.session, sc_id)
#     if single_cell:
#         matrix = sc_dao.get_matrix(g.session, matrix_id)
#         if matrix:
#             select_meta_columns = json.loads(single_cell.select_meta_columns)
#             cell_meta_df = feather.read_feather(matrix.matrix_meta_plot_file, columns=select_meta_columns, memory_map=True)
#             cell_meta_df = cell_meta_df.dropna()
#             cluster_df = cell_meta_df[cell_meta_df[group_name] == group_value]
#             # cluster_df = cluster_df.T
#             cluster_info = cluster_df.values.tolist()
#             meta_columns = select_meta_columns
#
#     return {"header": meta_columns, "cluster_info": cluster_info}
#
#
#
#
#
