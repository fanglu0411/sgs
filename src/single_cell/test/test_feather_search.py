# import pandas as pd
#
#
#
# def test_scope_search():
#     block_start = 5
#     block_end = 35
#     a = [[1, 10], [20, 30], [40, 50], [60, 70]]
#     dfa = pd.DataFrame(a)
#     dfa.columns = ["start", "end"]
#     print(dfa)
#     d1 = dfa[(dfa["start"] >= block_start) & (dfa["start"] <= block_end)]
#     d2 = dfa[(dfa["end"] >= block_start) & (dfa["end"] <= block_end)]
#     d3 = dfa[((dfa["start"] >= block_start) & (dfa["start"] <= block_end)) | ((dfa["end"] >= block_start) & (dfa["end"] <= block_end))]
#     print(d1)
#     print(d2)
#     print(d3)
#
#
#
#
