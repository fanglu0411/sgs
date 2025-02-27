import os, json, re, traceback
from db.dao.sc import subpopulation_dao, single_cell_mod_dao, single_cell_user_group_dao
from db.dao import chromosome_dao
from single_cell import mod_pool
import numpy as np
import pandas as pd
from path_config import sc_folder
from util import file_util
import pyarrow.feather as feather
from track.util import track_util
from track.util.dict_util import JsonEncoder







def is_peak_mod(f_name):
    is_peak = 0
    # pattern = r'(^[a-zA-Z0-9]+[:\-\_][0-9]+[-_][0-9]+$)'
    pattern = r'([a-zA-Z0-9]+)[_\-\.:\s]([0-9]+)[-_.]([0-9]+)'
    if re.match(pattern, f_name):
        is_peak = 1
        print(f_name)
    return is_peak






# peak_names = [
#     "abc123:456-789",  # 符合条件
#     "XYZ789:123_456",  # 符合条件
#     "abc123:456.789",  # 符合条件
#     # "abc123:456",      # 不符合条件，缺少最后的连接符和数字
#     # "abc123:456-",     # 不符合条件，缺少最后的数字
#     # "abc123:456_abc",  # 不符合条件，最后不是数字
#     # "abc123:456-",     # 不符合条件，缺少最后的数字
#     "abc123:456_789",  # 符合条件
#     "abc123-456_789",  # 符合条件
#     "abc123_456_789",  # 符合条件
#     "abc123_456-789",  # 符合条件
#     "123:456-789"      # 符合条件
# ]
def parse_peak_name(peak_name):
    pattern = r'([a-zA-Z0-9]+)[_\-\.:\s]([0-9]+)[-_.]([0-9]+)'
    match = re.match(pattern, peak_name)
    if match:
        chrom, start, end = match.groups()
        return peak_name, chrom, int(start), int(end)
    else:
        return None



def init_subpopulation_cell_peak_statistic_files(mod_id, user_id, group_id, cell_id_list, subpopulation_id):
    sc_mod_db = single_cell_mod_dao.get_single_cell_mod(mod_id)
    if sc_mod_db:
        sc_id = sc_mod_db["sc_id"]
        anndata = mod_pool.get_mod_anndata(mod_id)
        if anndata:
            # 从anndata中提取细胞亚群, 获得相应细胞的表达矩阵文件, 并且保存成h5格式
            selected_anndata = anndata[anndata.obs_names.isin(cell_id_list)]

            # 将表达矩阵转换为二进制矩阵（非零值改为 1）
            if isinstance(selected_anndata.X, np.ndarray):
                dense_matrix = selected_anndata.X
            else:
                dense_matrix = selected_anndata.X.toarray()

            # 将表达矩阵转换为二进制矩阵（非零值改为 1，零值保持为 0）
            binary_matrix = (dense_matrix > 0).astype(int)

            # 将稀疏矩阵转换为 Pandas DataFrame , 细胞名称为行索引，peak为列
            cell_peak_exp_df = pd.DataFrame(
                data=binary_matrix,
                index=selected_anndata.obs_names,  # 细胞名称作为行索引
                columns=selected_anndata.var_names  # peak名称作为列名
            )
            group_folder = os.path.join(sc_folder, user_id, sc_id, mod_id, group_id)
            file_util.create_folder(group_folder)
            subpopulation_cell_peak_exp_file = os.path.join(group_folder, subpopulation_id+".feather")
            feather.write_feather(cell_peak_exp_df, subpopulation_cell_peak_exp_file)
            subpopulation_dao.update_subpopulation_field(subpopulation_id, "peak_exp_file", subpopulation_cell_peak_exp_file)

            # 获得相应细胞的表达矩阵文件 , 解析peak名，提取染色体和位置信息, 并按照染色体分开存储
            peak_names = cell_peak_exp_df.columns.tolist()

            # 创建一个新的 DataFrame 来存储peak位置信息
            peak_info_df = pd.DataFrame(
                [parse_peak_name(peak) for peak in peak_names if parse_peak_name(peak) is not None],
                columns=["peak_name", 'chrom', 'start', 'end']
            ).set_index("peak_name")

            # 按染色体拆分数据并保存为单独的文件
            chr_peak_loc_files_dict = {}
            chr_name_map = {}
            for chr_view_name in peak_info_df['chrom'].unique():
                # 获取当前染色体的数据
                chr_peak_loc_df = peak_info_df[peak_info_df['chrom'] == chr_view_name].drop(columns=['chrom'])  # 删除染色体列
                chrom_file = chr_view_name + ".feather"
                chr_peak_loc_file = os.path.join(group_folder, chrom_file)
                feather.write_feather(chr_peak_loc_df, chr_peak_loc_file)
                chr_peak_loc_files_dict[chr_view_name] = chr_peak_loc_file
                chr_search_name = track_util.get_chr_search_name(chr_view_name)
                chr_name_map[chr_search_name] = chr_view_name
            chr_peak_loc_files_dict_str = json.dumps(chr_peak_loc_files_dict)
            subpopulation_dao.update_subpopulation_field(subpopulation_id, "chr_peak_location_files", chr_peak_loc_files_dict_str)
            sc_mod_db = single_cell_mod_dao.get_single_cell_mod(mod_id)
            if sc_mod_db["chr_name_mapping"] is None:
                if chr_name_map:
                    chr_name_map_str = json.dumps(chr_name_map, cls=JsonEncoder)
                    single_cell_mod_dao.update_sc_mod_field(mod_id, "chr_name_mapping", chr_name_map_str)






