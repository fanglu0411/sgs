import json, pickle, os
from util import file_util




def save_subpopulation(cell_list, cell_subpopulation_file):
    if os.path.exists(cell_subpopulation_file):
        file_util.delete_file(cell_subpopulation_file)
    with open(cell_subpopulation_file, 'wb') as f:
        pickle.dump(cell_list, f)



def get_subpopulation_from_file(cell_subpopulation_file):
    cell_id_list = []
    if os.path.exists(cell_subpopulation_file):
        with open(cell_subpopulation_file, 'rb') as f:
            cell_id_list = pickle.load(f)
    return cell_id_list











