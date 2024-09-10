# import json
# from util import file_util, id_util
# from track.single.vcf import vcf_index, vcf_path
# from old.track.single.vcf import vcf_block_old, vcf_bigwig_old
# from track.single.vcf.config import expand_block_f_count, vcf_sample_block_f_count
# from multiprocessing import Pool
# from flask import g
# from db.database_init import get_session
# from util.time import fuc_timer
# from db.dao import track_dao, chr_group_track_block_dao, chromosome_dao, chr_group_track_dao
# from track.track_type import vcf_track, vcf_sample_track, vcf_coverage_track, combine_track, single_track
# from track.util import track_util
#
#
#
#
#
# def add_vcf_task(vcf_file, parent_track_id, coverage_track_id, sample_track_id, species_id):
#     g.thread_session = get_session()
#     try:
#         track_dao.update_track_progress(g.session, parent_track_id, "adding", 20, "conversion")
#         chr_records, return_code, error_msg = vcf_bigwig_old.read_vcf_file(vcf_file)
#         if return_code == 0:
#             if len(chr_records.keys()) == 0:
#                 track_dao.delete_track(g.session, coverage_track_id)
#             else:
#                 track_dao.update_track_progress(g.session, parent_track_id, "adding", 30, "vcf conversion")
#                 vcf_bigwig_old.vcf2big(chr_records, coverage_track_id, species_id)
#                 track_dao.update_track_progress(g.session, parent_track_id, "adding", 70, "statistic")
#                 for chr_name, records in chr_records.items():
#                     chr_db_search_name = track_util.get_chr_search_name(chr_name)
#                     chromosome = chromosome_dao.get_chromosome_by_search_name(species_id, chr_db_search_name)
#                     if chromosome:
#                         chr_f_count = len(records)
#                         vcf_block_old.add_block_statistic(coverage_track_id, chromosome.id, chromosome.seq_length, chr_f_count, expand_block_f_count)
#                         if sample_track_id :
#                             chr_group_track_dao.add_chr_group(g.thread_session, sample_track_id, chromosome.id, None, None, None, None)
#                             vcf_block_old.add_block_statistic(sample_track_id, chromosome.id, chromosome.seq_length, chr_f_count, vcf_sample_block_f_count)
#         else:
#             track_dao.update_track_error_msg(g.session, parent_track_id, error_msg)
#         track_dao.update_track_status(g.thread_session, coverage_track_id, "done")
#         if sample_track_id:
#             track_dao.update_track_status(g.thread_session, sample_track_id, "done")
#         track_dao.update_track_progress(g.thread_session, parent_track_id, "done", 100, "add vcf track successful")
#     except Exception as e:
#         error_session = get_session()
#         track_dao.update_track_error_msg(error_session, parent_track_id, str(e))
#         if error_session is not None:
#             error_session.remove()
#     finally:
#         if g.thread_session is not None:
#             g.thread_session.remove()
#
#
#
#
# def add_vcf_track(species_id, track_name, vcf_file):
#     parent_track_id = id_util.generate_uuid()
#     response = {"track_id": parent_track_id}
#     try:
#         track_dao.add_track_with_id(g.session, parent_track_id, species_id, track_name, vcf_track, combine_track, None, "adding", None, "")
#         coverage_track_id = id_util.generate_uuid()
#         track_dao.add_track_with_id(g.session, coverage_track_id, species_id, "", vcf_coverage_track, single_track, "vcf_file",
#                                     "adding", parent_track_id, "")
#         vcf_file = vcf_path.mv_vcf2track_folder(vcf_file, coverage_track_id)
#         track_dao.update_track_file(g.session, coverage_track_id, vcf_file)
#
#         track_dao.update_track_progress(g.session, parent_track_id, "adding", 10, "index vcf file")
#         return_code = vcf_index.index_vcf(vcf_file, parent_track_id)
#         if str(return_code) == "0":
#             sample_track_id = None
#             sample_names_json, sample_names = vcf_index.get_track_header(vcf_file)
#             if len(sample_names) > 0:
#                 sample_track_id = id_util.generate_uuid()
#                 track_dao.add_track_with_id(g.session, sample_track_id, species_id, "", vcf_sample_track, single_track, vcf_file,
#                                             "adding", parent_track_id, sample_names_json)
#             # add_vcf_task(vcf_file, parent_track_id, coverage_track_id, sample_track_id, species_id)
#             task_pool = Pool(1)
#             task_pool.apply_async(add_vcf_task, args=(vcf_file, parent_track_id, coverage_track_id, sample_track_id, species_id) )
#             task_pool.close()
#         else:
#             track_dao.update_track_error_msg(g.session, parent_track_id, "index error")
#     except Exception as e:
#         error_session = get_session()
#         track_dao.update_track_error_msg(error_session, parent_track_id, str(e))
#         if error_session is not None:
#             error_session.remove()
#     return response
#
#
#
#
#
#
# @fuc_timer
# def get_track_data(request):
#     track_id = request.json["track_id"]
#     level = str(request.json["level"])
#     chr_id = request.json["chr_id"]
#     result = {"track_id": track_id, "chr_id": chr_id, "data": []}
#     chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
#     chr_group = chr_group_track_dao.get_chr_group(g.session, track_id, chr_id, None)
#     track = track_dao.get_track(g.session, track_id)
#     if chromosome and track and chr_group:
#         if level == "1":
#             ref_start = int(request.json["ref_start"])
#             ref_end = int(request.json["ref_end"])
#             histo_count = int(request.json["histo_count"])
#             stats_type = "sum"
#             if "stats_type" in request.json:
#                 stats_type = request.json["stats_type"]
#             all_big_stats = vcf_bigwig_old.read_track_chr_bigwigs(track_id, chr_id, ref_start, ref_end, histo_count, stats_type)
#             # histo_header = HistogramVCF.get_header()
#             # result = {"track_id": track_id, "chr_id": chr_id, "data": all_big_stats, "block_start": ref_start, "block_end": ref_end, "header": histo_header}
#             header = {"vcf_type": ["values"]}
#             result = {"data": all_big_stats, "header": header}
#         elif level == "3":
#             block_index = int(request.json["block_index"])
#             block_info = chr_group_track_block_dao.get_chr_statistic(g.session, track_id, chr_id)
#             if block_info:
#                 # session, track_id, chr_id, block_index, group
#                 block = chr_group_track_block_dao.get_chr_group_block(g.session, track_id, chr_id, block_index, None)
#                 if block:
#                     block_data_str = file_util.read_file(block.block_file)
#                     block_data = json.loads(block_data_str)
#                 else:
#                     block_data = vcf_block_old.write_vcf_block_data_old(track, chr_id, chr_group.matrix_chr_name, block_index, block_info.block_step, chromosome.seq_length)
#                 vcf_view_header = ["view_type", "feature_id", "feature_name", "alt_type", "alt_detail", "start", "end"]
#                 result = {"track_id": track_id, "chr_id": chr_id, "header": vcf_view_header, "data": block_data}
#     return result
#
#
#
#
# @fuc_timer
# def get_sample_track_data(request):
#     sample_track_id = request.json["track_id"]
#     chr_id = request.json["chr_id"]
#     block_index = int(request.json["block_index"])
#     result = {"sample_track_id": sample_track_id, "chr_id": chr_id, "data": []}
#
#     chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
#     chr_group = chr_group_track_dao.get_chr_group(g.session, sample_track_id, chr_id, None)
#     sample_track = track_dao.get_track(g.session, sample_track_id)
#     if chromosome and sample_track:
#         block_info = chr_group_track_block_dao.get_chr_statistic(g.session, sample_track_id, chr_id)
#         if block_info:
#             sample_block = chr_group_track_block_dao.get_chr_group_block(g.session, sample_track_id, chr_id, block_index, None)
#             if sample_block:
#                 block_data_str = file_util.read_file(sample_block.block_file)
#                 block_data = json.loads(block_data_str)
#                 sample_features = block_data.get("sample_features")
#                 sample_names = block_data.get("sample_names")
#             else:
#                 sample_names, sample_features = vcf_block_old.write_sample_block_data_old(sample_track_id, chr_id, chr_group.matrix_chr_name,
#                                                                                           block_index, block_info.block_step, chromosome.seq_length)
#             header = ["view_type", "feature_id", "feature_name", "statistic", "start", "end", "sample_geno_types"]
#             sample_geno_type_code = {"variant": 0, "homozygous": 1, "heterozygous": 2}
#             result = {"header": header, "sample_geno_type_code": sample_geno_type_code, "data": sample_features, "sample_names": sample_names}
#     return result
#
#
#
#
# def get_vcf_track_statistics(coverage_track):
#     statistics = []
#     if coverage_track.status == "done":
#         chromosomes = chr_group_track_dao.get_track_chromosomes(g.list_session, coverage_track.id)
#         if len(chromosomes) > 0:
#             for chromosome in chromosomes:
#                 block_info = chr_group_track_block_dao.get_chr_statistic(g.list_session, coverage_track.id, chromosome.id)
#                 statistic = {"chr_id": chromosome.id, "feature_count": block_info.feature_count, "average_f_length": block_info.average_feature_length}
#                 # block_info = chr_track_block_dao.get_track_chr_block_info(g.session, track_chr.chr_id, track.id, expand_feature_block_type)
#                 # if block_info:
#                 #     statistic["expand_block_count"] = block_info.block_count
#                 #     statistic["expand_block_step"] = block_info.block_step
#                 statistics.append(statistic)
#     return statistics
#
#
#
#
# def get_sample_track_statistics(sample_track):
#     statistics = []
#     if sample_track.status == "done":
#         chromosomes = chr_group_track_dao.get_track_chromosomes(g.list_session, sample_track.id)
#         if len(chromosomes) > 0:
#             for chromosome in chromosomes:
#                 block_info = chr_group_track_block_dao.get_chr_statistic(g.list_session, sample_track.id, chromosome.id)
#                 statistic = {"chr_id": chromosome.id, "feature_count": block_info.feature_count, "average_f_length": block_info.average_feature_length}
#                 statistics.append(statistic)
#     return statistics
#
#
#
#
# # def sample_csv2feather(species_id, sample_track_id, chr_csv_file_dict, sample_names):
# #     chr_feather_file_dict = {}
# #     for chr_view_name, chr_csv_file in chr_csv_file_dict.items():
# #         chr_feather_file = chr_csv_file.replace(".csv", ".feather")
# #         chr_df = pd.read_csv(chr_feather_file)
# #         sample_columns = ["chr_view_name", "feature_id", "feature_name", "pos", "ref_start", "ref_end", "format"]
# #         sample_columns.extend(sample_names)
# #         chr_df.columns = sample_columns
# #         chr_df.sort_values("pos", inplace=True)
# #         vcf_block.statistic_chr_sample(species_id, sample_track_id, chr_df, chr_feather_file, chr_view_name)
# #         chr_feather_file_dict[chr_view_name] = chr_feather_file
# #         feather.write_feather(chr_df, chr_feather_file, compression='lz4')
# #         file_util.delete_file(chr_csv_file)
# #
# #         # print(chr_view_name, "sample_csv2feather")
# #         # print(u'当前进程的内存使用：%.4f GB' % (psutil.Process(os.getpid()).memory_info().rss / 1024 / 1024 / 1024))
# #         # info = psutil.virtual_memory()
# #         # print(u'电脑总内存：%.4f GB' % (info.total / 1024 / 1024 / 1024))
# #
# #     return chr_feather_file_dict
#
#
#
# # def coverage_csv2feather(species_id, coverage_track_id, chr_csv_file_dict):
# #     chr_feather_file_dict = {}
# #     for chr_view_name, chr_csv_file in chr_csv_file_dict.items():
# #         start_time = time.time()
# #         chr_search_name = track_util.get_chr_search_name(chr_view_name)
# #         chr_feather_file = chr_csv_file.replace(".csv", ".feather")
# #         chr_df = pd.read_csv(chr_csv_file)
# #         chr_df.dropna(axis=0, how="any")
# #         chr_df.columns = ["feature_id", "feature_name", "pos", "ref_start", "ref_end", "alt_type", "alt_base", "alt", "ref_seq", "qual", "filter", "info"]
# #         vcf_block.statistic_chr_coverage(species_id, coverage_track_id, chr_df, chr_feather_file, chr_search_name)
# #         # split info column
# #         chr_info_dict_list = []
# #         chr_info_str_list = pd.Series.to_list(chr_df["info"])
# #         for info_str in chr_info_str_list:
# #             info_dict = hdf5_feather.info_str2dict(info_str)
# #             chr_info_dict_list.append(info_dict)
# #         chr_info_df = pd.DataFrame(chr_info_dict_list)
# #         chr_df = pd.concat([chr_df, chr_info_df], axis=1)
# #         chr_df.sort_values("pos", inplace = True)
# #         chr_feather_file_dict[chr_view_name] = chr_feather_file
# #         feather.write_feather(chr_df, chr_feather_file, compression='lz4')
# #
# #         # file_util.delete_file(chr_csv_file)
# #
# #         print(chr_view_name, " coverage_csv2feather")
# #         print(u'当前进程的内存使用：%.4f GB' % (psutil.Process(os.getpid()).memory_info().rss / 1024 / 1024 / 1024))
# #         info = psutil.virtual_memory()
# #         print(u'电脑总内存：%.4f GB' % (info.total / 1024 / 1024 / 1024))
# #
# #         cost_time = time.time() - start_time
# #         print("coverage_csv2feather  %s cost %s second" % ("bed2big", cost_time))
# #         print(chr_csv_file, " %s cost %s second" % (" coverage_csv2feather ", cost_time))
# #     return chr_feather_file_dict
#


