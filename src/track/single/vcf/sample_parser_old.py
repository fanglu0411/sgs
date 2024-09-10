# from pysam.libcbcf import VariantRecordSamples
# from util.id_util import generate_uuid
#
#
#
#
#
# def pos_samples_statistic_old(non_variant_count, homozygous_count, heterozygous_count):
#     all_count = non_variant_count + homozygous_count + heterozygous_count
#     non_variant_percent =  "{:.2%}".format(non_variant_count/all_count)
#     homozygous_percent = "{:.2%}".format(homozygous_count/all_count)
#     heterozygous_percent = "{:.2%}".format(heterozygous_count/all_count)
#     st = {"non-variant": [str(non_variant_count), non_variant_percent], "homozygous": [str(homozygous_count), homozygous_percent], "heterozygous": [str(heterozygous_count), heterozygous_percent]}
#     return st
#
#
#
#
#
#
# def parse_sample_group_old(samples: VariantRecordSamples, feature_name, start, end):
#     non_variant_count = 0
#     homozygous_count = 0
#     heterozygous_count = 0
#     sample_children = []
#     sample_geno_types = []
#     vcf_sample_f_view = []
#     vcf_sample_f_es = []
#     if len(samples.keys()) > 0:
#         for sample_name, sample_values in samples.items():
#             gt_type = ""
#             attributes = []
#             for gt_k, gt_array in sample_values.items():
#                 attributes.append({gt_k: gt_array})
#                 # non-variant=0, homozygous=1, heterozygous=2
#                 if gt_k == "GT":
#                     if gt_array[0] == gt_array[1] == 0:
#                         gt_type = 0
#                         non_variant_count = non_variant_count +1
#                     elif gt_array[0] == gt_array[1] == 1:
#                         gt_type = 1
#                         homozygous_count = homozygous_count +1
#                     else:
#                         gt_type = 2
#                         heterozygous_count = heterozygous_count + 1
#             # "sample_name", "gt_type", "attributes"
#             child_sample_f = [sample_name, gt_type, attributes]
#             sample_children.append(child_sample_f) # todo es
#             sample_geno_types.append(gt_type)
#         sts = pos_samples_statistic_old(non_variant_count, homozygous_count, heterozygous_count)
#         f_id = generate_uuid()
#         vcf_sample_f_view = ["vcf_sample", f_id, feature_name, sts, start, end, sample_geno_types]
#         vcf_sample_f_es = [f_id, feature_name, sts, start, end, sample_children]
#     return vcf_sample_f_view, vcf_sample_f_es
#
#
#
#
#
#
