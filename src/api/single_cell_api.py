# from flask import Blueprint
# from flask import request, g
# from db.database_init import get_session
# from single_cell import sc_plot, sc_meta
# from single_cell.trans import sc_transcript, gene_exp_matrix
# from single_cell.atac import sc_atac, peak_matrix, motif_matrix
# from processor import sc_track_processor, sc_processor_old
# from single_cell import sc_marker
#
#
#
#
#
#
# single_cell = Blueprint("single_cell", __name__ )
#
#
#
#
# @single_cell.route("/api/sc/add/new/transcript", methods=["post"])
# def new_sc_transcript():
#     # try:
#     g.session = get_session()
#     result = sc_transcript.create_new_sc_from_file(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
# @single_cell.route("/api/sc/add/complete/transcript", methods=["post"])
# def commit_sc_transcript():
#     # try:
#     g.session = get_session()
#     result = sc_transcript.complete_sc_from_file(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
# @single_cell.route("/api/sc/add/seurat", methods=["post"])
# def create_sc_from_seurat():
#     # try:
#     g.session = get_session()
#     result = sc_transcript.create_sc_from_seurat(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
# # todo
# @single_cell.route("/api/sc/add/new/atac", methods=["post"])
# def new_sc_atac():
#     # try:
#     g.session = get_session()
#     result = sc_atac.create_new_sc_from_file(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
# # todo
# @single_cell.route("/api/sc/add/complete/atac", methods=["post"])
# def commit_sc_atac():
#     # try:
#     g.session = get_session()
#     result = sc_atac.complete_sc_from_file(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
# @single_cell.route("/api/sc/add/signac", methods=["post"])
# def create_sc_from_signac():
#     # try:
#     g.session = get_session()
#     result = sc_atac.create_sc_from_signac(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
#
# # get all cell meta column selected info
# @single_cell.route("/api/sc/cell/column/all", methods=["post"])
# def column_selected_info():
#     # try:
#     g.session = get_session()
#     result = sc_meta.get_column_selected_info(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
# # list all sc of this species
# @single_cell.route("/api/sc/list", methods=["post"])
# def list_species_sc():
#     # try:
#     g.session = get_session()
#     result = sc_processor_old.list_species_single_cells(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
#
# # get cell plots by 降维方式(tsne, umap) and group by group value
# @single_cell.route("/api/sc/cell/group", methods=["post"])
# def group_cell_plot():
#     # try:
#     g.session = get_session()
#     result = sc_plot.get_column_cell_plot(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
# # 某个基因的表达分布
# @single_cell.route("/api/sc/cell/feature", methods=["post"])
# def feature_cell_plot():
#     # try:
#     g.session = get_session()
#     result = sc_plot.get_feature_cell_plot(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
# # search gene location by gene name
# @single_cell.route("/api/sc/gene/search", methods=["post"])
# def get_gene_location():
#     g.session = get_session()
#     result = sc_track_processor.get_gene_location(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#
#
#
# # search peak location by peak name
# @single_cell.route("/api/sc/peak/search", methods=["post"])
# def get_peak_location():
#     g.session = get_session()
#     # todo
#     result = sc_track_processor.get_peak_location(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#
#
#
# # get marker gene table that group_name == group_value
# @single_cell.route("/api/sc/marker/gene/table", methods=["post"])
# def marker_gene_table():
#     g.session = get_session()
#     result = gene_exp_matrix.marker_gene_table(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#
#
#
# @single_cell.route("/api/sc/marker/peak/table", methods=["post"])
# def marker_peak_table():
#     g.session = get_session()
#     result = peak_matrix.marker_peak_table(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#
#
#
# @single_cell.route("/api/sc/marker/motif/table", methods=["post"])
# def marker_motif_table():
#     g.session = get_session()
#     result = motif_matrix.marker_motif_table(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#
#
#
#
# # get marker gene image (scatter, box, heatmap, violin, bar, gene_structure ... )
# @single_cell.route("/api/sc/marker/feature/image", methods=["post"])
# def marker_feature_image():
#     g.session = get_session()
#     result = sc_marker.get_marker_feature_image(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#
#
#
#
# # get image drawing status
# @single_cell.route("/api/sc/marker/features/images", methods=["post"])
# def marker_features_images():
#     g.session = get_session()
#     result = sc_marker.get_features_images(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#
#
#
# # get meta info of this group value
# @single_cell.route("/api/sc/cluster/meta", methods=["post"])
# def cluster_meta_table():
#     g.session = get_session()
#     result = sc_meta.get_column_value_meta_table(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#
#
#
#
#
# @single_cell.route("/api/sc/marker/peak/data", methods=["post"])
# def marker_peak_view_data():
#     g.session = get_session()
#     result = sc_marker.get_group_coverage_view_data(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#
#
#
#
#
# @single_cell.route("/api/sc/delete", methods=["post"])
# def delete_sc():
#     g.session = get_session()
#     sc_id = request.json["sc_id"]
#     result = sc_track_processor.delete_single_cell(sc_id)
#     if g.session is not None:
#         g.session.remove()
#     return result
#
#
#
#
#
#
#
#
