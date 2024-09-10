# import numpy as np
# import pandas as pd
#
# # conda install -c conda-forge seaborn
# import seaborn as sns
# import matplotlib.pyplot as plt
# from old.single_cell_old.image.painter_util import random_color
#
# # pip install dmslogo
# import dmslogo
# from matplotlib.ticker import MultipleLocator
# import traceback
#
#
#
#
# class FeaturePainter(object):
#
#     def __init__(self):
#         pass
#
#
#     @staticmethod
#     def draw_scatter(df, feature_name, x_column_name, y_column_name, image):
#         try:
#             fig, ax = plt.subplots()
#             scat = ax.scatter(df[x_column_name], df[y_column_name], marker='.', c=df[feature_name], cmap='Purples', s=8)
#             ax.set_title(feature_name.upper(), fontweight="bold", fontname="Times New Roman", fontsize=16)
#             ax.spines['right'].set_color('none')
#             ax.spines['top'].set_color('none')
#             ax.set_ylabel(y_column_name, fontweight="bold", fontname="Times New Roman", fontsize=11)
#             ax.set_xlabel(x_column_name, fontweight="bold", fontname="Times New Roman", fontsize=11)
#             ax.yaxis.set_label_coords(0.081, 0.5, transform=fig.transFigure)
#             fig.colorbar(scat, shrink=0.2, aspect=5)
#             fig.subplots_adjust(right=1.03)
#             fig.savefig(image.image_path, dpi=300)
#             plt.close(fig)
#             return 1
#         except Exception as e:
#             traceback.print_exc()
#             return 0
#
#
#     @staticmethod
#     def draw_violin(df, feature_name, cluster_name, image):
#         try:
#             fig, ax = plt.subplots()
#             sns.violinplot(x=df[cluster_name], y=df[feature_name], width=1, ax=ax)  # palette="Pastel1"
#             ax.set_ylabel('')
#             ax.set_xlabel('')
#             ax.spines['right'].set_color('none')
#             ax.spines['top'].set_color('none')
#             ax.set_title(feature_name.upper(), fontweight="bold", fontname="Times New Roman", fontsize=16)
#             fig.autofmt_xdate(bottom=0.3, rotation=60)
#             fig.subplots_adjust(right=0.95, left=0.08)
#             fig.savefig(image.image_path, dpi=300)
#             plt.close(fig)
#             return 1
#         except Exception as e:
#             traceback.print_exc()
#             return 0
#
#
#     @staticmethod
#     def draw_box(df, feature_name, cluster_name, image):
#         try:
#             fig, ax = plt.subplots()
#             ax.spines['right'].set_color('none')
#             ax.spines['top'].set_color('none')
#             sns.boxplot(x=df[cluster_name], y=df[feature_name], ax=ax)  # palette="Blues"
#             ax.set_title(feature_name.upper(), fontweight="bold", fontname="Times New Roman", fontsize=16)
#             ax.set_ylabel('')
#             ax.set_xlabel('')
#             fig.autofmt_xdate(bottom=0.3, rotation=60)
#             fig.subplots_adjust(right=0.95, left=0.08)
#             fig.savefig(image.image_path, dpi=300)
#             plt.close(fig)
#             return 1
#         except Exception as e:
#             traceback.print_exc()
#             return 0
#
#
#     @staticmethod
#     def draw_bar(df, feature_name, cluster_name, image):
#         try:
#             df_select = df[[feature_name, cluster_name]]
#             df_median = df_select.groupby(cluster_name).median()
#             fig, ax = plt.subplots(figsize=(10, 6))
#             ax.spines['right'].set_visible(False)
#             ax.spines['top'].set_visible(False)
#             sns.barplot(x=df_median.index, y=df_median[feature_name], data=df_median, palette="Set1", ax=ax)
#             ax.xaxis.label.set_visible(False)
#             ax.yaxis.label.set_visible(False)
#             ax.set_xticklabels(ax.get_xticklabels(), weight='bold')
#             fig.autofmt_xdate(bottom=0.2, rotation=45)
#             fig.savefig(image.image_path, dpi=300)
#             plt.close(fig)
#             return 1
#         except Exception as e:
#             traceback.print_exc()
#             return 0
#
#
#
#     @staticmethod
#     def draw_heatmap(df, feature_name_list, cluster_name, image_path, cell_column_name):
#         try:
#             df_sort = df.sort_values(by=[cluster_name])
#             df_sort.set_index([cell_column_name], inplace=True)
#             dfs = df_sort[feature_name_list]
#             df_select = pd.DataFrame(dfs.values.T, index=dfs.columns, columns=dfs.index)
#             color = random_color(number=df_sort[cluster_name].unique().size)
#             network_lut = dict(zip(df_sort[cluster_name].unique(), color))
#             cg = sns.clustermap(df_select, cmap='magma_r', row_cluster=False, col_cluster=None, figsize=(8, 5.5), col_colors=df_sort[cluster_name].map(network_lut),
#                                 xticklabels=False, yticklabels=True, cbar_pos=(0.09, 0.13, 0.03, 0.18), colors_ratio=0.04)  # (left, bottom, width, height)
#             fig = cg.fig
#             for label in df_sort[cluster_name].unique():
#                 cg.ax_col_dendrogram.bar(0, 0, color=network_lut[label], label=label, linewidth=0)
#             cg.ax_col_dendrogram.legend(loc="center", ncol=5, fontsize=9)
#             cg.ax_heatmap.set_yticklabels(cg.ax_heatmap.get_yticklabels(), rotation=0)
#             fig.savefig(image_path, dpi=300)
#             plt.close(fig)
#             return 1
#         except Exception as e:
#             traceback.print_exc()
#             return 0
#
#
#
#
#     # motif_view_data:
#     # {
#     #     "view_name": "FOXF2",
#     #     "view_data": { todo }
#     # }
#     @staticmethod
#     def draw_motif_logo(motif_view_data, image):
#         try:
#             motif_name = motif_view_data["view_name"]
#             motif_dict = motif_view_data["view_data"]
#
#             df = pd.DataFrame(motif_dict)
#             total_counts = df.T.sum()
#             df = (df.T / total_counts).T
#             pfm = df.to_dict(orient='list')
#             pfms = df.fillna(0)
#             normalized_pfms = pfms.apply(lambda x: 2 + np.sum(np.log2(x ** x)), axis=1)
#             normalized_pfms_list = normalized_pfms.values.tolist()
#
#             list2 = []
#             for i in range(len(pfm['A'])):
#                 n = i + 1
#                 a = pfm['A'][i]
#                 c = pfm['C'][i]
#                 g = pfm['G'][i]
#                 t = pfm['T'][i]
#                 height = normalized_pfms_list[i]
#                 list2.extend(
#                     [(n, "A", a * height, "#209456"), (n, "C", c * height, "#265D9B"), (n, "G", g * height, '#FAB42C'), (n, "T", t * height, "#CE2A3C")])
#
#             data = pd.DataFrame.from_records(data=list2, columns=['site', 'letter', 'height', "color"])
#             fig, ax = plt.subplots()
#             dmslogo.draw_logo(data=data, ax=ax, x_col='site', letter_col='letter', color_col='color', letter_height_col='height')
#             ax.set_title(motif_name, fontsize=24)
#             ymajorLocator = MultipleLocator(0.5)
#             ax.yaxis.set_major_locator(ymajorLocator)
#             ax.xaxis.label.set_visible(False)
#             ax.yaxis.label.set_visible(False)
#             ax.xaxis.set_tick_params(rotation=0)
#             fig.subplots_adjust(left=0.1, bottom=0.1, right=0.95)
#             fig.savefig(image.image_path, dpi=300)
#             plt.close(fig)
#             return 1
#         except Exception as e:
#             traceback.print_exc()
#             return 0
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
