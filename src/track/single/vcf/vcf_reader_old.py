



# def info_str2dict(info_str):
#     info_dict = {}
#     if ";" in info_str:
#         key_value_pairs = info_str.split(";")
#         for key_value_pair in key_value_pairs:
#             if "=" in key_value_pair:
#                 k, v = key_value_pair.split(sep="=", maxsplit=1)
#                 info_dict[k] = v
#     return info_dict



# # validate and parse vcf records
# @fuc_timer
# def read_vcf(vcf_file, coverage_track_id, sample_track_id, has_samples):
#     all_line_count = file_util.iter_count(vcf_file)
#     print("all_line_count", all_line_count)
#     chr_view_names = []
#     chunk_line_count = 0
#     current_line_count = 0
#     chunk_size = 10000
#     coverage_chunk_records = []
#     sample_chunk_records = []
#     chunk_index = 0
#     reader = None
#     coverage_column_header = ["chr_view_name", "feature_id", "feature_name", "pos", "ref_start", "ref_end", "alt_type", "alt_base", "alt", "ref_seq", "qual", "filter", "info"]
#     sample_column_header = ["chr_view_name", "feature_id", "feature_name", "pos", "ref_start", "ref_end", "format", "samples"]
#     coverage_track_hdf5_folder = os.path.join(track_folder, str(coverage_track_id), "hdf5")
#     if not os.path.exists(coverage_track_hdf5_folder):
#         os.makedirs(coverage_track_hdf5_folder)
#     sample_track_hdf5_folder = os.path.join(track_folder, str(sample_track_id), "hdf5")
#     if has_samples:
#         if not os.path.exists(sample_track_hdf5_folder):
#             os.makedirs(sample_track_hdf5_folder)
#     try:
#         reader = open(vcf_file)
#         for line in reader:
#             current_line_count = current_line_count + 1
#             if line.startswith("#"):
#                 continue
#             else:
#                 tokens = list(line.strip().split("\t"))
#                 if len(tokens) < 7:
#                     continue
#                 else:
#                     chunk_line_count = chunk_line_count + 1
#                     chr_view_name = str(tokens[0])
#                     if chr_view_name not in chr_view_names:
#                         chr_view_names.append(chr_view_name)
#                     pos = int(tokens[1])
#                     feature_name = str(tokens[2])
#                     ref_seq = str(tokens[3])
#                     alt = str(tokens[4])
#                     info_str = str(tokens[7])
#                     ref_start, ref_end = alt_parser.parse_start_end(ref_seq, pos, info_str)
#                     f_id = chr_view_name + "_" + str(pos)
#                     alts_dict = alt_parser.parse_alts_type(ref_seq, alt)
#                     filter_str = str(tokens[6])
#                     qual_str = str(tokens[5])
#
#                     for alt_type, alt_base in alts_dict.items():
#                         # ["chr_view_name", "feature_id", "feature_name", "pos", "ref_start", "ref_end", "alt_type", "alt_base", "alt", "ref_seq", "qual", "filter", "info"]
#                         coverage_array = [chr_view_name, f_id, feature_name, pos, ref_start, ref_end, alt_type, alt_base, alt, ref_seq, qual_str, filter_str, info_str]
#                         coverage_chunk_records.append(coverage_array)
#                     if has_samples:
#                         format_str = str(tokens[8])
#                         samples = tokens[9:]
#                         samples_str = ";".join(samples)
#                         sample_record = [chr_view_name, f_id, feature_name, pos, ref_start, ref_end, format_str, samples_str]
#                         sample_chunk_records.append(sample_record)
#
#                     if current_line_count == all_line_count:
#                         # print("====== last line ======")
#                         hdf5_feather.coverage_chunk_records2hdf5(coverage_track_hdf5_folder, coverage_chunk_records, chunk_index, coverage_column_header)
#                         if has_samples:
#                             hdf5_feather.sample_chunk_records2hdf5(sample_track_hdf5_folder, sample_chunk_records, chunk_index, sample_column_header)
#                         chunk_index = chunk_index + 1
#
#                     if chunk_line_count == chunk_size:
#                         chunk_line_count = 0
#                         hdf5_feather.coverage_chunk_records2hdf5(coverage_track_hdf5_folder, coverage_chunk_records, chunk_index, coverage_column_header)
#                         if has_samples:
#                             hdf5_feather.sample_chunk_records2hdf5(sample_track_hdf5_folder, sample_chunk_records, chunk_index, sample_column_header)
#                         # print("chunk_index ", chunk_index, " chr_view_names", chr_view_names)
#                         coverage_chunk_records = []
#                         sample_chunk_records = []
#                         chunk_index = chunk_index + 1
#
#     except Exception as e:
#         print(e)
#         traceback.print_exc()
#         track_dao.update_track_error_msg(coverage_track_id, str(traceback.format_exc()))
#     finally:
#         if reader:
#             reader.close()
#     return coverage_track_hdf5_folder, sample_track_hdf5_folder, chr_view_names
#
#
#
#
# @fuc_timer
# def read_vcf_file(species_id, coverage_track_id, sample_track_id, vcf_file, has_samples):
#     coverage_track_hdf5_folder, sample_track_hdf5_folder, chr_view_names = read_vcf(vcf_file, coverage_track_id, sample_track_id, has_samples)
#     chr_vcf_feather_dict = hdf5_feather.vcf_hdf5_to_chr_feathers(coverage_track_id, chr_view_names, coverage_track_hdf5_folder)
#     for chr_view_name, chr_feather in chr_vcf_feather_dict.items():
#         chr_search_name = track_util.get_chr_search_name(chr_view_name)
#         if has_samples:
#             vcf_block.statistic_chr_coverage_old(species_id, coverage_track_id, chr_feather, chr_search_name, True, sample_track_id, sample_track_hdf5_folder)
#         else:
#             vcf_block.statistic_chr_coverage_old(species_id, coverage_track_id, chr_feather, chr_search_name, False, None, None)
#     return chr_vcf_feather_dict













