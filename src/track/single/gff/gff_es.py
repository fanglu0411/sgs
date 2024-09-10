from track.single.gff.parser import record2dict
from track.util import feature_util, dict_util
from track.single.gff.gff_config import gff_gene, gff_transcript







#
# @DeprecationWarning
# def get_records_view_and_es_data(records, chr_id):
#     f_obj_dict = {}
#     for record in records:
#         record2dict.record2feature_object(record, f_obj_dict)
#     # add intron
#     for fo in f_obj_dict.values():
#         bio_type = feature_util.get_bio_type(fo.feature_type)
#         if bio_type == gff_gene:
#             feature_util.build_gene_intron(fo)
#         elif bio_type == gff_transcript:
#             feature_util.build_mRNA_intron(fo)
#     # remove whole_chromosome_feature, child and sub_feature from feature_obj_dict
#     tree_f_obj_dict = {}
#     for fo in f_obj_dict.values():
#         if len(fo.parents_id) == 0:
#             tree_f_obj_dict[fo.feature_id] = fo
#     feature_view_array = []
#     for fo in tree_f_obj_dict.values():
#         fv = dict_util.feature_obj2view_array(fo)
#         feature_view_array.append(fv)
#
#     feature_es_array = []
#     for fo in f_obj_dict.values():
#         fes = dict_util.feature_obj2es_array(fo)
#         feature_es_array.append(fes)
#     return feature_view_array, feature_es_array
#














