# from flask import Blueprint
# from flask import request, g
# from processor import search_processor
# from db.database_init import get_session
# from old.es import es_dao
#
#
#
#
#
# # single_cell = Blueprint("track", __name__, url_prefix="/track")
# search = Blueprint("search", __name__ )
#
#
#
#
# @search.route('/api/es/list_es_index', methods=['POST'])
# def list_es_index():
#     result = {"alias": es_dao.list_all_indexes()}
#     return result
#
#
#
# @search.route('/api/es/whole_index_data', methods=['POST'])
# def get_es_index_data():
#     result = search_processor.get_whole_index_data(request)
#     return result
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
# # single_cell = Blueprint("track", __name__, url_prefix="/track")
# search = Blueprint("search", __name__ )
#
#
#
# @search.route('/api/search/gene', methods=['POST'])
# def search_gene():
#     result = search_processor.search_gene(request)
#     return result
#
#
#
# @search.route('/api/search/track/feature', methods=['POST'])
# def search_feature():
#     result = search_processor.search_features(request)
#     return result
#



