# import json
# from flask import g
# from db.dao import track_dao
# from single_cell_old.trans import sc_transcript
# from single_cell_old.atac import sc_atac
#
#
# # /home/sgs/data/sc/sc_id/image 映射成flask静态路径
# # /home/sgs/data/sc/sc_id/all_info_file
#
#
#
# # sc_type = transcript, atac ...
# def create_new_sc(request):
#     sc_type = "transcript"
#     if "sc_type" in request.json:
#         sc_type = request.json["sc_type"]
#     response = {}
#     if sc_type == "transcript":
#         response = sc_transcript.create_new_sc_from_file(request)
#     elif sc_type == "atac":
#         # todo
#         response = sc_atac.create_new_sc_from_file(request)
#     return response
#
#
#
# def complete_sc(request):
#     sc_type = request.json["sc_type"]
#     response = {}
#     if sc_type == "transcript":
#         response = sc_transcript.complete_sc_from_file(request)
#     elif sc_type == "atac":
#         # todo
#         response = sc_atac.complete_sc_from_file(request)
#     return response
#
#
#
# # {
# #     "sc_list": [
# #         {
# #             "cell_groups": {
# #                 "Cluster": [
# #                     "3T3",
# #                     "Oli-neu_1"
# #                 ]
# #             },
# #             "plots": [
# #                 "mouse_umap",
# #                 "mouse_lsi"
# #             ],
# #             "sc_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #             "sc_name": "23k",
# #             "status": "done",
# #             "track_id": "67445fe9e65a4c07a72c6996d502f834",
# #             "track_name": "23k expression",
# #             "matrix_list": [{"name": "", "id": ""}, {"name": "", "id": ""}]
# #         }
# #     ]
# # }
# def list_species_single_cells(request):
#     species_id = request.json["species_id"]
#     sc_list = []
#     track_name = ""
#     scs = sc_dao.get_species_single_cells(g.session, species_id)
#     for sc in scs:
#         if sc.status == "done":
#             all_meta_columns_groupby = json.loads(sc.all_meta_columns_groupby)
#             select_meta_columns = json.loads(sc.select_meta_columns)
#             select_meta_columns_groupby = {}
#             for c in select_meta_columns:
#                 select_meta_columns_groupby[c] = all_meta_columns_groupby.get(c)
#             sc_track = track_dao.get_track(g.session, sc.track_id)
#             if sc_track:
#                 track_name = sc_track.name
#             plots = sc_dao.get_cell_plots(g.session, sc.id)
#             plot_names = []
#             for plot in plots:
#                 plot_names.append(plot.name)
#             matrix_entries = sc_dao.get_sc_matrix(g.session, sc.id)
#             matrix_list = []
#             for m in matrix_entries:
#                 matrix_list.append({"name": m.name, "id": m.id})
#             sc_info = {"sc_id": sc.id, "sc_name": sc.name, "track_id": sc.track_id, "track_name": track_name, "plots": plot_names,
#                        "cell_groups": select_meta_columns_groupby, "status": sc.status, "matrix_list": matrix_list}
#             sc_list.append(sc_info)
#         else:
#             sc_info = {"sc_id": sc.id, "sc_name": sc.name, "track_id": sc.track_id, "track_name": track_name, "status": sc.status}
#             sc_list.append(sc_info)
#     result = {"sc_list": sc_list}
#     return result
#
#
#
#
# def get_track_single_cell(sc):
#     sc_info = {"sc_id": sc.id}
#     if sc.all_meta_columns_groupby:
#         all_meta_columns_groupby = json.loads(sc.all_meta_columns_groupby)
#         select_meta_columns = json.loads(sc.select_meta_columns)
#         select_meta_columns_groupby = {}
#         for c in select_meta_columns:
#             select_meta_columns_groupby[c] = all_meta_columns_groupby.get(c)
#         plots = sc_dao.get_cell_plots(g.list_session, sc.id)
#         plot_names = []
#         for plot in plots:
#             plot_names.append(plot.name)
#         matrix_entries = sc_dao.get_sc_matrix(g.list_session, sc.id)
#         matrix_list = []
#         for m in matrix_entries:
#             matrix_list.append({"name": m.name, "id": m.id, "type": m.feature_type})
#         sc_info = {"sc_id": sc.id, "sc_name": sc.name, "plots": plot_names, "sc_type": sc.sc_type, "cell_groups": select_meta_columns_groupby, "status": sc.status, "matrix_list": matrix_list}
#
#     return sc_info
#
#
#
#
#
#
#
#
