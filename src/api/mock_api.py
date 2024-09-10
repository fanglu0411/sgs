# from flask import Blueprint
# from flask import request, g
# from db.database_init import get_session
# from old.data_mock.processor import atac_track_mock
#
# mock_data = Blueprint("mock_data", __name__ )
#
#
#
#
#
#
#
# @mock_data.route("/api/mock/sc/atac/table", methods=["post"])
# def atac_table():
#     # try:
#     g.session = get_session()
#     result = atac_track_mock.get_table(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
#
# @mock_data.route("/api/mock/track/sc/atac/express", methods=["post"])
# def atac_express():
#     # try:
#     g.session = get_session()
#     result = atac_track_mock.get_group_express(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
#
# @mock_data.route("/api/mock/track/sc/atac/peak_co_access", methods=["post"])
# def atac_peak_co_access():
#     # try:
#     g.session = get_session()
#     result = atac_track_mock.get_peak_co_access(request)
#     if g.session is not None:
#         g.session.remove()
#     return result
#     # except Exception as e:
#     #     return json.dumps({"error": str(e)}), 404
#
#
# @mock_data.route("/api/mock/track/sc/atac/peak_coverage_group", methods=["post"])
# def atac_peak_coverage_group():
#     # try:
#     g.session = get_session()
#     result = atac_track_mock.get_coverage_group(request)
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
#
#
