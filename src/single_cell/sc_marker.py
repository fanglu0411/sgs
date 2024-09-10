# import json
# from old.single_cell_old.image.painter import FeaturePainter
# from PIL import Image
# from flask import g
# from db.dao import track_dao, chromosome_dao, chr_group_track_dao
# import numpy as np
# import pyarrow.feather as feather
# # from multiprocessing import Pool, cpu_count
# from old.single_cell_old.image import image_type
# from old.single_cell_old.atac import group_coverage
# from track.track_type import group_coverage_view, motif_view
# from track.util import track_util
# from db.dao import feature_location_dao
# from track.single.gff import gff_chr_matrix
# from track.single.gff.parser import record2dict
#
#
#
#
# # {
# #      sc_id = request.json["sc_id"]
# #     "track_id": "434f0cae5add44de9fe893432485ac0c",
# #     "matrix_id": "218bb7c332134eaab1affd5618b47bbf",
# #     "chr_name": "chr17",
# #     "ref_start": 80084294,
# #     "ref_end": 80085275,
# #     "group_name": "predicted_id",
# #     "feature_name": "chr17-80084294-80085275",
# #     "level": 3
# # }
# def get_group_coverage_view_data(request):
#     track_id = request.json["track_id"]
#     sc_id = request.json["sc_id"]
#     matrix_id = request.json["matrix_id"]
#     peak_name = request.json["feature_name"]
#     group_name = request.json["group_name"]
#     chr_name = request.json["chr_name"]
#     group_coverage_data = sc_dao.get_feature_data(g.session, track_id, matrix_id, group_coverage_view, peak_name, None, group_name, None)
#     if group_coverage_data:
#         response = json.loads(group_coverage_data.view_data)
#     else:
#         track = track_dao.get_track(g.session, track_id)
#         chr_db_search_name = track_util.get_chr_search_name(chr_name)
#         chromosome = chromosome_dao.get_chromosome_by_search_name(track.species_id, chr_db_search_name)
#         request.json["chr_id"] = chromosome.id
#         ref_start = request.json["ref_start"]
#         ref_end = request.json["ref_end"]
#         level = str(request.json["level"])
#         histo_count = None
#         if "histo_count" in request.json:
#             histo_count = request.json["histo_count"]
#         stats_type = None
#         if "stats_type" in request.json:
#             stats_type = request.json["stats_type"]
#         # track_id, chr_id, ref_start, ref_end, group_name, level, group_values, histo_count, stats_type
#         response = group_coverage.get_group_coverage_data(track_id, chromosome.id, ref_start, ref_end, group_name, level, None, histo_count, stats_type)
#         data_str = json.dumps(response)
#         sc_dao.add_feature_data(g.session, sc_id, track_id, matrix_id, peak_name, group_name, None, None, group_coverage_view, data_str, "done")
#     return response
#
#
#
#
# def get_marker_feature_image(request):
#     image_id = request.json["image_id"]
#     matrix_id = request.json["matrix_id"]
#     image = sc_dao.get_image_by_id(g.session, image_id)
#
#     if image:
#         if image.status == "adding":
#             p = FeaturePainter()
#             matrix = sc_dao.get_matrix(g.session, matrix_id)
#             feature_name = str(image.feature_name).lower()
#             if matrix.feature_type == "gene":
#                 feature_name = feature_name.lower()
#             return_code = 0
#             # scatter, box, heatmap, violin, bar, gene_structure, peak, group_coverage
#             if image.image_type == image_type.scatter:
#                 x_column_name = image.tags + "_x"
#                 y_column_name = image.tags + "_y"
#                 df = feather.read_feather(matrix.matrix_meta_plot_file, columns=[feature_name, x_column_name, y_column_name], memory_map=True)
#                 df = df.replace(np.nan, 0)
#                 df[x_column_name] = df[x_column_name].astype("float")
#                 df[y_column_name] = df[y_column_name].astype("float")
#                 return_code = p.draw_scatter(df, feature_name, x_column_name, y_column_name, image)
#             elif image.image_type == image_type.violin:
#                 df = feather.read_feather(matrix.matrix_meta_plot_file, columns=[feature_name, image.group_name], memory_map=True)
#                 df = df.replace(np.nan, 0)
#                 return_code = p.draw_violin(df, image.feature_name, image.group_name, image)
#             elif image.image_type == image_type.box:
#                 df = feather.read_feather(matrix.matrix_meta_plot_file, columns=[feature_name, image.group_name], memory_map=True)
#                 df = df.replace(np.nan, 0)
#                 return_code = p.draw_box(df, image.feature_name, image.group_name, image)
#             elif image.image_type == image_type.bar:
#                 df = feather.read_feather(matrix.matrix_meta_plot_file, columns=[feature_name, image.group_name], memory_map=True)
#                 # df = feather.read_feather(matrix.matrix_meta_plot_file, memory_map=True)
#                 # print(df.columns)
#                 df = df.replace(np.nan, 0)
#                 return_code = p.draw_bar(df, image.feature_name, image.group_name, image)
#             elif image.image_type == image_type.motif_logo:
#                 motif_view_data = sc_dao.get_feature_data(g.session, None, image.matrix_id, motif_view, image.feature_name, None, None, None)
#                 motif_view_data_str = motif_view_data.view_data
#                 motif_view_data_dict = json.loads(motif_view_data_str)
#                 return_code = p.draw_motif_logo(motif_view_data_dict, image)
#
#             if return_code == 1:
#                 im = Image.open(image.image_path)
#                 im.thumbnail((400, 200))
#                 im.save(image.thumb_image_path, "PNG")
#                 sc_dao.update_marker_feature_image_status(g.session, image.id, "done")
#             else:
#                 sc_dao.delete_feature_image(g.session, image.id)
#
#         rs = {"status": image.status, "image_url": image.image_url, "thumb_image_url": image.thumb_image_url}
#     else:
#         rs = {"result": "no image error"}
#     return rs
#
#
#
# def get_features_images(request):
#     image_ids = request.json["image_ids"]
#     images = []
#     result = {"result": images}
#     records = sc_dao.get_image_by_ids(g.session, image_ids)
#     if records:
#         for record in records:
#             image = {"status": record.status, "image_url": record.image_url, "thumb_image_url": record.thumb_image_url}
#             images.append(image)
#     else:
#         return {"result": "no images"}
#     return result
#
#
#
#
#
# def get_gene_structure_view_data(sc_id, gene_names):
#     gene_structures = []
#     sc = sc_dao.get_single_cell(g.session, sc_id)
#     gff_track = None
#     for gene_name in gene_names:
#         gl = feature_location_dao.get_sp_f_location(g.session, gene_name, sc.species_id, "gene")
#         if gl:
#             if not gff_track:
#                 gff_track = track_dao.get_track(g.session, gl.track_id)
#             if gff_track:
#                 chr_group = chr_group_track_dao.get_chr_group(g.session, gff_track.id, gl.chr_id, None)
#                 if chr_group:
#                     records = gff_chr_matrix.get_block_records_from_feather_file(gl.track_id, gl.chr_id, gl.ref_start, gl.ref_end)
#                     feature_view_array = record2dict.get_records_view_data(records)
#                     for fv in feature_view_array:
#                         # print(fv[3])
#                         if fv[3] == gene_name:
#                             gene_structures.append(fv)
#     return gene_structures
#
#
#
#
#
#
# # return  page_count, page_marker_df
# def page_marker_df(marker_df, page_num, page_size):
#     rec_count = int(marker_df.shape[0])
#     start_index = page_num * page_size
#     end_index = start_index + page_size
#     page_marker_df = marker_df.iloc[start_index: end_index]
#     return page_marker_df, rec_count
#
#
#
#
#
#
#
#
