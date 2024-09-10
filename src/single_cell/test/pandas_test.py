# import pandas as pd
#
#
#
#
#
#
# csv_file = "/home/sgs/data/sc/a290deb8f9a34635830208f8ac990ba0/cell_all_info_file.h5.csv"
# hdf5_file = "/home/sgs/data/sc/a290deb8f9a34635830208f8ac990ba0/cell_all_info_file.h5"
# mouse_exp_file = "/home/sgs/data/mouse/mouse_exp.tsv"
#
#
#
#
# def catagory_test(file):
#     df_pa = pd.read_csv(file, sep="\t", index_col=0, names=["cell", "x", "y"])
#     print(df_pa.columns)
#     # print(df_pa.columns)
#     # df_pa = df_pa.dropna()
#     # print(df_pa.head())
#     # print(df_pa.columns)
#     print(df_pa.info(memory_usage="deep"))
#     print("===========================================")
#     # df_h5 = DataFrame(pd.read_hdf(hdf5_file))
#     # print(df_h5.info(memory_usage="deep"))
#
#
# # catagory_test(mouse_exp_file)
#
#
#
#   # dff = df.drop_duplicates(subset=0, inplace=True) # 去重
#     # 切片测试
#     # merge_data = DataFrame(pd.read_hdf(merge_file, index_col=0))
#     # merge_data.index.name = "cell"
#     # split_m = merge_data.iloc[0:70, 0:20]
#     # split_m.to_csv("/home/sgs/data/test/heihei.tsv")
#
#
#
#
# plot1 = "/home/sgs/data/mouse/23k/mouse_sample_marker_gene.txt"
# plot2 = "/home/sgs/data/mouse/23k/mouse_cluster_marker_gene.txt"
#
# def test_merge_plot_file(plot_file1, plot_file2):
#     plot_df = pd.read_csv(plot_file1, sep="\t", names=["cell", "x1", "y1"])
#     plot_df = plot_df.sort_values(by="cell")
#     plot2_df = pd.read_csv(plot_file2, sep="\t", names=["cell2", "x2", "y2"])
#     plot2_df = plot2_df.sort_values(by="cell2")
#     plot2_df = plot2_df[["x2", "y2"]]
#     plot_df = plot_df.merge(plot2_df, left_on='cell', right_on='x2', how="inner")
#     print("merge plot columns === ", plot_df.columns)
#
# # test_merge_plot_file(plot1, plot2)
#
#
#
#
#
#
#
# def test_columns_sub():
#     data1 = {"a": [1, 5, 7], "b": [3, 7, 99]}
#     df1 = pd.DataFrame(data1)
#
#     ss = df1["b"] - df1["a"]
#     ss_mean = ss.mean()
#     print(int(ss_mean))
#     print(type(ss_mean))
#
#     # df_c_mean = df1[["c"]].mean()
#     # print(df_c_mean[0])
#     # print(type(df_c_mean))
#
# test_columns_sub()
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