def peak_cell_statistic(group_id, subpopulation_id, chr_id, start, end):
    try:
        data = []
        sbp_db = subpopulation_dao.get_subpopulation_by_id(subpopulation_id)
        if sbp_db:
            peak_exp_file = sbp_db["peak_exp_file"]
            chr_peak_location_files = sbp_db["chr_peak_location_files"]
            chr_peak_location_files_dict = json.loads(chr_peak_location_files)
            cell_peak_exp_df = feather.read_feather(peak_exp_file, memory_map=True)
            all_cell_count = cell_peak_exp_df.shape[0]
            chr_db = chromosome_dao.get_chromosome_by_id(chr_id)
            group_db = single_cell_user_group_dao.get_group_by_id(group_id)
            if group_db:
                mod_db = single_cell_mod_dao.get_single_cell_mod(group_db["mod_id"])
                if mod_db["chr_name_mapping"]:
                    chr_name_mapping = json.loads(mod_db["chr_name_mapping"])
                    if chr_db:
                        chr_search_name = chr_db["search_name"]
                        if chr_search_name:
                            peak_chr_view_name = chr_name_mapping[chr_search_name]
                            if peak_chr_view_name:
                                chr_peak_loc_file = chr_peak_location_files_dict[peak_chr_view_name]
                                if chr_peak_loc_file:
                                    # peak_loc_df = pd.read_hdf(chr_peak_loc_file, key='df')
                                    peak_loc_df = feather.read_feather(chr_peak_loc_file, memory_map=True)
                                    # 筛选符合条件的 peak
                                    filtered_peaks = peak_loc_df[
                                        (peak_loc_df['start'] >= start) &
                                        (peak_loc_df['end'] <= end)].index
                                    # 如果没有符合条件的基因，提示用户
                                    if filtered_peaks.empty:
                                        print("没有符合条件的 peak。请检查筛选条件或数据。")
                                    else:
                                        # 统计每个符合条件的基因中表达值不为零的细胞数量
                                        peak_cell_count = {}
                                        for peak in filtered_peaks:
                                            if peak in cell_peak_exp_df.columns:  # 确保基因名在 DataFrame 的列中
                                                expressed_cells = (cell_peak_exp_df[peak] > 0).sum()  # 表达该基因的细胞数
                                                peak_cell_count[peak] = expressed_cells
                                        for peak, count in peak_cell_count.items():
                                            if count > 0:
                                                peak_row = peak_loc_df.loc[peak]
                                                start = int(peak_row['start'])
                                                end = int(peak_row['end'])
                                                percent = int(count) / all_cell_count
                                                p = {"peak": str(peak), "start": start, "end": end, "percent": percent, "cell": int(count), "all_cell": all_cell_count}
                                                data.append(p)
        return data
    except Exception as e:
        traceback.print_exc()
        return None











