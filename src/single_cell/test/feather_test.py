# # pip install feather-format
# import pandas as pd
# import pyarrow.feather as feather
#
#
#
# # https://pandas.pydata.org/pandas-docs/stable/user_guide/io.html#performance-considerations  performance-considerations
# # https://arrow.apache.org/docs/python/feather.html  feather doc
# # https://github.com/wesm/feather feather github
#
#
#
#
# # pyarrow.feather.write_feather
# # pyarrow.feather.write_feather(df, dest, compression=None, compression_level=None, chunksize=None, version=2)[source]
# # Write a pandas.DataFrame to Feather format.
# # Parameters
# # df (pandas.DataFrame or pyarrow.Table) – Data to write out as Feather format.
# # dest (str) – Local destination path.
# # compression (string, default None) – Can be one of {“zstd”, “lz4”, “uncompressed”}. The default of None uses LZ4 for V2 files if it is available, otherwise uncompressed.
# # compression_level (int, default None) – Use a compression level particular to the chosen compressor. If None use the default compression level
# # chunksize (int, default None) – For V2 files, the internal maximum size of Arrow RecordBatch chunks when writing the Arrow IPC file format. None means use the default, which is currently 64K
# # version (int, default 2) – Feather file version. Version 2 is the current. Version 1 is the more limited legacy format
# def test2feather():
#
#     cell_scatter_file = "/home/sgs/data/mouse/mouse_lsi.coords.tsv"
#     plot_df = pd.read_csv(cell_scatter_file, sep="\t", names=["cell", "x", "y"])
#     plot_df = plot_df.sort_values(by="cell")
#     print("plot shape", plot_df.shape)
#
#
#     cell_meta_file = "/home/sgs/data/mouse/cell_meta.tsv"
#     # cell_meta = pd.read_csv(cell_meta_file, sep="\t", index_col=0)
#     cell_meta = pd.read_csv(cell_meta_file, sep="\t", index_col=0)
#     print("cell_meta shape", cell_meta.shape)
#
#     # all_df = plot_df.merge(cell_meta, left_index=True, right_index=True, how="inner")
#     all_df = plot_df.merge(cell_meta, left_on='cell', right_index=True, how="inner")
#     print("cell_meta plot shape", all_df.shape)
#
#     exp_file = "/home/sgs/data/mouse/mouse_exp.tsv"
#     exp_f = pd.read_csv(exp_file, sep="\t", index_col=0)
#     exp_f = exp_f.T
#     exp_t = exp_f.sort_index()
#     print("exp shape", exp_t.shape)
#
#     all_df = all_df.merge(exp_t, left_on='cell', right_index=True, how="inner")
#
#     print("all_info shape", all_df.shape)
#
#     # all_df.index.name = "cell"
#     all_info_file = "/home/sgs/data/mouse/all_info.f"
#     feather.write_feather(all_df, all_info_file)
#
#
# # test2feather()
#
#
#
#
#
# # pyarrow.feather.read_feather(source, columns=None, use_threads=True, memory_map=True)[source]
# # Read a pandas.DataFrame from Feather format. To read as pyarrow.Table use feather.read_table.
# # Parameters
# # source (str file path, or file-like object) –
# # columns (sequence, optional) – Only read a specific set of columns. If not provided, all columns are read.
# # use_threads (bool, default True) – Whether to parallelize reading using multiple threads.
# # memory_map (boolean, default True) – Use memory mapping when opening file on disk
# # Returns   df (pandas.DataFrame)
# def test_read_feather():
#     exp_file_f = "/home/sgs/data/mouse/all_info.f"
#     df = feather.read_feather(exp_file_f, memory_map=True)
#     # df = feather.read_feather(exp_file_f, columns = ['gene-b4395', 'gene-b4396', 'gene-b4397'], memory_map=True)
#     print(df.columns)
#     print(df.shape)
#     print(df.iloc[[0]])
#
#
#
# # test_read_feather()
#
#
#
# import vaex
# def test_read_csv(file_name):
#     # pd.read_csv("head.csv",nrows=2,skiprows=3,header=None)
#     # df = pd.read_csv(file_name, sep="\t", nrows=2)
#     df = vaex.read_csv(file_name, sep="\t", copy_index=False)
#     print(df.shape)
#
#     # 28728
#     # index = 0
#     # df_all = None
#     # for chunk in pd.read_csv(file_name, sep="\t", chunksize=100):
#     #     if index == 0:
#     #         print("chunk1", chunk.shape)
#     #         df_all = chunk
#     #     elif index == 1:
#     #         df_all = df_all.merge(chunk, how="inner")
#     #         print("chunk1+2", df_all.shape)
#     #     index = index + 1
#     #
#     # print(df_all.shape)
#     # print(len(list(df_all.columns)))
#
#
# # test_read_csv("/home/sgs/data/hg38/exprMatrix.tsv")
#
#
#
#
# # from pycylon import read_csv, DataFrame, CylonEnv
# # from pycylon.net import MPIConfig
# # def test_vaex_to_pandas(file_name):
# #     # Initialize Cylon distributed environment
# #     config: MPIConfig = MPIConfig()
# #     env: CylonEnv = CylonEnv(config=config, distributed=True)
# #
# #     df1: DataFrame = read_csv('/tmp/csv1.csv')
# #     df2: DataFrame = read_csv('/tmp/csv2.csv')
# #
# #     # Using 1000s of cores across the cluster to compute the join
# #     df3: Table = df1.join(other=df2, on=[0], algorithm="hash", env=env)
# #
# #     print(df3)
#
#
#
#
#
#
# # big csv
# # https://pandas.pydata.org/pandas-docs/stable/user_guide/scale.html
# #
# # https://pandas-genomics.readthedocs.io/en/latest/
# #
# # https://pandas.pydata.org/pandas-docs/stable/ecosystem.html#ecosystem-out-of-core  生态
# #
# # https://pythondata.com/dask-large-csv-python/   dask
# #
# # https://examples.dask.org/dataframes/01-data-access.html
#
#
#
#
# # import pandas as pd
# # NCOLS = 1.8e6  # The exact number of columns
# #
# # batch_size = 50
# # from_file = 'my_large_file.csv'
# # to_file = 'my_large_file_transposed.csv'
# # for batch in range(NCOLS//batch_size + bool(NCOLS%batch_size)):
# #     lcol = batch * batch_size
# #     rcol = min(NCOLS, lcol+batch_size)
# #     data = pd.read_csv(from_file, usecols=range(lcol, rcol))
# #     with open(to_file, 'a') as _f:
# #         data.T.to_csv(_f, header=False)
#
#
#
#
# # test draw_gene_plots
# # import multiprocessing
# # if __name__ == '__main__':
# #     mg = MarkerGene()
# #     p = multiprocessing.Pool(multiprocessing.cpu_count())
# #     p.apply_async(mg.draw_gene_plots, args=("gene-b2787", "/home/sgs/data/test/ecoli_merge.h5", "tsne", "/home/sgs/data/test/test.jpg",))
# #     p.close()
# #     p.join()
# #     print('Parent process done!')
#
#
#
#
#
