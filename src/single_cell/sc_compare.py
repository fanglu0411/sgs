# # compare模块
#
# from flask import g
# from util import id_util
# import os
# from path_config import sc_image_folder, sc_image_url
# from old.single_cell_old.image import image_type
# import pyarrow.feather as feather
# import numpy as np
# from old.single_cell_old.image.painter import FeaturePainter
# from PIL import Image
# from old.single_cell_old import sc_marker
#
#
# # /static/sc/e265b111c876401da1c51bd01fbc3d98/gene_exp/violin/cluster/image/0099c69d750d4e3aa60fe79f4a88d4cc.jpg
# # /static/sc/image/sc_id/matrix/group_name/view_type/xxx.jpg
# # /static/sc/image/sc_id/matrix/plot_name/group_name/view_type/xxx.jpg
# # /static/sc/image/sc_id/gene_exp/scatter/tsne/xxx.jpg
#
#
#
#
# #request
# # {
# #     "sc_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #     "feature_names": ["gene1", "gene2"],
# #     "matrix_id": "",
# #     "plot_name": "umap"
# # }
# #response
# # {
# #     "scatter": [
# #         {
# #             "feature_name": "gene1",
# #             "image_url": "/static/sc/f68d4448ee314af2b6ff8693effbbe4a/mouse_umap/Cluster/image/3cde90f56c3e4d128d6e558953ff9037.jpg",
# #             "thumb_image_url": "/static/sc/f68d4448ee314af2b6ff8693effbbe4a/mouse_umap/Cluster/image/3cde90f56c3e4d128d6e558953ff9037.thumb.jpg"
# #             "image_id": "3cde90f56c3e4d128d6e558953ff9037"
# #         },
# #         {
# #             "feature_name": "gene2",
# #             "image_url": "",
# #             "thumb_image_url": ""
# #             "image_id": ""
# #         }
# #     ]
# # }
# # 散点图  peak, gene, motif
# def get_scatter_images(request):
#     sc_id = request.json["sc_id"]
#     feature_names = request.json["feature_names"]
#     matrix_id = request.json["matrix_id"]
#     plot_name = request.json["plot_name"]
#     response_images = []
#     for feature_name in feature_names:
#         image = sc_dao.get_feature_image(g.session, sc_id, matrix_id, image_type.scatter, feature_name, plot_name, None, None)
#         if image:
#             image_id = image.id
#             image_url = image.image_url
#             thumb_image_url = image.thumb_image_url
#         else:
#             image_id = id_util.generate_uuid()
#             image_file = str(image_id) + ".jpg"
#             thumb_image_file = str(image_id) + ".thumb.jpg"
#             image_folder = os.path.join(sc_image_folder, sc_id)
#             if not os.path.exists(image_folder):
#                 os.makedirs(image_folder)
#             image_path = os.path.join(image_folder, image_file)
#             thumb_image_path = os.path.join(image_folder, thumb_image_file)
#             image_url = os.path.join(sc_image_url, sc_id, image_file)
#             thumb_image_url = os.path.join(sc_image_url, sc_id, thumb_image_file)
#             sc_dao.add_feature_image(g.session, image_id, sc_id, matrix_id, image_type.scatter, feature_name, None, None, plot_name, image_path, thumb_image_path,
#                                      image_url, thumb_image_url, "adding")
#         response_image = {"image_id": image_id, "feature_name": feature_name, "image_url": image_url, "thumb_image_url": thumb_image_url}
#         response_images.append(response_image)
#     response = {"scatters": response_images}
#     return response
#
#
#
#
# # 初始化 小提琴图, 箱线图, 柱形图, 面积图  通用方法
# def init_group_images(sc_id, feature_names, matrix_id, group_name, image_type):
#     image_dict_list = []
#     response_images = []
#     matrix = sc_dao.get_matrix(g.session, matrix_id)
#     for feature_name in feature_names:
#         search_name = feature_name
#         if matrix.feature_type == "gene":
#             search_name = feature_name.lower()
#         image = sc_dao.get_feature_image(g.session, sc_id, matrix_id, image_type, search_name, None, group_name, None)
#         if image:
#             image_id = image.id
#             image_url = image.image_url
#             thumb_image_url = image.thumb_image_url
#         else:
#             image_id = id_util.generate_uuid()
#             image_file = str(image_id) + ".jpg"
#             image_folder = os.path.join(sc_image_folder, sc_id)
#             image_url = os.path.join(sc_image_url, sc_id, image_file)
#             if not os.path.exists(image_folder):
#                 os.makedirs(image_folder)
#             image_path = os.path.join(image_folder, image_file)
#             thumb_image_file = str(image_id) + ".thumb.jpg"
#             thumb_image_url = os.path.join(sc_image_url, sc_id, thumb_image_file)
#             thumb_image_path = os.path.join(image_folder, thumb_image_file)
#             image_dict = {"id": image_id, "sc_id": sc_id, "image_type": image_type, "feature_name": search_name, "matrix_id": matrix_id, "group_name": group_name,
#                           "image_path": image_path, "thumb_image_path": thumb_image_path, "image_url": image_url, "thumb_image_url": thumb_image_url, "status": "adding"}
#             image_dict_list.append(image_dict)
#         response_image = {"image_id": image_id, "feature_name": feature_name, "image_url": image_url, "thumb_image_url": thumb_image_url}
#         response_images.append(response_image)
#     sc_dao.bulk_feature_images(g.session, image_dict_list)
#     return response_images
#
#
#
#
# #request
# # {
# #     "sc_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #     "feature_names": ["gene1", "gene2"],
# #     "matrix_id": "",
# #     "group": "age"
# # }
# #response
# # {
# #     "violin": [
# #         {
# #             "feature_name": "gene2",
# #             "image_url": "",
# #             "thumb_image_url": ""
# #             "image_id": ""
# #         }
# #     ]
# # }
# # 小提琴图  peak, gene, motif
# def get_violin_images(request):
#     sc_id = request.json["sc_id"]
#     feature_names = request.json["feature_names"]
#     matrix_id = request.json["matrix_id"]
#     group_name = request.json["group_name"]
#     response_images = init_group_images(sc_id, feature_names, matrix_id, group_name, image_type.violin)
#     response = {"violins": response_images}
#     return response
#
#
#
# #request
# # {
# #     "sc_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #     "gene_names": ["gene1", "gene2"],
# #     "matrix_id": "",
# #     "group": "sample"
# # }
# #response
# # {
# #     "box": [
# #         {
# #             "gene_name": "gene2",
# #             "image_url": "",
# #             "thumb_image_url": ""
# #             "image_id": ""
# #         }
# #     ]
# # }
# # 箱线图   peak, gene, motif
# def get_box_images(request):
#     sc_id = request.json["sc_id"]
#     feature_names = request.json["feature_names"]
#     matrix_id = request.json["matrix_id"]
#     group_name = request.json["group_name"]
#     response_images = init_group_images(sc_id, feature_names, matrix_id, group_name, image_type.box)
#     response = {"boxes": response_images}
#     return response
#
#
#
# #request
# # {
# #     "sc_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #     "gene_names": ["gene1", "gene2"],
# #     "matrix_id": "",
# #     "group": "cluster"
# # }
# #response
# # {
# #     "bar": [
# #         {
# #             "gene_name": "gene2",
# #             "image_url": "",
# #             "thumb_image_url": ""
# #             "image_id": ""
# #         },
# #     ]
# # }
# # 柱形图   gene
# def get_bar_images(request):
#     sc_id = request.json["sc_id"]
#     feature_names = request.json["feature_names"]
#     matrix_id = request.json["matrix_id"]
#     group_name = request.json["group_name"]
#     response_images = init_group_images(sc_id, feature_names, matrix_id, group_name, image_type.bar)
#     response = {"bars": response_images}
#     return response
#
#
#
#
# #request
# # {
# #     "sc_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #     "gene_names": ["gene1", "gene2"],
# #     "matrix_id": "",
# #     "group": "cluster"
# # }
# #response
# # {
# #     "bar": [
# #         {
# #             "gene_name": "gene2",
# #             "image_url": "",
# #             "thumb_image_url": ""
# #             "image_id": ""
# #         },
# #     ]
# # }
# # 柱形图 motif
# def get_motif_logo_images(request):
#     sc_id = request.json["sc_id"]
#     motif_names = request.json["feature_names"]
#     matrix_id = request.json["matrix_id"]
#     response_images = init_group_images(sc_id, motif_names, matrix_id, None, image_type.motif_logo)
#     response = {"bars": response_images}
#     return response
#
#
#
#
# #request
# # {
# #     "sc_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #     "feature_names": ["gene1", "gene2"]
# # }
# #response
# # {
# #     "gene_structures": [
# #         {
# #             "feature_name": "gene2",
# #             "chr_id": "",
# #             "start": "",
# #             "end": "",
# #             "strand": "",
# #             "sub_feature": [],
# #             "children": []
# #         },
# #     ]
# # }
# #
# # request
# # {
# #    "sc_id": "e265b111c876401da1c51bd01fbc3d98",
# #    "feature_names": ["cd79a", "ms4a1", "cd79b", "tcl1a", "hla-dqa1", "hla-dqb1", "cd74", "fcer2", "hla-dpb"]
# # }
# def get_gene_structure(request):
#     sc_id = request.json["sc_id"]
#     gene_name_list = request.json["feature_names"]
#     gene_structures = sc_marker.get_gene_structure_view_data(sc_id, gene_name_list)
#     return {"gene_structure": gene_structures, "header": ["view_type", "feature_type", "feature_id", "sgs_id", "feature_name", "start", "end", "strand", "sub_feature", "children"]}
#
#     # return compare_mock.mock_gene_structure(gene_name_list)
#
#
#
#
#
#
# #request
# # {
# #     "sc_id": "f68d4448ee314af2b6ff8693effbbe4a",
# #     "gene_names": ["gene1", "gene2"],
# #     "matrix_id": "",
# #     "group": "cluster"
# # }
# #response
# # {
# #     "heatmap": {
# #             "image_url": "",
# #             "thumb_image_url": ""
# #             "image_id": ""
# #         }
# # }
# # 热图 不存数据库
# # peak, gene, motif
# def get_heatmap_image(request):
#     sc_id = request.json["sc_id"]
#     feature_names = request.json["feature_names"]
#     matrix_id = request.json["matrix_id"]
#     group_name = request.json["group_name"]
#     image_id = id_util.generate_uuid()
#     image_file = str(image_id) + ".jpg"
#     image_folder = os.path.join(sc_image_folder, sc_id)
#     image_url = os.path.join(sc_image_url, sc_id, image_file)
#     if not os.path.exists(image_folder):
#         os.makedirs(image_folder)
#     image_file = os.path.join(image_folder, image_file)
#     thumb_image_file = str(image_id) + ".thumb.jpg"
#     thumb_image_url = os.path.join(sc_image_url, sc_id, thumb_image_file)
#     thumb_image_file = os.path.join(image_folder, thumb_image_file)
#     # sc_dao.add_gene_expression_image(g.session, sc_id, matrix_id, image_type.heatmap, None, group, None, None, image_file, thumb_image_file, image_url, thumb_image_url, "adding")
#
#     # draw image
#     matrix = sc_dao.get_matrix(g.session, matrix_id)
#     cell_column_name = "cell"
#     columns = [cell_column_name]
#     if matrix.feature_type == "gene":
#         lower_feature_names = []
#         for f_name in feature_names:
#             lower_feature_names.append(f_name.lower())
#         feature_names = lower_feature_names
#     columns = columns + feature_names
#     columns.append(group_name)
#
#     # todo is feature_name in matrix
#     df = feather.read_feather(matrix.matrix_meta_plot_file, columns=columns, memory_map=True)
#     df = df.replace(np.nan, 0)
#     p = FeaturePainter()
#     return_code = p.draw_heatmap(df, feature_names, group_name, image_file, "cell")
#     if return_code == 1:
#         im = Image.open(image_file)
#         im.thumbnail((400, 200))
#         im.save(thumb_image_file, "PNG")
#         sc_dao.update_marker_feature_image_status(g.session, image_id, "done")
#         status = "done"
#     else:
#         sc_dao.delete_feature_image(g.session, image_id)
#         status = "error"
#
#     response_image = {"image_id": image_id, "image_url": image_url, "thumb_image_url": thumb_image_url, "status": status }
#     response = {"heatmap": response_image}
#     return response
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
