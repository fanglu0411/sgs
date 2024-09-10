# # conda install -c conda-forge vaex
# import pandas as pd
# from pandas import DataFrame
# import numpy as np
# import matplotlib.pylab as plt
# import vaex, time
#
#
#
#
#
# # vaex 文档和github
# # https://vaex.io/docs/index.html  官方文档
# # https://github.com/vaexio  vaex github
# # vaex  以及 内存映射原理
# # https://zhuanlan.zhihu.com/p/356385219
# # https://zhuanlan.zhihu.com/p/356547017
# # https://zhuanlan.zhihu.com/p/356574558
# # https://www.youtube.com/watch?v=2Tt0i823-ec&t=769s&ab_channel=PyData
# # https://zhuanlan.zhihu.com/p/147627842  Vaex真香！几秒钟就能处理数十亿行数据，比Pandas、Dask更好用
# # https://zhuanlan.zhihu.com/p/240797772   Vaex ：突破pandas，快速分析100G大数据量
#
# # https://baijiahao.baidu.com/s?id=1671080188522713952&wfr=spider&for=pc  这场Spark、Dask、Vaex、Pandas的正面交锋，谁赢了
#
# # https://blog.csdn.net/weixin_42608414/article/details/106578074  震惊! 居然可以用python在短短几秒内处理几十亿数据！
#
# # CSV, Arrow, Parquet, hdf5
#
# # CSV：最常用的数据格式
# # Pickle：用于序列化和反序列化Python对象结构
# # MessagePack：类似于json，但是更小更块
# # HDF5：一种常见的跨平台数据储存文件
# # Feather：一个快速、轻量级的存储框架
# # Parquet：Apache Hadoop的列式存储格式
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
# mouse_csv_file = "/home/sgs/data/sc/a290deb8f9a34635830208f8ac990ba0/cell_all_info_file.h5.csv"
# pandas_hdf5_file = "/home/sgs/data/sc/a290deb8f9a34635830208f8ac990ba0/cell_all_info_file.h5"
# vax_h5 = "/home/sgs/data/sc/a290deb8f9a34635830208f8ac990ba0/cell_all_info_file.h5.csv.hdf5"
#
#
#
#
#
# def pandas2vaex(pandas_h5_file, vax_h5):
#     df_pandas = DataFrame(pd.read_hdf(pandas_h5_file))
#     df_pandas = df_pandas.dropna()
#     df_vax = vaex.from_pandas(df_pandas)
#
#
#
#
#
#
#
# def test_pandas(h5_file):
#     print("=================== pandas")
#     time1 = time.time()
#     df_pd = DataFrame(pd.read_hdf(h5_file))
#     print(df_pd.info(memory_usage="deep"))
#     time2 = time.time()
#     print("open cost: ", (time2 - time1))
#
#     print(df_pd["total"].mean())
#     time3 = time.time()
#     print("mean cost: ", (time3 - time2))
#
#
#
#
# def test_vaex(h5_file):
#     print("=================== vaex")
#     time1 = time.time()
#     df_va = vaex.open(h5_file)
#     print(type(df_va))
#     time2 = time.time()
#     print("open cost: ", (time2 - time1))
#     print(df_va["total"].mean())
#     time3 = time.time()
#     print("mean cost: ", (time3 - time2))
#
#
#
#
# def csv2hdf5(csv_file):
#     dv = vaex.from_csv(csv_file, convert=True, chunk_size=1000000)
#
#
# def dataframe2hdf5():
#     print()
#
# def zoom_expand():
#     a = np.array([[2, 3, 5], [4, 6, 7], [1, 5, 7]])
#     b = np.kron(a, np.ones((3, 3)))
#     print(b)
#
#
#
# def plot_test(file):
#     df = vaex.open(file)
#     print(df)
#     x = df.evaluate("x", selection=df.x > 100)
#     y = df.evaluate("y", selection=df.y > 100)
#     # x = df.evaluate("x")
#     # y = df.evaluate("y")
#     plt.scatter(x, y, c="blue")
#     plt.savefig("./ecoli.jpg")
#     plt.show()
#     df.close()
#
#
#
# mouse_exp_file = "/home/sgs/data/mouse/mouse_exp.tsv"
#
#
#
#
#
#
#
