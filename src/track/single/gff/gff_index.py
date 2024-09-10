# import pysam, subprocess
# from track.single.gff import gff_path
# from db.dao import track_dao
# from flask import g
# from db.database_init import get_session
#
#
#
#
# # conda install -c bioconda gff3sort
# # --precise   Run in precise mode, about 2X~3X slower than the default mode.
# #             Only needed to be used if your original GFF3 files have parent
# #             features appearing behind their children features.
# # print(os.system('echo $PATH'))
# # gff3sort.pl heihei.gff3 > heihei.gff3.sort
# # bgzip heihei.gff3.sort
# # tabix -p gff heihei.gff3.sort.gz
# def index_gff_file(gff_file, track_id):
#     return_code = 0
#     error_msg = ""
#     try:
#         sort_file, gz_file = gff_path.get_sort_gz_file(gff_file, track_id)
#         # 1 sort bed file
#         # conda install -c bioconda  gff3sort
#         sort_cmd = "/home/conda/bin/gff3sort.pl " + gff_file + " > " + sort_file
#
#         # sort -k1,1 -k4,4n myfile.gff > myfile.sorted.gff
#         # sort_cmd = "sort -k1,1 -k4,4n  " + gff_file + " > " + sort_file
#
#         ret = subprocess.run(sort_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8", timeout=None)
#         return_code = ret.returncode
#         error_msg = ret.stderr
#         if return_code > 0:
#             return return_code, error_msg
#         else:
#             # 2 compress sorted gff file
#             compress_cmd = "/home/conda/bin/bgzip -f " + sort_file
#             ret = subprocess.run(compress_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8", timeout=None)
#             return_code = ret.returncode
#             error_msg = ret.stderr
#             if return_code > 0:
#                 return return_code, error_msg
#             else:
#                 # 3 index  .gff.sorted.gz file
#                 tabix_cmd = "/home/conda/bin/tabix -p gff " + gz_file
#                 ret = subprocess.run(tabix_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8", timeout=None)
#                 return_code = ret.returncode
#                 error_msg = ret.stderr
#     except Exception as e:
#         error_session = get_session()
#         track_dao.update_track_error_msg(error_session, track_id, str(e))
#         if error_session is not None:
#             error_session.remove()
#     return return_code, error_msg
#
#
#
#
# def get_records_from_index_file(track_id, gff_file, chr_name, start, end):
#     records = []
#     gz_file = gff_path.get_sort_gz_file(gff_file, track_id)[1]
#     index_reader = None
#     try:
#         index_reader = pysam.TabixFile(gz_file, encoding='utf-8')
#         for line in index_reader.fetch(reference=chr_name, start=start, end=end, parser=pysam.asGFF3()):
#             records.append(line)
#     except Exception as e:
#         print(e)
#     finally:
#         if index_reader is not None:
#             index_reader.close()
#     return records
#
#
#
#
#
#
#
#
