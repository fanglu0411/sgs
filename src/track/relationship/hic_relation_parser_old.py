# import pyBigWig
# from util import file_util
#
#
#
#
# def get_file_type(track_file):
#     file_type = "bed" # bed for big
#     # todo 先根据后缀名判断
#     ext = file_util.get_file_ext(track_file)
#     if ext.lower() == "langrange":
#         file_type = "bed"
#     elif ext.lower() == "biginteract":
#         file_type = "big"
#     return file_type
#
#
#
#
# # Mt	280883	281108	4:5669934-5670530,284
# # 1	23332395	23332785	1:18296572-18296927,705
# # 4	13323194	13323860	4:9175545-9176232,950
# # 1	14485182	14485958	5:15537423-15538320,234
# def read_bed_file(bed_file, chr_name_id_dict):
#     reader = None
#     relations = []
#     chr_id_count_dict = {}
#     try:
#         reader = open(bed_file)
#         for line in reader:
#             if line.startswith("#"):
#                 continue
#             else:
#                 tokens = list(line.strip().split("\t"))
#                 chr1_name = str(tokens[0])
#                 chr1_start = int(tokens[1])
#                 chr1_end = int(tokens[2])
#                 chr2_info = str(tokens[3])
#                 chr2_info_list = list(chr2_info.strip().split(":"))
#                 chr2_name = str(chr2_info_list[0])
#                 chr2_start_end = str(chr2_info_list[1])
#                 chr2_start_end_list =  list(chr2_start_end.strip().split("-"))
#                 chr2_start = int(chr2_start_end_list[0])
#                 chr2_end_value = str(chr2_start_end_list[1])
#                 chr2_end_value_list = list(chr2_end_value.strip().split(","))
#                 chr2_end = int(chr2_end_value_list[0])
#                 relation_score = float(chr2_end_value_list[1])
#                 chr1_id = chr_name_id_dict.get(chr1_name)
#                 chr2_id = chr_name_id_dict.get(chr2_name)
#
#                 relation_name = ""
#                 if len(tokens) > 4:
#                     relation_name = str(tokens[4])
#                 relations.append([chr1_id, chr2_id, chr1_start, chr1_end, chr2_start, chr2_end, relation_score, relation_name])
#
#                 if chr1_id in chr_id_count_dict.keys():
#                     chr_id_count_dict[chr1_id] = chr_id_count_dict[chr1_id] + 1
#                 else:
#                     chr_id_count_dict[chr1_id] = 1
#                 if chr2_id in chr_id_count_dict.keys():
#                     chr_id_count_dict[chr2_id] = chr_id_count_dict[chr2_id] + 1
#                 else:
#                     chr_id_count_dict[chr2_id] = 1
#
#     except Exception as e:
#         print(e)
#     finally:
#         if reader:
#             reader.close()
#     return relations, chr_id_count_dict
#
#
#
#
#
#
# # Note that the first three entries in the SQL string are not part of the string
# # b'table interact
# # "interaction between two regions"
# #     (
# #     string chrom;        "Chromosome (or contig, scaffold, etc.). For interchromosomal, use 2 records"
# #     uint chromStart;     "Start position of lower region. For interchromosomal, set to chromStart of this region"
# #     uint chromEnd;       "End position of upper region. For interchromosomal, set to chromEnd of this region"
#
# #     string name;         "Name of item, for display.  Usually \'sourceName/targetName/exp\' or empty"
# #     uint score;          "Score (0-1000)"
# #     uint value;        "Strength of interaction or other data value. Typically basis for score"
# #     string exp;          "Experiment name (metadata for filtering). Use . if not applicable"
# #     string color;        "Item color.  Specified as r,g,b or hexadecimal #RRGGBB or html color name, as in //www.w3.org/TR/css3-color/#html4. Use 0 and spectrum setting to shade by score"
# #     string sourceChrom;  "Chromosome of source region (directional) or lower region. For non-directional interchromosomal, chrom of this region."
# #     uint sourceStart;    "Start position in chromosome of source/lower/this region"
# #     uint sourceEnd;      "End position in chromosome of source/lower/this region"
# #     string sourceName;   "Identifier of source/lower/this region"
# #     string sourceStrand; "Orientation of source/lower/this region: + or -.  Use . if not applicable"
# #     string targetChrom;  "Chromosome of target region (directional) or upper region. For non-directional interchromosomal, chrom of other region"
# #     uint targetStart;    "Start position in chromosome of target/upper/this region"
# #     uint targetEnd;      "End position in chromosome of target/upper/this region"
# #     string targetName;   "Identifier of target/upper/this region"
# #     string targetStrand; "Orientation of target/upper/this region: + or -.  Use . if not applicable"
# #     )
# def read_big_file(big_file, chr_name_id_dict):
#     chr_id_count_dict = {}
#     relations = []
#     bw = None
#     try:
#         bw = pyBigWig.open(big_file)
#         entries = bw.entries("1", 0, 30427671)
#         for e in entries:
#             start = e[0]
#             end = e[1]
#             chr_pair_str = e[2]
#             chr_pair_array = chr_pair_str.strip().split("\t")
#             relation_name = str(chr_pair_array[0])
#             relation_score = float(chr_pair_array[1])
#             chr1_name = str(chr_pair_array[5])
#             chr1_start = int(chr_pair_array[6])
#             chr1_end = int(chr_pair_array[7])
#             chr2_name = str(chr_pair_array[10])
#             chr2_start = int(chr_pair_array[11])
#             chr2_end = int(chr_pair_array[12])
#             chr1_id = chr_name_id_dict.get(chr1_name)
#             chr2_id = chr_name_id_dict.get(chr2_name)
#             relations.append([chr1_id, chr2_id, chr1_start, chr1_end, chr2_start, chr2_end, relation_score, relation_name])
#
#             if chr1_id in chr_id_count_dict.keys():
#                 chr_id_count_dict[chr1_id] = chr_id_count_dict[chr1_id] + 1
#             else:
#                 chr_id_count_dict[chr1_id] = 1
#             if chr2_id in chr_id_count_dict.keys():
#                 chr_id_count_dict[chr2_id] = chr_id_count_dict[chr2_id] + 1
#             else:
#                 chr_id_count_dict[chr2_id] = 1
#     except Exception as e:
#         print(e)
#     finally:
#         if bw:
#             bw.close()
#
#     return relations, chr_id_count_dict
#
#
#
#
