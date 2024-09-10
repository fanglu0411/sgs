# import pandas as pd
# import pyranges as pr
#
#
#
#
# input_bed_file = "/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/CD14_Mono.bed"
#
# overlapping_bed_file = "/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/overlapping.bed"
# overlapping1_bed_file = "/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/overlapping1.bed"
# overlapping2_bed_file = "/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/overlapping2.bed"
#
# a_bed_file = "/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/a.bed"
# b_bed_file = "/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/b.bed"
#
#
# def test_count_overlap():
#     df1 = pd.read_csv(a_bed_file, sep="\t", names=["Chromosome", "Start", "End", "cell", "count"])
#     df2 = pd.read_csv(b_bed_file, sep="\t", names=["Chromosome", "Start", "End", "cell", "count"])
#
#     gr1 = pr.PyRanges(df1[["Chromosome", "Start", "End", "count"]])
#     gr2 = pr.PyRanges(df2[["Chromosome", "Start", "End", "count"]])
#     gr_dict = {"gr1": gr1, "gr2": gr2}
#     rs = pr.count_overlaps(gr_dict)
#     print(rs.df)
#
#
# # test_count_overlap()
#
#
#
#
#
#
# def demo_count_overlap():
#     a = '''Chromosome Start End
#     chr1    0    20
#     chr1    0    20
#     chr1    10    30
#     chr1    15    35
#     chr1    5    100'''
#
#     b = '''Chromosome Start End
#     chr1    15    35
#     chr1    5    100'''
#
#     grs = {n: pr.from_string(s) for n, s in zip(["a", "b"], [a, b])}
#     rs = pr.count_overlaps(grs)
#     rs.print()
#     # rs.print(merge_position=True)
#
# demo_count_overlap()
#
#
#
#
#
#
