from multiprocessing import Pool




# @DeprecationWarning
# def add_species_old(request):
#     species_name = request.json["species_name"]
#     if "user_id" in request.json:
#         user_id = request.json["user_id"]
#     user_id = "user001" # todo
#     fasta_file = request.json["fasta_file"]
#
#     sp_id = id_util.generate_uuid()
#     if os.path.exists(fasta_file):
#         ext = file_util.get_file_ext(fasta_file)
#         if ext in ["gz", "zip"]:
#             fasta_file = file_util.decompress_file(fasta_file)
#         species_dao.add_species_with_id(sp_id, species_name, fasta_file, "adding")
#         # add_chromosome(fasta_file, sp_id)
#         task_pool = Pool(1)
#         task_pool.apply_async(add_chromosome, args=(fasta_file, sp_id))
#         task_pool.close()
#         return {"species_id": sp_id}
#     else:
#         return {"species_id": "failed"}









