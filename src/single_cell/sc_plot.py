# # 散点图模块
#
# from flask import g
# from single_cell.parser import matrix_meta_plot_parser
#
#
#
#
#
# # request
# # {
# #     "sc_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #     "group_name": "Cluster",
# #     "plot_name": "mouse_umap"
# # }
# # response
# # {
# #     "cell_plot_data": {
# #         "3T3": [
# #             [
# #                 "H3K27me3_cell_lines_1_AAACGAACACAGCTTA-1",
# #                 6113.0,
# #                 17997.0
# #             ]
# #     },
# #     "cell_plot_header": {
# #         "group": [
# #             "cell",
# #             "mouse_umap_x",
# #             "mouse_umap_y"
# #         ]
# #     }
# # }
# # get one column plot group by column values
# def get_column_cell_plot(request):
#     result = {"result": "no single cell"}
#     sc_id = request.json["sc_id"]
#     plot_name = request.json["plot_name"]
#     group_name = request.json["group_name"]
#     sc = sc_dao.get_single_cell(g.session, sc_id)
#     matrix_list = sc_dao.get_sc_matrix(g.session, sc_id)
#     if sc and matrix_list:
#         matrix0 = matrix_list[0]
#         result = matrix_meta_plot_parser.column_cells_plot(sc, group_name, plot_name, matrix0.matrix_meta_plot_file)
#     return result
#
#
#
# # request
# # {
# #     "sc_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #     "feature_name": "",
# #     "plot_name": "mouse_umap"
# # }
# # response
# # {
# #     "cell_plot_data": {
# #         "3T3": [
# #             [
# #                 "H3K27me3_cell_lines_1_AAACGAACACAGCTTA-1",
# #                 6113.0,
# #                 17997.0
# #             ]
# #     },
# #     "cell_plot_header": {
# #         "group": [
# #             "cell",
# #             "mouse_umap_x",
# #             "mouse_umap_y"
# #         ]
# #     }
# # }
# def get_feature_cell_plot(request):
#     result = {"result": "no single cell"}
#     matrix_id = request.json["matrix_id"]
#     plot_name = request.json["plot_name"]
#     feature_name = request.json["feature_name"]
#     matrix = sc_dao.get_matrix(g.session, matrix_id)
#     if matrix:
#         result = matrix_meta_plot_parser.feature_cell_plot(matrix, plot_name, feature_name)
#     return result
#
#
#
#
#
#
#
#
