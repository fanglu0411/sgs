# import pandas as pd
# from old.single_cell_old.parser import coverage_util
# from track.single.bed.normal import bed_path
# from track.util import track_util
# from db.dao import chromosome_dao
#
#
# # conda install -c bioconda pyranges
# # or conda install -c bioconda ncls
#
# # bed to pandas, group by chromosome and count features
# # pandas to bigwig
# def bed2bigwig(session, track_id, bed_file, species_id):
#     df = pd.read_csv(bed_file, sep="\t", usecols=[0, 1, 2], comment="#")
#     df.columns = ["Chromosome", "Start", "End"]
#     df["Chromosome"] = df["Chromosome"].astype("str")
#     df["Start"] = df["Start"].astype("int32")
#     df["End"] = df["End"].astype("int32")
#     group_dfs = {k: v for k, v in df.groupby("Chromosome")}
#     chr_f_count_dict = {}
#     chr_big_file_dict = {}
#     chr_name_length_dict = {}
#     for chr_name, chr_df in group_dfs.items():
#         print("chr_", chr_name, chr_df.shape)
#         chr_name = str(chr_name)
#         chr_f_count_dict[chr_name] = chr_df.shape[0]
#         df_split = coverage_util.split_range(chr_df)
#         print("split_range")
#         df_split = df_split[["Chromosome", "Start", "End"]]
#         #     todo 内存溢出
#         chr_df_result = coverage_util.count_coverage(df_split, chr_df, "count")
#         print("count_coverage")
#         chr_big_file = bed_path.get_split_big_file(track_id, chr_name)
#         chr_big_file_dict[chr_name] = chr_big_file
#         if chr_name in chr_name_length_dict.keys():
#             chr_length = chr_name_length_dict.get(chr_name)
#         else:
#             chr_search_name = track_util.get_chr_search_name(chr_name)
#             chromosome = chromosome_dao.get_chromosome_by_search_name(species_id, chr_search_name)
#             chr_length = chromosome.seq_length
#             chr_name_length_dict[chr_name] = chr_length
#         coverage_util.df2bigwig(chr_df_result, chr_big_file, chr_length, chr_name)
#         print("df2bigwig")
#     return group_dfs, chr_f_count_dict, chr_big_file_dict
#
#
#
#
#
#
# # 获取bed文件每个chr下reocrds位置信息,(this have changed!!)
# #big_chr_records = {'chr1': {'feature': [[246919, 246920], [247945, 247946], [248234, 248235], [255415, 255416], [255660, 255661]]}}
# #chr_records = {"chr":[[start, end],...], ...]}
# @DeprecationWarning
# def read_bed_file(bed_file, chr_name_length):
#     #{chr_name:{big_type:[]}}
#     # big_chr_records = {}
#     chr_records = {}
#     line_num = 0
#     return_code = 0
#     reader = None
#     error_msg = ""
#     try:
#         reader = open(bed_file,"r")
#         for l in reader:
#             line_num = line_num + 1
#             rec = l.strip("\n").split("\t")
#             chr_name = rec[0]
#             ref_start = int(rec[1])
#             ref_end = int(rec[2])
#             record = [ref_start, ref_end]
#             chr_length = chr_name_length.get(chr_name)
#             if chr_length and ref_end >= int(chr_length):
#                 continue
#             #todo 该函数未使用
#             # add2big_chr_records(big_chr_records, record, chr_name, record_type)
#             if chr_name not in chr_records.keys():
#                 chr_records[chr_name] = [record]
#             else:
#                 chr_records.get(chr_name).append(record)
#     except Exception as e:
#         print(e)
#         return_code = 1
#         error_msg = "bed parse error at line " + str(line_num)
#     finally:
#         if reader:
#             reader.close()
#     return chr_records, return_code, error_msg
#     # return chr_records, big_chr_records, return_code, error_msg
#
#
#
#
# ###new bed file paser
# ###定义str类型判断
# def is_number(s):
#     try:
#         float(s)
#         return True
#     except ValueError:
#         pass
#     try:
#         import unicodedata
#         unicodedata.numeric(s)
#         return True
#     except (TypeError, ValueError):
#         pass
#     return False
#
#
#
# ##rgb deal：rbg换算
# # if bed_type in ['bed9', 'bed12'] and len(bed.rgb) == 3
# def deal_rgb(rgb):
#     default = '#1f78b4'
#     if len(rgb) == 3:
#         try:
#             rgb = [float(x) / 255 for x in rgb]
#         except IndexError:
#             rgb = default
#         else:
#             rgb = default
#     else:
#         rgb = default
#     return rgb
#
#
#
#
#
# ####get the bed subfeatures
# ###6,9,12
# # type = ["cds","five_prime_utr", "three_prime_utr",'']
# def get_block_pos(thickstart, thickend, block_counts, start, end ,strand, rgb, block_starts, block_sizes):
#     positions = []
#     ##calculate the bed12 format block pos and type
#     if block_counts and block_starts and block_sizes:
#         for idx in range(0, block_counts):
#             # x0 and x1 are the start/end of the current block
#             x0 = start + block_starts[idx]
#             x1 = x0 + block_sizes[idx]
#             # We deal with the special case where
#             # there is no coding independently
#             if thickstart == thickend:
#                 # positions = ['', strand, rgb, x0, x1, 'five_prime_utr', []]
#                 ##changed
#                 positions.append(['', strand, rgb, x0, x1, 'five_prime_utr', []])
#                 continue
#             # If the beginning of the coding region
#             # is withing the current block
#             if x0 < thickstart < x1:
#                 # What is before is UTR
#                 positions.append(['', strand, rgb, x0, thickstart, 'five_prime_utr', []])
#                 # The start of the interval is updated
#                 x0 = thickstart
#
#             # If the end of the coding region
#             # is withing the current block
#             if x0 < thickend < x1:
#                 # What is before is coding
#                 positions.append(['', strand, rgb, x0, thickend, 'cds', []])
#                 # The start of the interval is updated
#                 x0 = thickend
#             if x1 < thickstart:
#                 type = 'five_prime_utr'
#             elif x0 >= thickend:
#                 type = 'three_prime_utr'
#             else:
#                 type = 'cds'
#             positions.append(['', strand, rgb, x0, x1, type, []])
#     elif thickend and thickstart:
#         if thickstart != start:
#             positions.append(['', strand, rgb, start, thickstart, 'five_prime_utr', []])
#             if thickend != end:
#                 positions.append([['', strand, rgb, thickstart, thickend, 'cds', []], ['', strand, rgb, thickend, end, 'three_prime_utr', []]])
#             else:
#                 positions.append(['', strand, rgb, thickstart, thickend, 'cds', []])
#         else:
#             if thickend != end:
#                 positions.append([['', strand, rgb, thickstart, thickend, 'cds', []], ['', strand, rgb, thickend, end, 'three_prime_utr', []]])
#             else:
#                 positions = []
#     return positions
#
#
#
# #bed_file_type:bed3, bed4, bed6, bed8, bed9, bed12
# #r: a list of rec
# #rec_length: the length of the rec
# def bed_file_type(r, rec_length):
#     if rec_length in [4,5]:
#         if not is_number(r[3]):
#             bed_type = "bed4"
#         else:
#             bed_type = "bed3"
#
#     elif rec_length in [6,7]:
#         if r[5] in ["+", "-", ".", "1", "-1"]:
#             bed_type = "bed6"
#         else:
#             if not is_number(r[3]):
#                 bed_type = "bed4"
#             else:
#                 bed_type = "bed3"
#
#     elif rec_length == 8:
#         if is_number(r[6]) and is_number(r[7]):
#             if type(eval(r[6])) == int and type(eval(r[7])) == int:
#                 bed_type = "bed8"
#             else:
#                 if r[5] in ["+", "-", ".", "1", "-1"]:
#                     bed_type = "bed6"
#                 else:
#                     if not is_number(r[3]):
#                         bed_type = "bed4"
#                     else:
#                         bed_type = "bed3"
#         else:
#             if r[5] in ["+", "-", ".", "1", "-1"]:
#                 bed_type = "bed6"
#             else:
#                 if not is_number(r[3]):
#                     bed_type = "bed4"
#                 else:
#                     bed_type = "bed3"
#
#     elif rec_length in [9, 10, 11]:
#         if r[8].split(",") and len(r[8].split(",")) == 3:
#             bed_type = 'bed9'
#         ##this use for uscs style
#         elif is_number(r[8]):
#             if type(eval(r[8])) == int:
#                 bed_type = 'bed9'
#             else:
#                 if is_number(r[6]) and is_number(r[7]):
#                     if type(eval(r[6])) == int and type(eval(r[7])) == int:
#                         bed_type = "bed8"
#                     else:
#                         if r[5] in ["+", "-", ".", "1", "-1"]:
#                             bed_type = "bed6"
#                         else:
#                             if not is_number(r[3]):
#                                 bed_type = "bed4"
#                             else:
#                                 bed_type = "bed3"
#                 else:
#                     if r[5] in ["+", "-", ".", "1", "-1"]:
#                         bed_type = "bed6"
#                     else:
#                         if not is_number(r[3]):
#                             bed_type = "bed4"
#                         else:
#                             bed_type = "bed3"
#         else:
#             if is_number(r[6]) and is_number(r[7]):
#                 if type(eval(r[6])) == int and type(eval(r[7])) == int:
#                     bed_type = "bed8"
#                 else:
#                     if r[5] in ["+", "-", ".", "1", "-1"]:
#                         bed_type = "bed6"
#                     else:
#                         if not is_number(r[3]):
#                             bed_type = "bed4"
#                         else:
#                             bed_type = "bed3"
#             else:
#                 if r[5] in ["+", "-", ".", "1", "-1"]:
#                     bed_type = "bed6"
#                 else:
#                     if not is_number(r[3]):
#                         bed_type = "bed4"
#                     else:
#                         bed_type = "bed3"
#
#     elif rec_length == 12:
#         if str(r[10]).split(",") and str(r[11]).split(","):
#             ##block 数目判断
#             if len(str(r[10]).split(",")) == len(str(r[11]).split(",")) and len([int(x) for x in r[10].split(",") if x != '']) == int(r[9]):
#                 bed_type = 'bed12'
#             else:
#                 if r[8].split(",") and len(r[8].split(",")) == 3:
#                     bed_type = 'bed9'
#                 elif is_number(r[8]):
#                     if type(eval(r[8])) == int:
#                         bed_type = 'bed9'
#                     else:
#                         if is_number(r[6]) and is_number(r[7]):
#                             if type(eval(r[6])) == int and type(eval(r[7])) == int:
#                                 bed_type = "bed8"
#                             else:
#                                 if r[5] in ["+", "-", ".", "1", "-1"]:
#                                     bed_type = "bed6"
#                                 else:
#                                     if not is_number(r[3]):
#                                         bed_type = "bed4"
#                                     else:
#                                         bed_type = "bed3"
#                         else:
#                             if r[5] in ["+", "-", ".", "1", "-1"]:
#                                 bed_type = "bed6"
#                             else:
#                                 if not is_number(r[3]):
#                                     bed_type = "bed4"
#                                 else:
#                                     bed_type = "bed3"
#                 else:
#                     if is_number(r[6]) and is_number(r[7]):
#                         if type(eval(r[6])) == int and type(eval(r[7])) == int:
#                             bed_type = "bed8"
#                         else:
#                             if r[5] in ["+", "-", ".", "1", "-1"]:
#                                 bed_type = "bed6"
#                             else:
#                                 if not is_number(r[3]):
#                                     bed_type = "bed4"
#                                 else:
#                                     bed_type = "bed3"
#                     else:
#                         if r[5] in ["+", "-", ".", "1", "-1"]:
#                             bed_type = "bed6"
#                         else:
#                             if not is_number(r[3]):
#                                 bed_type = "bed4"
#                             else:
#                                 bed_type = "bed3"
#         else:
#             if r[8].split(",") and len(r[8].split(",")) == 3:
#                 bed_type = 'bed9'
#             elif is_number(r[8]):
#                 if type(eval(r[8])) == int:
#                     bed_type = 'bed9'
#                 else:
#                     if is_number(r[6]) and is_number(r[7]):
#                         if type(eval(r[6])) == int and type(eval(r[7])) == int:
#                             bed_type = "bed8"
#                         else:
#                             if r[5] in ["+", "-", ".", "1", "-1"]:
#                                 bed_type = "bed6"
#                             else:
#                                 if not is_number(r[3]):
#                                     bed_type = "bed4"
#                                 else:
#                                     bed_type = "bed3"
#                     else:
#                         if r[5] in ["+", "-", ".", "1", "-1"]:
#                             bed_type = "bed6"
#                         else:
#                             if not is_number(r[3]):
#                                 bed_type = "bed4"
#                             else:
#                                 bed_type = "bed3"
#             else:
#                 if is_number(r[6]) and is_number(r[7]):
#                     if type(eval(r[6])) == int and type(eval(r[7])) == int:
#                         bed_type = "bed8"
#                     else:
#                         if r[5] in ["+", "-", ".", "1", "-1"]:
#                             bed_type = "bed6"
#                         else:
#                             if not is_number(r[3]):
#                                 bed_type = "bed4"
#                             else:
#                                 bed_type = "bed3"
#                 else:
#                     if r[5] in ["+", "-", ".", "1", "-1"]:
#                         bed_type = "bed6"
#                     else:
#                         if not is_number(r[3]):
#                             bed_type = "bed4"
#                         else:
#                             bed_type = "bed3"
#     else:
#         bed_type = 'bed3'
#     return bed_type
#
#
# ##bed type:bed4, bed6, bed8, bed9, bed12, bed3
# # f_view_list = ['name', 'strand', 'color', 'start', 'end', 'view_type', sub_features]
# # sub_features = [['name', 'strand', 'color', 'start', 'end', 'view_type', []], ['name', 'strand', 'color', 'start', 'end', 'view_type', []],......]
# # block_pos = ['name', 'strand', 'color', 'start', 'end', 'view_type', []]
# #view_type = ['', 'cds','five_prime_utr', 'three_prime_utr']
# def parse_bed_record(rec, bed_type):
#     start = int(rec[1])
#     end = int(rec[2])
#     color = ''
#     name = ''
#     strand = '.'
#     block_count = None
#     block_start = None
#     block_size = None
#     thickstart = None
#     thickend = None
#
#     #get the name
#     if bed_type in ['bed4', 'bed6', 'bed8', 'bed9', 'bed12']:
#         if not is_number(rec[3]):
#             name = rec[3]
#         else:
#             name = ''
#
#     ##get the strand
#     if bed_type in ['bed6', 'bed8', 'bed9', 'bed12']:
#         if rec[5] not in ["+", "-", "."]:
#             if rec[5] == '1':
#                 strand = "+"
#             elif rec[5] == '-1':
#                 strand = '-'
#             else:
#                 strand = '.'
#         else:
#             strand = rec[5]
#
#     ##get the thick_start and thick_end and subfeature
#     if bed_type in ['bed8', 'bed9', 'bed12']:
#         if is_number(rec[6]) and is_number(rec[7]):
#             #注意thickstart<= thickend; thickstart与start没有明确大小关系:thickstart >= start or thickstart <= start
#             if type(eval(rec[6])) == int and type(eval(rec[7])) == int:
#                 thickstart = int(rec[6])
#                 thickend = int(rec[7])
#                 if thickstart <= start:
#                     thickstart =start
#                 elif thickend >= end:
#                     thickend = end
#             else:
#                 thickstart = None
#                 thickend = None
#         else:
#             thickstart = None
#             thickend = None
#
#     ##get the rgb inform
#     if bed_type in ['bed9', 'bed12']:
#         passed = True
#         try:
#         # This is what happens in UCSC browser:
#             rgb = [0, 0, int(rec[8])]
#         except ValueError:
#             rgb = rec[8].split(",")
#             if len(rgb) == 3:
#                 try:
#                     rgb = list(map(int, rgb))
#                 except ValueError:
#                     passed = False
#                 else:
#                     rgb = rgb
#             else:
#                 passed = False
#         if not passed:
#             rgb = [0, 0, 0]
#         color = deal_rgb(rgb)
#
#     ##get the block data
#     if bed_type == 'bed12':
#         block_count = int(rec[9])
#         block_size = [int(x) for x in rec[10].split(",") if x != '']
#         block_start = [int(x) for x in rec[11].split(",") if x != '']
#     block_pos = get_block_pos(thickstart, thickend, block_count, start, end ,strand, color, block_start, block_size)
#     subfeature = block_pos
#     if len(subfeature) > 1:
#         view_type = ''
#     else:
#         view_type = 'cds'
#     feature_view_array = [name, strand, color, start, end, view_type, subfeature]
#     return feature_view_array
#
#
#
#
#
# # f_view_list = [feature_name,strand, color, start, end, view_type, sub_features]
# # sub_features = [[feature_name,strand, color, start, end, view_type, []], [feature_name,strand, color, start, end, view_type, []],......]
# def parse_records(records):
#     feature_view_array = []
#     ##处理该块没有数据的情况
#     if len(records) > 0:
#         r = records[0]
#         r_len = int(len(r))
#         bed_type = bed_file_type(r, r_len)
#         for record in records:
#             feature_view = parse_bed_record(record, bed_type)
#             feature_view_array.append(feature_view)
#     return feature_view_array
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
#
#
#
#
#
#
#
