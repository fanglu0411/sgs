# # conda install -c bioconda pyranges
# # or conda install -c bioconda ncls
#
#
# import os
# import pandas as pd
# from single_cell.parser.coverage_util import duplicate_df, split_range, count_coverage, df2bigwig
#
#
#
# # https://github.com/biocore-ntnu/ncls
# # https://www.bilibili.com/read/cv14181523
# # https://www.douban.com/note/211921266/ 线段树
# # https://academic.oup.com/bioinformatics/article/23/11/1386/199545
#
#
# # BED file: Find intervals that overlap a certain percentage and keep the longest one
# # https://www.biostars.org/p/9470750/
#
#
# # https://github.com/biocore-ntnu/pyranges
# # https://pyranges.readthedocs.io/en/master/autoapi/pyranges/multioverlap/index.html
#
#
#
#
# def test1(bed_file):
#     df = pd.read_csv(bed_file, sep="\t", names=["Chromosome", "Start", "End", "cell", "count"])
#     dfs = {k: v for k, v in df.groupby("Chromosome")}
#
#     big_file_folder = "/home/sgs/data/test/coverage/"
#     if not os.path.exists(big_file_folder):
#         os.makedirs(big_file_folder)
#     big_file = os.path.join(big_file_folder, "test_coverage.bigwig")
#     chr_df = dfs["chr1"]
#     print("chr_df", chr_df.shape)
#     df_dup = duplicate_df(chr_df)
#     print("df_dup", df_dup.shape)
#
#     df_split = split_range(df_dup)
#
#     df_dup = df_dup[["Chromosome", "Start", "End", "cell"]]
#     print("df_split", df_split.shape)
#
#     df_result = count_coverage(df_split, df_dup, "count")
#     print("df_result", df_result.shape)
#
#     # save to big
#     chr1_length = 249250621
#     df2bigwig(df_result, big_file, chr1_length, "chr1")
#
#
#
#     # big_files = {}
#     # for chr_name, df in dfs.items():
#     #     print("df", df.shape)
#     #     df_dup = duplicate_df(df)
#     #     print("df_dup", df_dup.shape)
#     #
#     #     df_split = split_range(df_dup)
#     #     df_dup = df_dup[["Chromosome", "Start", "End", "cell"]]
#     #     print("df_split", df_split.shape)
#     #
#     #     df_result = count_coverage(df_split, df_dup, "count")
#     #     print("df_result", df_result.shape)
#     #
#     #     # todo save to big
#     #     big_files[chr_name] = ""
#     #
#     # return big_files
#
#
#
# # test("/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/small.bed")
# # test("/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/test.bed")
# # test("/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/NK_CD56bright.bed")
# # test("/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/NK_CD56Dim.bed")s
# # test("/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/CD8_Effector.bed")
# # test("/home/sgs/data/hg19/sc/pbmc_5k_bed/cluster/CD14_Mono.bed")
#
#
#
# # read_big("/home/sgs/data/test/coverage/test_coverage.bigwig")
#
#
# def test2():
#
#     reads = [
#         ["chr1", 10, 30, "GTGTGATCAAGTAACA-1", 2],
#         ["chr1", 15, 35, "GGGACCTAGGATATCA-1", 3] ,
#         ["chr1", 30, 100, "GCTGCGAGTATCTGCA-1", 1] ,
#         ["chr1", 1000, 2000, "GCTGCGAGTATCTGCA-1", 1]
#     ]
#
#     reads_df = pd.DataFrame(reads)
#     reads_df.columns = ["Chromosome", "Start", "End", "cell", "count"]
#
#     print(reads_df["Start"].max())
#
#
#     # df_dup = duplicate_df(reads_df)
#     # df_dup.columns = ["Chromosome", "Start", "End", "cell", "count"]
#     #
#     # print(reads_df)
#     # print(df_dup)
#     # df_split = split_range(reads_df)
#     # print(df_split)
#
#
#
# # test2()
#
#
#
#
# import pyBigWig
# def test_read_big(big_file, chr_name):
#     stats_type = "max"
#     bw = pyBigWig.open(big_file)
#     stats = bw.stats(chr_name, 10000, 10000000, type=stats_type, nBins=100)
#     print("stats", stats)
#
#     intervals = bw.intervals(chr_name, 10000, 10000000)
#     print("intervals", intervals)
#     bw.close()
#
#
#
#
#
#
#
#
#
