# from track.single.vcf.parser import expand_parser
# from es.es_vcf import add_block_records, add_block_samples
# from multiprocessing import Pool
# import json
# from pysam import VariantFile
# from db.dao import track_dao, chr_group_track_block_dao
# from util import file_util
# from flask import g
# from util.time import fuc_timer
# from track.util import abstract_block_util
# from track.single.vcf import vcf_path
# from track import track_type
# from flask import g
# import json, os
# from db.dao import feature_location_dao, chr_group_track_block_dao, track_dao, chromosome_dao
# import pyarrow.feather as feather
# from track.single.vcf.parser import sample_parser, alt_parser
# from track.track_type import vcf_sample_track, vcf_coverage_track
# import pandas as pd
#
#
#
#
#
#
# block_f_count = 200
#
#
#
# def add_sample_block_statistic(track_id, chr_id, ref_length, chr_f_count, chr_feather_file):
#     average_feature_length = 1
#     block_length = (ref_length//chr_f_count + 1) * block_f_count
#     block_count = ref_length // block_length + 1
#     chr_group_track_block_dao.add_statistic(g.thread_session, track_id, chr_id, None, block_count, block_length, chr_f_count, average_feature_length, chr_feather_file)
#     return block_length, block_count
#
#
#
#
# @DeprecationWarning
# def write_vcf_block_data_old(track, chr_id, chr_name, block_index, block_step, ref_length):
#     fs_view = []
#     reader = None
#     try:
#         gz_file = vcf_path.get_gz_index_file(track)[0]
#         reader = VariantFile(gz_file, "r")
#         block_start = block_step * block_index
#         block_end = block_start + block_step
#         if block_end > ref_length:
#             block_end = ref_length
#         records = reader.fetch(contig=chr_name, start=block_start, end=block_end)
#         fs_view, fs_es = expand_parser.parse_records(records)
#         block_data_str = json.dumps(fs_view)
#         expand_block_folder = vcf_path.get_expand_block_folder(track.id, chr_name)
#         block_file = abstract_block_util.write_expand_block_file(expand_block_folder, str(block_index), block_data_str)
#         chr_group_track_block_dao.add_block(g.session, track.id, chr_id, None, block_start, block_end, block_index, block_file, "full")
#
#         # es
#         # add_block_records(track_id, chr_name, fs_es)
#         task_pool = Pool(1)
#         task_pool.apply_async(add_block_records, args=(track.id, chr_name, fs_es))
#         task_pool.close()
#     except Exception as e:
#         print(e)
#     finally:
#         if reader:
#             reader.close()
#     return fs_view
#
#
#
#
#
# @fuc_timer
# def write_sample_block_data_old(sample_track_id, chr_id, chr_name, block_index, block_step, ref_length):
#     sample_names = []
#     sample_features = []
#     sample_fs_es = []
#     sample_track = track_dao.get_track(g.session, sample_track_id)
#     children_tracks = track_dao.get_children_tracks(g.session, sample_track.parent_id)
#     for c in children_tracks:
#         if c.bio_type == track_type.vcf_coverage_track:
#             vcf_track = c
#             block_start = block_step * block_index
#             block_end = block_start + block_step
#             if block_end > ref_length:
#                 block_end = ref_length
#             gz_file = vcf_path.get_gz_index_file(vcf_track)[0]
#             reader = None
#             try:
#                 sample_names = json.loads(sample_track.header)
#                 reader = VariantFile(gz_file, "r")
#                 records = reader.fetch(contig=chr_name, start=block_start, end=block_end)
#                 for rec in records:
#                     sample_feature, sample_f_es = expand_parser.parse_record_sample(rec)
#                     sample_features.append(sample_feature)
#                     sample_fs_es.append(sample_f_es)
#                 block_data = {"sample_names": sample_names, "sample_features": sample_features}
#                 block_data_str = json.dumps(block_data)
#                 expand_block_folder = vcf_path.get_expand_block_folder(sample_track_id, chr_name)
#                 block_file = abstract_block_util.write_expand_block_file(expand_block_folder, str(block_index), block_data_str)
#                 file_util.write_file(block_file, block_data_str)
#                 chr_group_track_block_dao.add_block(g.session, sample_track_id, chr_id, None, block_start, block_end, block_index, block_file, "full")
#                 # es
#                 add_block_samples(sample_track.id, chr_name, sample_fs_es)
#                 # task_pool = Pool(1)
#                 # task_pool.apply_async(add_block_samples, args=(sample_track.id, chr_name, sample_fs_es))
#                 # task_pool.close()
#             except Exception as e:
#                 print(e)
#             finally:
#                 if reader:
#                     reader.close()
#     return sample_names, sample_features
#
#
#
#
# def get_feature_detail(parent_track_id, chromosome, feature_id, block_index):
#     result = {}
#     sub_tracks = track_dao.get_children_tracks(g.session, parent_track_id)
#     if len(sub_tracks) == 1:
#         coverage_track = sub_tracks[0]
#         chr_block = chr_group_track_block_dao.get_chr_statistic(g.session, coverage_track.id, chromosome.id)
#         if chr_block:
#             chr_matrix_file = chr_block.block_source_file
#             if os.path.exists(chr_matrix_file):
#                 chr_df = feather.read_feather(chr_matrix_file, memory_map=True)
#                 feature_df = chr_df[chr_df["feature_id"] == feature_id]
#                 match_features = feature_df.values.tolist()
#                 result = get_vcf_coverage_track_detail(match_features, chromosome.view_name)
#     elif len(sub_tracks) == 2:
#         coverage_track = None
#         sample_track = None
#         for t in sub_tracks:
#             if t.bio_type == vcf_coverage_track:
#                 coverage_track = t
#             elif t.bio_type == vcf_sample_track:
#                 sample_track = t
#         sample_names = json.loads(sample_track.header)
#         coverage_chr_block = chr_group_track_block_dao.get_chr_statistic(g.session, coverage_track.id, chromosome.id)
#         sample_chr_block = chr_group_track_block_dao.get_chr_statistic(g.session, sample_track.id, chromosome.id)
#         if coverage_chr_block:
#             chr_coverage_matrix_file = coverage_chr_block.block_source_file
#             if os.path.exists(chr_coverage_matrix_file):
#                 coverage_feature_df = feather.read_feather(chr_coverage_matrix_file, memory_map=True)
#                 coverage_feature_df = coverage_feature_df[coverage_feature_df["feature_id"] == feature_id]
#                 match_coverage_features = coverage_feature_df.values.tolist()
#                 result = get_vcf_coverage_track_detail(match_coverage_features, chromosome.view_name)
#                 if sample_chr_block:
#                     chr_sample_matrix_file = sample_chr_block.block_source_file
#                     sample_feature_df = feather.read_feather(chr_sample_matrix_file, memory_map=True)
#                     sample_feature_df = sample_feature_df[sample_feature_df["feature_id"] == feature_id]
#                     match_sample_features = sample_feature_df.values.tolist()
#                     sample_info_dict = get_vcf_sample_track_detail(match_sample_features[0], sample_names)
#                     result["sample_info"] = sample_info_dict
#     return result
#
#
#
#
# def get_vcf_sample_track_detail(sample_line, sample_names):
#     variant_statistic, genotype_info = sample_parser.sample_line2detail_feature(sample_line, sample_names)
#     sample_info_dict = {"variant statistic": variant_statistic, "genotype info": genotype_info}
#     return sample_info_dict
#
#
#
#
#
# def statistic_chr_coverage_old(species_id, coverage_track_id, chr_coverage_feather, chr_search_name, has_samples, sample_track_id, sample_track_hdf5_folder):
#     chromosome = chromosome_dao.get_chromosome_by_search_name(species_id, chr_search_name)
#     if chromosome:
#         chr_coverage_df = feather.read_feather(chr_coverage_feather, memory_map=True)
#         chr_f_count = int(chr_coverage_df.shape[0])
#         ss = chr_coverage_df["ref_end"] - chr_coverage_df["ref_start"]
#         chr_average_f_length = int(ss.mean())
#         block_length = (chromosome["seq_length"] // chr_f_count + 1) * block_f_count
#         block_count = chromosome["seq_length"] // block_length + 1
#         chr_group_track_block_dao.add_statistic(coverage_track_id, chromosome["id"], None, block_count, block_length, chr_f_count, chr_average_f_length, chr_coverage_feather)
#         if has_samples:
#             chr_group_track_dao.add_chr_group(sample_track_id, chromosome["id"], None, None, None, None)
#             chr_group_track_block_dao.add_statistic(sample_track_id, chromosome["id"], None, block_count, block_length, chr_f_count, chr_average_f_length, sample_track_hdf5_folder)
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


