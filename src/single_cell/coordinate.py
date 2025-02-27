import json, gc
import os.path
from db.dao.sc import single_cell_mod_dao, single_cell_3d_dao
import numpy as np
from single_cell import feature_search
import pyarrow.feather as feather
from track.util.dict_util import JsonEncoder
from util import file_util, id_util
from path_config import data_folder




# 获取某一注释类型的坐标
def get_annotation_coord(mod_id, annotation_name, coord_key):
    result = {}
    mod_db = single_cell_mod_dao.get_single_cell_mod(mod_id)
    if mod_db:
        sc_3d_db = single_cell_3d_dao.get_single_cell_3d(mod_id, coord_key, annotation_name)
        obs_file = mod_db["obs_file"]
        if obs_file:
            # sgs_cell_id, umap_x, umap_y, pca_x, pca_y, cell_name, cell_type, sample_source, experimental_condition, batch  ...
            target_columns = ["sgs_cell_id", annotation_name, coord_key+"_x", coord_key+"_y"]
            if sc_3d_db:
                target_columns = ["sgs_cell_id", annotation_name, coord_key + "_x", coord_key + "_y", coord_key + "_z"]
            coord_obs_df = feather.read_feather(obs_file, columns=target_columns, memory_map=True)
            if not coord_obs_df.empty:
                gv_dict = json.loads(mod_db["cell_meta_columns_group_value"])
                column_group_dict = gv_dict[annotation_name]
                if column_group_dict["type"] == "list": # "Cluster": {"type": "list", "value": ["3T3", "Oli-neu_1", ...]}
                    group_values = column_group_dict["value"]
                    header_name = ["cell", coord_key + "_x", coord_key + "_y"]
                    if sc_3d_db:
                        header_name = ["cell", coord_key + "_x", coord_key + "_y", coord_key + "_z"]
                    result["cell_plot_header"] = {"group": header_name}

                    # 耗时部分 start
                    cell_plot_data_dict = {}
                    for group_value in group_values:
                        sub_df = coord_obs_df[coord_obs_df[annotation_name] == group_value]
                        if sc_3d_db:
                            sub_df = sub_df[["sgs_cell_id", coord_key + "_x", coord_key + "_y", coord_key + "_z"]]
                        else:
                            sub_df = sub_df[["sgs_cell_id", coord_key + "_x", coord_key + "_y"]]
                        cell_plot_data_dict[group_value] = sub_df.values.tolist()
                    result["cell_plot_data"] = cell_plot_data_dict
                    # 耗时部分 end
                elif column_group_dict["type"] == "num":  # "gene_count": {"type": "num", "value": [10, 200]}
                    header_name = ["cell", "value", coord_key + "_x", coord_key + "_y"]
                    if sc_3d_db:
                        header_name = ["cell", "value", coord_key + "_x", coord_key + "_y", coord_key + "_z"]
                    result["cell_plot_header"] = header_name
                    cell_plot_data = {"scope": column_group_dict["value"], "coord": coord_obs_df.values.tolist()}
                    result["cell_plot_data"] = cell_plot_data
            del coord_obs_df
        gc.collect()
    return result




def get_features_coord(mod_id, anndata, features, coord_key):
    result = {"cell_plot_data": []}
    feature_names = feature_search.load_f_names(mod_id)
    do_next = False
    for f_name in features:
        if f_name in feature_names:
            do_next = True
            break
    if do_next:
        exp_values = None
        f_anndata = anndata[:, features]
        if len(features) == 1:
            f_anndata = f_anndata[f_anndata.X > 0]
            exp_values = f_anndata.X.toarray()
            # 对表达值进行log标准化
            # exp_values = a_feature_exp.to_df(layer="log").values.tolist()
        elif len(features) > 1:
            gene_indices = [anndata.var_names.get_loc(gene) for gene in features]
            average_fs_exp_matrix = np.mean(anndata.X[:, gene_indices], axis=1)
            f_anndata.obs['average_expression'] = average_fs_exp_matrix
            f_anndata = f_anndata[f_anndata.obs['average_expression'] > 0]
            exp_values = f_anndata.obs['average_expression'].tolist()
            # exp_values = np.asarray(average_fs_exp_matrix).ravel()
        # 合并 表达值 和 坐标
        if exp_values is not None:
            coord = f_anndata.obsm[coord_key]
            cell_name_ndarray = f_anndata.obs_names.to_numpy()
            exp_coord = np.column_stack([exp_values, coord])
            cell_exp_coord = np.column_stack([cell_name_ndarray, exp_coord])
            result = {"cell_plot_data": cell_exp_coord.tolist()}
    del anndata
    gc.collect()
    return result




