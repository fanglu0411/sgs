import os, shutil, gzip, tarfile, zipfile




def read_file(file):
    if not os.path.isfile(file):
        return None
    with open(file, 'r') as _file:
        return _file.read()


def write_file(file_path, content):
    f = open(file_path, "w")
    f.write(content)
    f.close()



def create_folder(folder):
    if not os.path.exists(folder):
        os.makedirs(folder)
    else:
        print(folder, " is exist")




def clear_folder(folder):
    if os.path.exists(folder):
        shutil.rmtree(folder)
        os.makedirs(folder)



def delete_folder(folder):
    if os.path.exists(folder):
        shutil.rmtree(folder)


def delete_file(path):
    if os.path.exists(path):
        os.remove(path)



# “zip”, “tar”, “bztar”，“gztar”
def compress_file(file):
    target_file = file + ".gz"
    with open(file, 'rb') as f_in:
        with gzip.open(target_file, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)



def get_file_base_name(file_path):
    base_name = os.path.basename(file_path)
    no_ext_base_name, ext = os.path.splitext(base_name)
    return no_ext_base_name



def get_file_ext(file_name):
    f_name, f_ext = os.path.splitext(file_name)
    f_ext = f_ext.replace(".", "")
    return f_ext



def get_file_pure_name_and_ext(file_name):
    f_name, f_ext = os.path.splitext(file_name)
    f_ext = f_ext.replace(".", "")
    return f_name, f_ext



# todo tar.gz
# gzip file_name
# tar zcvf filename.tar.gz dirname
# "/home/sgs/data/at/GSM4160807_bed4.gz"
# "/home/sgs/data/at/GSM4160807_bed4.bed.gz"
# "/home/sgs/data/at/GSM4160807_bed4.zip"
def decompress_file(compress_file):
    compress_folder = os.path.dirname(compress_file)
    # /home/sgs/data/at/GSM4160807_bed4   zip
    de_compress_file, ext = get_file_pure_name_and_ext(compress_file)
    if ext in ["gz", "zip"]:
        if os.path.exists(de_compress_file):
            delete_file(de_compress_file)
        if ext == "gz":
            with gzip.open(compress_file, "rb") as f_in:
                with open(de_compress_file, "wb") as f_out:
                    shutil.copyfileobj(f_in, f_out)
                    # delete_file(compress_file)
            # gz_file = gzip.GzipFile(compress_file)
            # open(gz_file, "wb+").write(gz_file.read())
            # open(target_file_path, "w+").write(gz_file.read().decode("utf-8"))
            # gz_file.close()
        elif ext == "zip":
            zip_file = zipfile.ZipFile(compress_file, "r")
            # GSM4160807_bed4
            base_name = zip_file.namelist()[0]
            zip_file.extract(base_name, compress_folder)
            zip_file.close()
    else:
        de_compress_file = compress_file
    return de_compress_file






# cc_file = "/home/sgs/data/at/GSM4160807_bed4.bed.gz"
# print(decompress_file(cc_file))



# 去除文件名中的空格
def del_file_name_blank(file):
    if " " in file:
        new_file_name = file.replace(" ", "")
        os.rename(file, new_file_name)
        return new_file_name
    else:
        return file







# 计算大文件行数
def iter_count(file_name):
    from itertools import (takewhile, repeat)
    buffer = 1024 * 1024
    with open(file_name) as f:
        buf_gen = takewhile(lambda x: x, (f.read(buffer) for _ in repeat(None)))
        return sum(buf.count('\n') for buf in buf_gen)


import subprocess
def copy_file(source_file, dest_file):
    cp_vcf = "cp " + source_file + " " + dest_file
    r_code = subprocess.run(cp_vcf, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8", timeout=None)











