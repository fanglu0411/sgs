import pyBigWig, pysam, os, time, traceback
from util import file_util
from track.single.bed.methy import methy_path
from db.dao import chromosome_dao, chr_group_track_dao, track_dao
from track.util import track_util
from util.time import fuc_timer




class MethyBigWig(object):

    def __init__(self):
        pass


    @staticmethod
    def read_methy_bed(index_reader, chr_name, chr_length):
        methy_count = 0
        methy_big_type_dict = {}
        # pos = 0
        for line in index_reader.fetch(reference=chr_name, start=0, end=chr_length, parser=pysam.asBed()):
            methy_count = methy_count + 1
            start = int(line.start)
            end = int(line.end)
            methy_type = str(line.name)
            methy_value = float(line.score) # todo float 是否可以跟int在同一字典
            strand = "n" if line.strand == "-" else "p"
            deeps = float(line.thickStart)  # todo float 类型
            sub_big_type = strand + "_" + methy_type
            deep_type = strand + "_deeps"

            # # make sure record in order
            # if end <= start:
            #     continue
            # elif start <= pos:
            #     continue
            # elif end <= pos:
            #     continue
            # pos = end

            if sub_big_type in methy_big_type_dict.keys():
                methy_big_type_dict[sub_big_type][0].append(chr_name)
                methy_big_type_dict[sub_big_type][1].append(start)
                methy_big_type_dict[sub_big_type][2].append(end)
                methy_big_type_dict[sub_big_type][3].append(methy_value)
            else:
                methy_big_type_dict[sub_big_type] = [[chr_name], [start], [end], [methy_value]]

            if deep_type in methy_big_type_dict.keys():
                methy_big_type_dict[deep_type][0].append(chr_name)
                methy_big_type_dict[deep_type][1].append(start)
                methy_big_type_dict[deep_type][2].append(end)
                methy_big_type_dict[deep_type][3].append(deeps)
            else:
                methy_big_type_dict[deep_type] = [[chr_name], [start], [end], [deeps]]
        return methy_big_type_dict, methy_count



    @staticmethod
    def write2bigwig(file_name, chr_name_list, start_list, end_list, m_value_list, chro_name, chro_length):
        if os.path.exists(file_name):
            file_util.delete_file(file_name)
        big_writer = pyBigWig.open(file_name, "w")

        big_writer.addHeader([(chro_name, chro_length)], maxZooms=0)
        big_writer.addEntries(chr_name_list, start_list, ends=end_list, values=m_value_list)
        big_writer.close()




@fuc_timer
def bed2big(species_id, bed_file, track_id, db_chr_names):
    chr_methy_count_dict = {}
    try:
        gz_file = methy_path.get_sort_gz_file(bed_file, track_id)[1]
        index_reader = pysam.TabixFile(gz_file, encoding='utf-8')

        # cpu_count = multiprocessing.cpu_count()
        # pool_count = cpu_count // 2
        # pool = Pool(pool_count)

        for contig_name in index_reader.contigs:
            db_chr_name = track_util.get_chr_search_name(contig_name)
            if db_chr_name in db_chr_names:
                if contig_name in chr_methy_count_dict.keys():
                    contig_length = chr_methy_count_dict[contig_name]
                else:
                    chr_search_name = track_util.get_chr_search_name(contig_name)
                    chromosome = chromosome_dao.get_chromosome_by_search_name(species_id, chr_search_name)
                    contig_length = chromosome["seq_length"]
                    chr_methy_count_dict[contig_name] = contig_length
                mbw = MethyBigWig()
                methy_type_dict, chr_methy_count = mbw.read_methy_bed(index_reader, contig_name, contig_length)
                chr_methy_count_dict[contig_name] = chr_methy_count
                for m_name, m_list in methy_type_dict.items():
                    sub_big_file_name = m_name + ".bw"
                    big_folder = methy_path.get_chr_big_folder(track_id, contig_name)
                    sub_big_file = os.path.join(big_folder, sub_big_file_name)
                    chr_names = m_list[0]
                    starts = m_list[1]
                    ends = m_list[2]
                    m_values = m_list[3]
                    mbw.write2bigwig(sub_big_file, chr_names, starts, ends, m_values, contig_name, contig_length)
                    # pool.apply_async(mbw.write2bigwig, args=(sub_big_path, chr_names, starts, ends, m_values, contig_name, contig_length))
                    chr_db_search_name = track_util.get_chr_search_name(contig_name)
                    chromosome = chromosome_dao.get_chromosome_by_search_name(species_id, chr_db_search_name)
                    chr_group_track_dao.add_chr_group(track_id, chromosome["id"], m_name, sub_big_file, None, None)

        index_reader.close()

        # pool.close()
        # pool.join()

    except Exception as e:
        track_dao.update_track_error_msg(track_id, str(traceback.format_exc()))
    return chr_methy_count_dict