def get_spatial_column_coord(anndata, mod_id, column_name, spatial_key):
    result = {}
    spatial_meta_column = None
    if "library_id" in list(anndata.obs_keys()):
        spatial_meta_column = "library_id"
    elif "fov" in list(anndata.obs_keys()):
        spatial_meta_column = "fov"
    if spatial_meta_column:
        if "spatial" in list(anndata.obsm_keys()):
            spatial_anndata = anndata[anndata.obs[spatial_meta_column] == spatial_key]
            sc_mod_db = single_cell_mod_dao.get_single_cell_mod(mod_id)
            if sc_mod_db:
                gv_dict = json.loads(sc_mod_db["cell_meta_columns_group_value"])
                column_group_dict = gv_dict[column_name]
                if column_group_dict["type"] == "list":  # "Cluster": {"type": "list", "value": ["3T3", "Oli-neu_1", ...]}
                    group_values = column_group_dict["value"]
                    header_name = ["cell", "spatial_x", "spatial_y"]
                    result["cell_plot_header"] = {"group": header_name}
                    cell_plot_data_dict = {}
                    result["cell_plot_data"] = cell_plot_data_dict
                    for group_value in group_values:
                        sub_a = spatial_anndata[spatial_anndata.obs[column_name] == group_value]
                        # 坐标矩阵
                        coord = sub_a.obsm["spatial"]
                        # 细胞名列
                        cell_name_ndarray = sub_a.obs_names.to_numpy()
                        # 连接细胞名列和坐标矩阵
                        cell_coord = np.column_stack([cell_name_ndarray, coord.toarray()])
                        cell_plot_data_dict[group_value] = cell_coord.tolist()
                elif column_group_dict["type"] == "num":  # "gene_count": {"type": "num", "value": [10, 200]}
                    coord = spatial_anndata.obsm["spatial"]
                    cell_name_ndarray = spatial_anndata.obs_names.to_numpy()
                    column_value = spatial_anndata.obs[column_name].values
                    cell_coord = np.column_stack([column_value, coord])
                    cell_coord = np.column_stack([cell_name_ndarray, cell_coord])

                    header_name = ["cell", "value", "spatial_x", "spatial_y"]
                    result["cell_plot_header"] = header_name
                    cell_plot_data = {"scope": column_group_dict["value"], "coord": cell_coord.tolist()}
                    result["cell_plot_data"] = cell_plot_data
    del anndata
    gc.collect()
    return result




def save_3d_meshes(sc_file, obsm_key, single_cell_id, mod_id):
    mod_mesh_static_folder = os.path.join(data_folder, "meshes", single_cell_id, mod_id, obsm_key)
    file_util.create_folder(mod_mesh_static_folder)
    user_data_folder = os.path.dirname(sc_file)
    # /home/sgs/data/sc_test_2023/test_adata/3D_SGS_test/hypo_preoptic/meshes/spatial_3d_aligned
    user_meshes_obsm_folder = os.path.join(user_data_folder, "meshes", obsm_key)
    for root, ds, fs in os.walk(user_meshes_obsm_folder):
        for annotation in ds:
            annotation_mesh_files = []
            annotation_folder = os.path.join(user_meshes_obsm_folder, str(annotation))
            mesh_static_folder = os.path.join(data_folder, "meshes", single_cell_id)
            annotation_static_folder = os.path.join(mesh_static_folder, mod_id, obsm_key, str(annotation))
            file_util.create_folder(annotation_static_folder)
            file_util.clear_folder(annotation_static_folder)
            for root1, ds1, obj_files in os.walk(annotation_folder):
                for obj_file in obj_files:
                    obj_file_str = str(obj_file)
                    if obj_file_str.endswith(".obj"):
                        f_path = os.path.join(annotation_folder, obj_file_str)
                        f_static_path = os.path.join(annotation_static_folder, obj_file_str)
                        file_util.copy_file(f_path, f_static_path)
                        obj_name = file_util.get_file_base_name(obj_file)
                        f_static_path = f_static_path.replace(data_folder, "/static/")
                        mesh_dict = {"name": obj_name, "path": f_static_path}
                        annotation_mesh_files.append(mesh_dict)
            annotation_mesh_files_str = json.dumps(annotation_mesh_files, cls=JsonEncoder)
            sc_3d_id = id_util.generate_uuid()
            single_cell_3d_dao.add_sc_3d(sc_3d_id, single_cell_id, mod_id, obsm_key, str(annotation), annotation_mesh_files_str, mesh_static_folder)









