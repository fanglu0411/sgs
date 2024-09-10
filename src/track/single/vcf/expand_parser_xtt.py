# from pysam import VariantRecord
# from pysam.libcbcf import VariantRecordInfo
# from old.track.single.vcf import sample_parser_old
# from util.id_util import generate_uuid
#
#
#
#
# def parse_alts(ref, alts):
#     alt_dict = {}
#     if len(alts) > 0:
#         for alt_str in alts:
#             alt_type = ""
#             if "]" in alt_str or "[" in alt_str:
#                 alt_type = "SV"
#             elif alt_str[0] == "." and len(alt_str) > 0:
#                 alt_type = "SV:BND"
#             elif alt_str[-1] == "." and len(alt_str) > 0:
#                 alt_type = "SV:BND"
#             elif alt_str[0] == "<" and alt_str[-1] == ">":
#                 alt_type = "SV"
#             elif len(ref) == len(alt_str):
#                 if len(ref) == 1 and ref[0] != alt_str[0]:
#                     alt_type = "SNV"
#                 else:
#                     alt_type = "substitution"
#             elif len(ref) > len(alt_str):
#                 alt_type = "deletion"
#             elif len(ref) < len(alt_str):
#                 alt_type = "insertion"
#             alt_content = ref + "->" + alt_str
#             if alt_type in alt_dict.keys():
#                 alt_dict.get(alt_type).append(alt_content)
#             else:
#                 alt_dict[alt_type] = [alt_content]
#     return alt_dict
#
#
#
# def parse_primary_data(record: VariantRecord, name, start, end, alt_dict):
#     length = str(end - start) + " bp"
#     position_info = record.chrom + ":" + str(start) + ".." + str(end)
#     alt_type_list = []
#     alt_desc_list = []
#     for k, v in alt_dict.items():
#         alt_type_list.append(k)
#         desc = k + ":" + str(v)
#         alt_desc_list.append(desc)
#     alt_type = str(",".join(alt_type_list))
#     desc = str(",".join(alt_desc_list))
#     primary_data = {"Name": name, "Seq ID": record.chrom, "Type": alt_type, "Description": desc, "Position": position_info, "Length": length, "Score": record.qual}
#     return primary_data
#
#
#
# def parse_attributes(rec_info: VariantRecordInfo):
#     attr_info = {}
#     for k, v in rec_info.items():
#         attr_info[k] = v
#     return attr_info
#
#
#
# def parse_desc(record, feature_name, start, end, alt_dict):
#     primary_data = parse_primary_data(record, feature_name, start, end, alt_dict)
#     attributes = parse_attributes(record.info)
#     desc = {"Primary Data": primary_data, "Attributes": attributes}
#     return desc
#
#
#
# def parse_records(records):
#     fs_view = []
#     fs_es = []
#     for rec in records:
#         feature_name = rec.id
#         f_id = generate_uuid()
#
#         alts_dict = parse_alts(rec.ref, rec.alts)
#         alt_types = ",".join(alts_dict.keys())
#         if rec.info.get('END') is not None:
#             start = rec.pos
#         else:
#             start = rec.pos - 1
#         if rec.info.get('END') is not None:
#             end = rec.info.get("END")
#         else:
#             end = rec.pos - 1 + len(rec.ref)
#         if feature_name is None:
#             feature_name = alt_types + str(start) + ".." + str(end)
#         desc = parse_desc(rec, feature_name, rec.start, rec.stop, alts_dict)
#
#         # "view_type", "feature_id", "feature_name", "alt_type", "alt_detail", "start", "end"
#         f_view_array = ["vcf", f_id, feature_name, alt_types, alts_dict, start, end]
#
#         # "feature_id", "feature_name", "alt_type", "alt_detail", "start", "end", "desc"
#         f_es_array = [f_id, feature_name, alt_types, alts_dict, start, end, desc]
#         fs_view.append(f_view_array)
#         fs_es.append(f_es_array)
#     return fs_view, fs_es
#
#
#
# def parse_record_sample(rec):
#     feature_name = rec.id
#     alts = parse_alts(rec.ref, rec.alts)
#     alt_type = ",".join(alts.keys())
#     if rec.info.get('END') is not None:
#         start = rec.pos
#     else:
#         start = rec.pos - 1
#     if rec.info.get('END') is not None:
#         end = rec.info.get("END")
#     else:
#         end = rec.pos - 1 + len(rec.ref)
#     if feature_name is None:
#         feature_name = alt_type + str(start) + ".." + str(end)
#     sample_feature, sample_f_es = sample_parser_old.parse_sample_group_old(rec.samples, feature_name, start, end)
#     return sample_feature, sample_f_es
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
