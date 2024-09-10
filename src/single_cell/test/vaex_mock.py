# import pandas as pd
# import numpy as np
# import vaex
#
#
#
#
# def mock_data(mock_csv_file):
#     n_rows = 10000000
#     n_cols = 50
#     df = pd.DataFrame(np.random.randint(0, 100, size=(n_rows, n_cols)), columns=['col%d' % i for i in range(n_cols)])
#     print(df.shape)
#     print(df.info(memory_usage="deep"))
#     df.to_csv(mock_csv_file, index=False)
#     mock_h5_file = mock_csv_file + ".hdf5"
#     return mock_h5_file
#
#
# # todo vaex.from_pandas
# # mock_h5_file = mock_data("/home/sgs/data/test/mock.csv")
#
#
# def test_vaex_speed(mock_h5_file):
#     df_v = vaex.open(mock_h5_file)
#     print(type(df_v))
#     print(df_v.col0.sum())
#
#
#
#
#