# def add_vcf_track_old(species_id, parent_track_id, vcf_file):
#     track_dao.update_track_view_type(parent_track_id, combine_track)
#     try:
#         # coverage feather track
#         coverage_track_id = id_util.generate_uuid()
#         track_dao.add_track_with_id(coverage_track_id, species_id, "", vcf_coverage_track, single_track, None,   "adding", parent_track_id, "")
#         track_dao.update_track_progress(parent_track_id, "adding", 10, "validate vcf file")
#         sample_names_json, sample_names = vcf_reader.get_track_header(vcf_file)
#         sample_track_id = id_util.generate_uuid()
#         has_samples = False
#         if len(sample_names):
#             has_samples = True
#             track_dao.add_track_with_id(sample_track_id, species_id, "", vcf_sample_track, single_track, None,  "adding", parent_track_id, sample_names_json)
#         # chr_feather_dict[chr_view_name] = chr_feather_file
#         # index vcf file
#         vcf_index.index_vcf(vcf_file, parent_track_id)
#         chr_vcf_feather_dict = vcf_reader.read_vcf_file(species_id, parent_track_id, coverage_track_id, sample_track_id, vcf_file, has_samples)
#         if len(chr_vcf_feather_dict.keys()) > 0:
#             track_dao.update_track_progress(parent_track_id, "adding", 30, "generate bigwig")
#             vcf_bigwig.vcf2bigwig_old(species_id, coverage_track_id, chr_vcf_feather_dict)
#             track_dao.update_track_status(coverage_track_id, "done")
#             if has_samples :
#                 track_dao.update_track_status(sample_track_id, "done")
#         track_dao.update_track_progress(parent_track_id, "done", 100, "add vcf track successful")
#
#     except Exception as e:
#         traceback.print_exc()
#         track_dao.update_track_error_msg(parent_track_id, str(traceback.format_exc()))





































