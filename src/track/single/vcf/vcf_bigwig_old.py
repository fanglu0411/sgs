# from pysam import VariantFile
# from track.single.vcf import vcf_path
# import time, json, pyBigWig
# from track.util import track_util
# from flask import g
# from db.dao import chr_group_track_dao, chromosome_dao
#
#
# def get_start_end_type(vcf_record):
#     records = []
#     alts = vcf_record.alts
#     ref = vcf_record.ref
#     if vcf_record.info.get('END') is not None:
#         start = vcf_record.pos
#     else:
#         start = vcf_record.pos - 1
#     if vcf_record.info.get('END') is not None:
#         end = vcf_record.info.get("END")
#     else:
#         end = vcf_record.pos - 1 + len(vcf_record.ref)
#     for alt_str in alts:
#         alt_type = ""
#         if "]" in alt_str or "[" in alt_str:
#             alt_type = "SV"
#         elif alt_str[0] == "." and len(alt_str) > 0:
#             alt_type = "BND"
#         elif alt_str[-1] == "." and len(alt_str) > 0:
#             alt_type = "BND"
#         elif alt_str[0] == "<" and alt_str[-1] == ">":
#             alt_type = "SV"
#         elif len(ref) == len(alt_str):
#             if len(ref) == 1 and ref[0] != alt_str[0]:
#                 alt_type = "SNV"
#             else:
#                 alt_type = "MNV"
#         elif len(ref) > len(alt_str):
#             alt_type = "DEL"
#         elif len(ref) < len(alt_str):
#             alt_type = "INS"
#         records.append([start, end, alt_type])
#     return records
#
#
#
#
# def read_vcf_file(vcf_file):
#     chr_records = {}
#     line_num = 0
#     return_code = 0
#     error_msg = ""
#     reader = None
#     try:
#         reader = VariantFile(vcf_file, "r")
#         for rec in reader.fetch():
#             line_num = line_num + 1
#             chr_name = rec.chrom
#             alt_records = get_start_end_type(rec)
#             if chr_name in chr_records.keys():
#                 for alt_record in alt_records:
#                     chr_records.get(chr_name).append(alt_record)
#             else:
#                 chr_records[chr_name] = alt_records
#     except Exception as e:
#         print(e)
#         return_code = 1
#         error_msg = "gff parse error at line " + str(line_num)
#     finally:
#         if reader:
#             reader.close()
#     return chr_records, return_code, error_msg
#
#
#
#
# def init_sub_big_writer_dict(sub_big_key, sub_big_writer_dict, sub_big_file_dict, track_id, chromosome, matrix_chr_name):
#     if sub_big_key not in sub_big_writer_dict:
#         big_file = vcf_path.get_split_big_file(track_id, matrix_chr_name, sub_big_key)
#         sub_big_file_dict[sub_big_key] = big_file
#         bw = pyBigWig.open(big_file, "w")
#         bw.addHeader([(matrix_chr_name, chromosome.seq_length)], maxZooms=0)
#         sub_big_writer_dict[sub_big_key] = bw
#
#
#
# def add_sub_big(chromosome, track_id, matrix_chr_name, sub_big_key, big_file):
#     reader = pyBigWig.open(big_file)
#     max_value = reader.stats(matrix_chr_name, 0, chromosome.seq_length, type="sum")
#     statistic = {"max": max_value}
#     statistic = json.dumps(statistic)
#     reader.close()
#     chr_group_track_dao.add_chr_group(g.thread_session, track_id,  chromosome.id, sub_big_key, big_file, statistic, None)
#
#
#
# # sub_big_interval is  {sub_big_key: {pos1: deep1, pos2: deep2}}
# def sum_sub_record_deeps(sub_big_type, sub_big_interval: dict, start, end):
#     # big_interval is  {pos1: deep1, pos2: deep2}
#     if sub_big_type in sub_big_interval.keys():
#         big_interval = sub_big_interval.get(sub_big_type)
#     else:
#         big_interval = {}
#         sub_big_interval[sub_big_type] = big_interval
#     for i in range(start, end):
#         if i in big_interval:
#             big_interval[i] = big_interval[i] + 1
#         else:
#             big_interval[i] = 1
#
#
#
# def write_intervals(intervals, sub_big_writer, chr_name):
#     chr_name_list = []
#     start_list = []
#     end_list = []
#     value_list = []
#     for pos, deep in intervals.items():
#         chr_name_list.append(chr_name)
#         start_list.append(pos)
#         end_list.append(pos+1)
#         value_list.append(float(deep))
#         # sub_big_writer.addEntries([chr_name], [pos], ends=[pos+1], values=[float(deep)])
#     sub_big_writer.addEntries(chr_name_list, start_list, end_list, values=value_list)
#     sub_big_writer.close()
#
#
#
# def vcf2big(chr_records, track_id, species_id):
#     fuc_start = time.time()
#     for chr_name, records in chr_records.items():
#         # {sub_big_key1: {pos1: deep1, pos2: deep2}, sub_big_key2: {pos1: deep1, pos2: deep2} }
#         sub_big_interval = {}
#         # {sub_big_key: sub_big_writer}
#         sub_big_writer_dict = {}
#         sub_big_file_dict = {}
#         chr_db_search_name = track_util.get_chr_search_name(chr_name)
#         chromosome = chromosome_dao.get_chromosome_by_search_name(species_id, chr_db_search_name)
#         if chromosome and chromosome.seq_length > 0:
#             # init chr bigwig writer
#             for rec in records:
#                 start = rec[0]
#                 end = rec[1]
#                 vcf_type = rec[2]
#                 # sum_sub_record_deeps(chr_name, sub_big_interval, start, end)
#                 sum_sub_record_deeps(vcf_type, sub_big_interval, start, end)
#                 # init chr big_type bigwig writer
#                 init_sub_big_writer_dict(vcf_type, sub_big_writer_dict, sub_big_file_dict, track_id, chromosome, chr_name)
#             for sub_big_key, intervals in sub_big_interval.items():
#                 sub_big_writer = sub_big_writer_dict.get(sub_big_key)
#                 write_intervals(intervals, sub_big_writer, chr_name)
#
#             # save to table
#             for sub_big_key, sub_big_file in sub_big_file_dict.items():
#                 add_sub_big(chromosome, track_id, chr_name, sub_big_key, sub_big_file)
#
#     cost_time = time.time() - fuc_start
#     print(track_id, " %s cost %s second" % ("vcf2big", cost_time))
#
#
#
#
#
# def read_track_chr_bigwigs(track_id, chr_id, start, end, histo_count, stats_type):
#     all_big_stats = {}
#     sub_bigs = chr_group_track_dao.get_chr_all_group(g.session, track_id, chr_id)
#     for sub_big in sub_bigs:
#         big_type = sub_big.group_name
#         big_file = sub_big.group_track_file
#         chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
#         chr_group = chr_group_track_dao.get_chr_group(g.session, track_id, chr_id, None)
#         big_reader = pyBigWig.open(big_file)
#         if end > (chromosome.seq_length - 1):
#             end = chromosome.seq_length - 1
#         stats = big_reader.stats(chr_group.matrix_chr_name, start, end, type=stats_type, nBins=histo_count)
#         all_big_stats[big_type] = stats
#         big_reader.close()
#     return all_big_stats
#
#
#
#
#
#
# @fuc_timer
# def vcf2bigwig_old(species_id, track_id, chr_coverage_feather_dict):
#     for chr_view_name, chr_feather in chr_coverage_feather_dict.items():
#         chr_search_name = track_util.get_chr_search_name(chr_view_name)
#         chromosome = chromosome_dao.get_chromosome_by_search_name(species_id, chr_search_name)
#         to_bigwig_df = feather.read_feather(chr_feather, columns=["alt_type", "pos"], memory_map=True)
#         to_bigwig_df["End"] = to_bigwig_df["pos"] + 1
#         to_bigwig_df = to_bigwig_df.rename(columns={"pos": "Start"})
#         to_bigwig_df["Chromosome"] = chr_view_name
#         alt_type_dfs = {k: v for k, v in to_bigwig_df.groupby("alt_type")}
#         for alt_type, alt_type_df in alt_type_dfs.items():
#             sub_df = alt_type_df[["Chromosome", "Start", "End"]]
#             # df_split = coverage_util.split_range(sub_df)
#             # df_split = df_split[["Chromosome", "Start", "End"]]
#             chr_df_result = coverage_util.count_coverage(sub_df, sub_df, "count")
#             sub_big_file = vcf_path.get_split_big_file(track_id, chromosome["search_name"], alt_type)
#             coverage_util.df2bigwig(chr_df_result, sub_big_file, chromosome["seq_length"], chr_view_name)
#             reader = pyBigWig.open(sub_big_file)
#             max_value = reader.stats(chr_view_name, 0, chromosome["seq_length"], type="sum")
#             statistic = {"max": max_value}
#             statistic = json.dumps(statistic, cls=JsonEncoder)
#             reader.close()
#             chr_group_track_dao.add_chr_group(track_id, chromosome["id"], alt_type, sub_big_file, statistic, None)
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