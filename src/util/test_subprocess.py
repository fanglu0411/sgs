import subprocess, sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

gff_file = "/home/sgs/data/upload/gff3/homo37.gff3"



sort_file = gff_file + ".sort"
sort_cmd = "/home/conda/bin/gff3sort.pl " + gff_file + " > " + sort_file

gz_file = sort_file + ".gz"
compress_cmd = "/home/conda/bin/bgzip -f " + sort_file

tabix_cmd = "/home/conda/bin/tabix -p gff " + gz_file



def test_subprocess():
    ret = subprocess.run(sort_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8", timeout=None)
    return_code = ret.returncode
    print("return_code: ", return_code)

    ret1 = subprocess.run(compress_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8", timeout=None)
    return_code1 = ret1.returncode
    print("return_code1: ", return_code1)

    ret2 = subprocess.run(tabix_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8", timeout=None)
    return_code2 = ret2.returncode
    print("return_code2: ", return_code2)


# test_subprocess()

