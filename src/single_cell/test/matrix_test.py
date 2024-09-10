#
# import pandas as pd
# import numpy as np
# import json
# from pandas import DataFrame
#
#
#
#
#
#
#
#
# # ucsc单细胞
# # https://cells.ucsc.edu/?ds=adult-testis
# #
# # plotly 画图
# # https://plotly.com/python/
# #
# # pandas官方文档
# # https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.concat.html
# #
#
#
#
# def mock_matrix_merge():
#     df1 = pd.DataFrame([['1771017030_C09', "OPC", "PDGFRA", "cortex", 93],
#                         ['1771017028_G05', "NFOL2", "CD-1", "hippo", 11],
#                         ['1771052132_B02', "MFOL2", "C57BL6", "corpus", 93],
#                         ['1772099214_D12', "MOL3", "PDGFRA-CRE", "Amygdala", 93]], columns=['cell', 'cluster', 'strain', 'tissue', 'age'])
#     sort_df1 = df1.sort_values(by="cell")
#     print(sort_df1)
#
#     df2 = pd.DataFrame([['1771017030_C09', 11, 22, 33, 44],
#                         ['1771017028_G05', 11, 22, 33, 44],
#                         ['1771052132_B02', 11, 22, 33, 44],
#                         ['1772099214_D12', 11, 22, 33, 44]],  columns=['cell', 'gene1', "gene2", "gene3", "gene4"])
#     df2.set_index("cell")
#     sort_df2 = df2.sort_values(by="cell")
#     print(sort_df2)
#
#     df = sort_df1.reset_index().merge(sort_df2, left_index=True, right_index=True, how="inner", suffixes=('', '_y') , sort=False).set_index("cell")
#     # df = sort_df1.reset_index().merge(sort_df2, left_index=True, right_index=True, how="outer", suffixes=('', '_y') , sort=False).set_index("name")
#     df.drop(df.filter(regex="_y$").columns.tolist(), axis=1, inplace=True)
#     df.drop(columns="index", axis=1, inplace=True)
#     print(df)
#
#     # df.to_csv("/home/sgs/data/test/test_merge.csv", index=False)
#     df.to_csv("/home/sgs/data/test/test_merge.csv")
#     df.to_hdf("/home/sgs/data/test/test_merge.h5", key='df', mode='w')
#
#
# # mock_matrix_merge()
# # hdf = pd.read_hdf("/home/sgs/data/test/test_merge.h5")
# # print(hdf)
#
#
#
#
# def df_split_and_t(input_file, split_file, split_t_file):
#     df = pd.read_csv(input_file, sep="\t", index_col=0)
#     # testdf3.iloc[:,0:4] # 指定连续列，用数字
#     # 前100行
#     df_split = df.iloc[0:20, 0:5]
#     df_split.to_csv(split_file)
#     df_t = df_split.T
#     df_t.to_csv(split_t_file)
#     df_t = pd.read_csv(split_t_file)
#     print(df_t)
# # df_split_and_t("/home/sgs/data/test/ecoli_exp1.tsv", "/home/sgs/data/test/ecoli_exp_split.csv", "/home/sgs/data/test/ecoli_exp_split_t.csv")
#
#
#
#
# def transfer_express_matrix(input_file, output_file):
#     df = pd.read_csv(input_file, sep="\t", index_col=0)
#     df_t = df.T
#     df_t.to_csv(output_file)
#
#
# # transfer_express_matrix("/home/sgs/data/test/ecoli_exp1.tsv", "/home/sgs/data/test/ecoli_exp1_t.tsv")
#
#
# # df = pd.read_csv("/home/sgs/data/test/ecoli_cell_meta.tsv", sep="\t", index_col=0)
# # print(df.iloc[0:20])
# # df2 = df.sort_index()
# # print(df2.iloc[0:20])
#
#
#
# def get_line_by_column_value(matrix_file):
#     df = pd.read_csv(matrix_file, sep="\t")
#     a = df["gene"].isin(["gene-b0001", "gene-b0002"])
#     b = df[df["gene"].isin(["gene-b0001", "gene-b0002"])]
#     print(list(b.index))
#
#
# # get_line_by_column_value("/home/sgs/data/test/ecoli_marker_gene.tsv")
#
#
# # https://blog.csdn.net/sinat_26811377/article/details/103216680  Pandas 对DataFrame的缺失值NA值处理4种方法总结
#
#
# def group_values(cell_meta_file):
#     df = pd.read_csv(cell_meta_file, sep="\t", index_col=0)
#     group_dict = {}
#     columns = list(df.columns)
#     for column in columns:
#         if df[column].dtype.name == "float64":
#             print("===================", column)
#             df.dropna(subset=[column], inplace=True)
#             # df.replace(np.nan, 0, inplace=True)
#             # df.replace(np.inf, 0, inplace=True)
#             vv = df[column].astype("int").drop_duplicates()
#             vv = vv.apply(str)
#             print(vv)
#         elif df[column].dtype.name == "int64":
#             print("===================", column)
#             # df.replace(np.nan, 0, inplace=True)
#             # df.replace(np.inf, 0, inplace=True)
#             df.dropna(subset=[column], inplace=True)
#             vv = df[column].drop_duplicates()
#             vv = vv.apply(str)
#             print(vv)
#         else:
#             print("===================", column)
#             # df.replace(np.nan, 0, inplace=True)
#             # df.replace(np.inf, 0, inplace=True)
#             df.dropna(subset = [column], inplace=True)
#             vv = df[column].drop_duplicates()
#             print(vv)
#         vv = vv.sort_values()
#         gv = vv.values
#         group_dict[column] = list(gv)
#     return group_dict
#
# # group_values("/home/sgs/data/test/ecoli_cell_meta.tsv")
#
#
#
#
#
# # header: [cell_name, x, y, exp_value]
# def gene_cell_plot(cell_all_info_file, gene_name):
#     df = DataFrame(pd.read_hdf(cell_all_info_file))
#     columns = list(df.columns)
#     group_cell_plot_data = []
#     if gene_name in columns:
#         a = df.loc[df[gene_name] > 0]
#         exp_df = a[[gene_name, "x", "y"]]
#         exp_df = exp_df.T
#         exp_dict = exp_df.to_dict()
#         for cell_name, itm in exp_dict.items():
#             group_cell_plot_data.append([cell_name, itm.get(gene_name), itm.get("x"), itm.get("y")])
#     print(group_cell_plot_data)
#
#
# # gene_cell_plot("/home/sgs/data/test/ecoli_merge.h5", "gene-b0003")
#
#
#
#
#
# def sum_columns(cell_matrix_file, exp_file):
#     df = DataFrame(pd.read_hdf(cell_matrix_file, index_col=0))
#     exp_df = pd.read_csv(exp_file, sep="\t", index_col=0)
#     gene_columns = list(exp_df.T.columns)
#     df = df[gene_columns]
#     s = df.apply(lambda x: x.sum())
#     s = s.sort_values(ascending=False)
#     print(type(s))
#     print(s.to_dict())
#
#
# # sum_columns("/home/sgs/data/test/ecoli_merge.h5", "/home/sgs/data/test/ecoli_exp1.tsv")
#
#
#
#
#
# from PIL import Image
# def image_thumbnail(orig_image, thumb_image):
#     im = Image.open(orig_image)
#     im.thumbnail((400,200))
#     im.save(thumb_image, "PNG")
#
#
#
# # image_thumbnail("/home/sgs/data/test/test.jpg", "/home/sgs/data/test/test_thumb.jpg")
#
#
#
#
#
#
# # ======================================================================================================================
# # get gene expression group by cluster and other tags
# # get all cell that express one gene and draw the plot image
#
#
# # get genes expression median in cells
# def cell_feature_median(genes, cells, cell_matrix_file):
#     df = DataFrame(pd.read_hdf(cell_matrix_file, index_col=0))
#     r = df[df.index.isin(cells)]
#     genes_exp = r[genes].median()
#     gene_exp_dict = genes_exp.to_dict()
#     # print("中位数", gene_exp_dict, type(gene_exp_dict))
#     return gene_exp_dict
#
# # cell_feature_median(["gene-b0002", "gene-b0004"], ["1771017028_E12", "1771017029_D10"], "/home/sgs/data/test/ecoli_merge.h5")
#
#
#
#
#
#
# # get genes expression median of one group
# # r = df.query("(cell in ['1771017028_E12', '1771017029_D10']) & (cell_class == 'OPC') ")
# # r = df.query("cell in ['1771017028_E12', '1771017029_D10'] ")
# # r = df[df.index == "1771017028_E12" ]
# # r = df[df["gene-b0001"] > 0]
# def group_one_value_genes_exp_median(genes, group_name, group_value, cell_matrix_file):
#     df = DataFrame(pd.read_hdf(cell_matrix_file, index_col=0))
#     r = df[df[group_name] == group_value]
#     genes_exp = r[genes].median()
#     gene_exp_dict = genes_exp.to_dict()
#     # print("中位数", gene_exp_dict, type(gene_exp_dict))
#     return gene_exp_dict
#
# # group_one_value_genes_exp_median(["gene-b0002", "gene-b0004"], "cell_class", "VLMC", "/home/sgs/data/test/ecoli_merge.h5")
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
