from old.folder_bulk.load_folder_tracks import walk_folder, add_tracks_task
from db.dao import species_dao
from track.single.fasta.chromosome_processor import add_chromosome
from util import id_util





def add_species_folder(request):
    folder_path = request.json["folder_path"]
    species_name = request.json["species_name"]
    bio_type_dict = walk_folder(folder_path)

    sp_id = id_util.generate_uuid()
    result = {"species_id": sp_id}
    if "fasta_track" in bio_type_dict.keys():
        sp_file_path = bio_type_dict["fasta_track"][0]
        # add species
        species_dao.add_species_with_id(sp_id, species_name, sp_file_path, "adding")
        add_chromosome(sp_file_path, sp_id)

        add_tracks_task(sp_id, folder_path, bio_type_dict)

        # task_pool = Pool(1)
        # task_pool.apply_async(add_tracks_task, args=(sp_id, folder_path, bio_type_dict))
        # task_pool.close()
    else:
        result = {"error": "no fasta file"}
    return result











