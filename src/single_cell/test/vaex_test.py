import pandas as pd
import vaex
from pandas import DataFrame
import numpy as np
import matplotlib.pylab as plt
import vaex as va
import time





mouse_csv_file = "/home/sgs/data/sc/a290deb8f9a34635830208f8ac990ba0/cell_all_info_file.h5.csv"
pandas_hdf5_file = "/home/sgs/data/sc/a290deb8f9a34635830208f8ac990ba0/cell_all_info_file.h5"
vax_h5 = "/home/sgs/data/sc/a290deb8f9a34635830208f8ac990ba0/cell_all_info_file.h5.csv.hdf5"




def test_pandas(h5_file):
    print("=================== pandas")
    time1 = time.time()
    df_pd = DataFrame(pd.read_hdf(h5_file))
    print(df_pd.info(memory_usage="deep"))
    time2 = time.time()
    print("open cost: ", (time2 - time1))
    print(df_pd["total"].mean())
    time3 = time.time()
    print("mean cost: ", (time3 - time2))

# test_pandas(pandas_hdf5_file)



def test_vaex(h5_file):
    print("=================== vaex")
    time1 = time.time()
    df_va = va.open(h5_file)
    print(type(df_va))
    time2 = time.time()
    print("open cost: ", (time2 - time1))
    print(df_va["total"].mean())
    time3 = time.time()
    print("mean cost: ", (time3 - time2))

# test_vaex(vax_h5)




def csv2hdf5(csv_file):
    va.from_csv(csv_file, convert=True, chunk_size=5000000)

# csv2hdf5(mouse_csv_file)



def plot_test(file):
    df = va.open(file)
    print(df)
    x = df.evaluate("x", selection=df.x > 100)
    y = df.evaluate("y", selection=df.y > 100)
    # x = df.evaluate("x")
    # y = df.evaluate("y")
    plt.scatter(x, y, c="blue")
    plt.savefig("./ecoli.jpg")
    plt.show()
    df.close()

# csv2hdf5("/home/sgs/data/test/heihei.csv")
# plot_test("/home/sgs/data/test/heihei.csv.hdf5")



# def zoom_expand():
#     a = np.array([[2, 3, 5], [4, 6, 7], [1, 5, 7]])
#     b = np.kron(a, np.ones((3, 3)))
#     print(b)
# zoom_expand()




# todo vaex.from_pandas
mock_csv_file = "/home/sgs/data/test/mock.csv"

def mock_data():
    n_rows = 10000000
    n_cols = 50
    df = pd.DataFrame(np.random.randint(0, 100, size=(n_rows, n_cols)), columns=['col%d' % i for i in range(n_cols)])
    print(df.shape)
    print(df.info(memory_usage="deep"))
    df.to_csv(mock_csv_file, index=False)

# mock_data()

# dv = vaex.from_csv(mock_csv_file, convert=True, chunk_size=1000000)


# mock_h5_file = "/home/sgs/data/test/mock.csv.hdf5"
# df_v = vaex.open(mock_h5_file)
# print(type(df_v))
# print(df_v.col0.sum())








