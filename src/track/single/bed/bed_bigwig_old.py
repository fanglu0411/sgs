import pyBigWig, os, vaex
from db.dao import chr_group_track_dao
from track.single.bed.normal import bed_path
from track.util import track_util, coverage_util
from db.dao import chromosome_dao






def read_track_chr_bigwigs(track_id, chromosome, start, end, histo_count, stats_type):
    group = chr_group_track_dao.get_chr_group(track_id, chromosome["id"], None)
    if group:
        big_file = group["group_track_file"]
        if big_file:
            big_reader = pyBigWig.open(big_file)
            if end > (chromosome["seq_length"] - 1):
                end = chromosome["seq_length"] - 1
            if stats_type == "sum":
                stats = big_reader.stats(chromosome["view_name"], start, end, nBins=histo_count)
            else:
                stats = big_reader.stats(chromosome["view_name"], start, end, type=stats_type, nBins=histo_count)
            big_reader.close()
            return stats
    else:
        return None



def read_chr_binsize_bigwigs(track_id, chr_id, start, end, bin_size):
    chr_group = chr_group_track_dao.get_binsize_bigwig(track_id, chr_id, bin_size)
    intervals = []
    if chr_group:
        big_file = chr_group["group_track_file"]
        chromosome = chromosome_dao.get_chromosome_by_id(chr_id)
        chr_length = chromosome["seq_length"]
        if start < 0:
            start = 0
        if end > chr_length:
            end = chr_length
        chr_view_name = chromosome["view_name"]
        big_reader = pyBigWig.open(big_file)
        if end > (chromosome["seq_length"] - 1):
            end = chromosome["seq_length"] - 1
        intervals = big_reader.intervals(chr_view_name, start, end)
        big_reader.close()
    return intervals




def bed2bigwig(species_id, track_id, hdf5_folder, chr_view_names):
    chr_big_file_dict = {}
    chr_name_length_dict = {}
    chr_f_count_dict = {}
    chr_dfs = {}
    hdf5_file_names = os.listdir(hdf5_folder)
    hdf5_path_names = [os.path.join(hdf5_folder, file_name) for file_name in hdf5_file_names]
    df_hdf5 = vaex.open_many(hdf5_path_names)
    for chr_view_name in chr_view_names:
        # ['chromosome', 'ref_start', 'ref_end', 'name', 'score', 'strand', 'thick_start', 'thick_end', 'item_rgb', 'block_count', 'block_size', 'block_starts']
        chr_vaex= df_hdf5[df_hdf5.chromosome == chr_view_name]
        chr_df = chr_vaex.to_pandas_df(["chromosome", "ref_start", "ref_end"])
        chr_df = chr_df.rename(columns={"chromosome": "Chromosome", "ref_start": "Start", "ref_end": "End"})
        chr_df["Chromosome"] = chr_df["Chromosome"].astype("str")
        chr_df["Start"] = chr_df["Start"].astype("str")
        chr_df["End"] = chr_df["End"].astype("str")
        chr_df["Start"] = chr_df["Start"].astype("int64")
        chr_df["End"] = chr_df["End"].astype("int64")
        chr_dfs[chr_view_name] = chr_df
        chr_f_count_dict[chr_view_name] = chr_df.shape[0]
        df_split = coverage_util.split_range(chr_df)
        df_split = df_split[["Chromosome", "Start", "End"]]
        chr_df_result = coverage_util.count_coverage(df_split, chr_df, "count")
        chr_big_file = bed_path.get_split_big_file(track_id, chr_view_name)
        chr_big_file_dict[chr_view_name] = chr_big_file
        if chr_view_name in chr_name_length_dict.keys():
            chr_length = chr_name_length_dict.get(chr_view_name)
        else:
            chr_search_name = track_util.get_chr_search_name(chr_view_name)
            chromosome = chromosome_dao.get_chromosome_by_search_name(species_id, chr_search_name)
            chr_length = chromosome["seq_length"]
            chr_name_length_dict[chr_view_name] = chr_length
        coverage_util.df2bigwig(chr_df_result, chr_big_file, chr_length, chr_view_name)
    return chr_dfs, chr_f_count_dict, chr_big_file_dict












