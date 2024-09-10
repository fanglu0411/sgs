# from flask import Blueprint
# from flask import request, g
# from db.database_init import get_session
# from single_cell_old import sc_compare
#
#
#
#
# compare = Blueprint("compare", __name__ )
#
#
#
# @compare.route("/api/sc/compare/gene_structure", methods=["post"])
# def sc_gene_structure():
#     # try:
#     g.session = get_session()
#     result = sc_compare.get_gene_structure(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
#
# @compare.route("/api/sc/compare/scatter", methods=["post"])
# def sc_scatter():
#     # try:
#     g.session = get_session()
#     result = sc_compare.get_scatter_images(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
#
# @compare.route("/api/sc/compare/violin", methods=["post"])
# def sc_violin():
#     # try:
#     g.session = get_session()
#     result = sc_compare.get_violin_images(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
#
# @compare.route("/api/sc/compare/box", methods=["post"])
# def sc_box():
#     # try:
#     g.session = get_session()
#     result = sc_compare.get_box_images(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
#
# @compare.route("/api/sc/compare/bar", methods=["post"])
# def sc_bar():
#     # try:
#     g.session = get_session()
#     result = sc_compare.get_bar_images(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
# @compare.route("/api/sc/compare/motif", methods=["post"])
# def sc_motif_logo():
#     g.session = get_session()
#     result = sc_compare.get_motif_logo_images(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#
#
#
# @compare.route("/api/sc/compare/heatmap", methods=["post"])
# def sc_heatmap():
#     # try:
#     g.session = get_session()
#     result = sc_compare.get_heatmap_image(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
#
#
#
#
#
#
