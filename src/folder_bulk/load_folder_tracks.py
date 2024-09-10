import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
from old.folder_bulk import track_loader
from track.util import track_util
from util import file_util



data_folder = "/home/sgs/data/"
env_local = "http://localhost:6102/"





# return {track_ext: [file_path, file_path]}
def walk_folder(sp_folder):
    bio_type_dict = {}
    if sp_folder is None or sp_folder == "":
        return bio_type_dict
    for root, ds, fs in os.walk(sp_folder):
        for f in fs:
            track_ext = file_util.get_file_ext(f)
            if track_ext in ["gz", "zip"]:
                compress_file = os.path.join(sp_folder, f)
                decompress_file = file_util.decompress_file(compress_file)
                track_ext = file_util.get_file_ext(decompress_file)
                track_file_path = decompress_file
            else:
                track_file_path = os.path.join(root, f)
            bio_type = track_util.get_bio_type(track_ext)
            if bio_type not in bio_type_dict.keys():
                bio_type_dict[bio_type] = [track_file_path]
            else:
                bio_type_dict[bio_type].append(track_file_path)
    return bio_type_dict





def add_tracks_task(sp_id, folder_name, bio_type_dict):
    for bio_type, track_file_list in bio_type_dict.items():
        # env, sp_id, track_name, track_file
        for track_file in track_file_list:
            track_name = os.path.basename(track_file)
            if bio_type in ["gff_track", "big_track", "hic_track", "bed_track"]:
                track_loader.add_track(env_local, sp_id, track_name, track_file)
            elif bio_type in ["vcf_track"]:
                track_loader.add_vcf_track(env_local, sp_id, track_name, track_file)
            elif bio_type in ["bam_track"]:
                track_loader.add_bam_track(env_local, sp_id, track_name, track_file)
    print("add ", folder_name, " finished")









