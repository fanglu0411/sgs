from track.track_type import gff_track, vcf_track, bam_reads_track, eqtl_track
from db.dao import feature_location_dao, track_dao
from track.single.gff import gff_block
from db.dao import chromosome_dao
from track.single.vcf import vcf_block
from track.single.bam import bam_record_detail
from track.single.eqtl import eqtl_track_processor




# def get_whole_index_data(request):
#     track_id = request.json["track_id"]
#     chr_name = request.json["chr_name"]
#     block_index = request.json["block_index"]
#     index_name = get_index_name(track_id, chr_name, block_index)
#     records, count = es_dao.get_whole_index_data(index_name)
#     return {"index_name": index_name, "records": records, "count": count}





# def get_feature_detail(request):
#     result = {}
#     track_id = request.json["track_id"]
#     chr_id = request.json["chr_id"]
#     block_index = int(request.json["block_index"])
#     feature_id = request.json["feature_id"]
#     track = track_dao.get_track(track_id)
#     chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
#     if track:
#         bio_type = track["bio_type"]
#         if bio_type == gff_track:
#             result = gff_block.get_feature_detail(track_id, chromosome, block_index, feature_id)
#         elif bio_type == vcf_track:
#             result = vcf_block.get_feature_detail(track_id, chromosome, feature_id, block_index)
#             # result = vcf_chr_matrix.get_feature_detail(track_id, chromosome, feature_id, block_index)
#         elif bio_type == bam_reads_track:
#             result = bam_record_detail.get_feature_detail(track_id, chromosome, feature_id, block_index)
#         elif bio_type == eqtl_track:
#             result = eqtl_track_processor.get_snp_detail(track_id, chromosome, feature_id)
#     else:
#         print("no track ", track_id)
#     return result




# def search_gene(request):
#     gene_id = request.json["gene_id"]
#     species_id = request.json["species_id"]
#     r_count = request.json["result_count"]
#     genes = feature_location_dao.search_features_by_type(gene_id, species_id, r_count, "gene")
#     result = []
#     if genes and len(genes) > 0:
#         for gl in genes:
#             gene_dict = {"gene_id": gl["search_name"], "chr_id": gl["chr_id"], "start": gl["ref_start"], "end": gl["ref_end"], "track_id": gl["track_id"]}
#             result.append(gene_dict)
#     return {"genes": result}








