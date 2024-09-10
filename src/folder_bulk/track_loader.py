import sys, os, json
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
import requests, time
from db.dao import species_dao, track_dao




# def add_folder_species(sp_name, sp_file_path):
#     sp_id = species_dao.add_species(g.session, sp_name, sp_file_path, "adding")
#     add_chromosome(sp_file_path, sp_id)
#     return sp_id




def add_species(env, sp_name, sp_file):
    url = env + "api/species/add"
    req = {
        "user_id": "user001",
        "species_name": sp_name,
        "fasta_file": sp_file
    }
    data = json.dumps(req)
    headers = {'Content-Type': 'application/json'}
    result = requests.post(url=url, data=data, headers=headers)
    response = json.loads(result.text)
    status = "adding"
    if "species_id" in response:
        species_id = response["species_id"]
        if species_id != "failed":
            while status == "adding":
                time.sleep(3)
                sp = species_dao.get_species(species_id)
                status = sp["status"]
            return species_id



def add_track(env, sp_id, track_name, track_file):
    url = env + "api/track/add"
    req = {
        "species_id": sp_id,
        "track_name": track_name,
        "file_id": track_file,
        "user_id": "user001"
    }
    data = json.dumps(req)
    headers = {'Content-Type': 'application/json'}
    result = requests.post(url=url, data=data, headers=headers)
    response = json.loads(result.text)
    status = "adding"
    if "track_id" in response:
        track_id = response["track_id"]
        while status == "adding":
            time.sleep(3)
            track = track_dao.get_track(track_id)
            status = track["status"]
        print(track_name, track_id)
        return track_id


def add_bam_track(env, sp_id, track_name, track_file):
    url = env + "api/track/add"
    req = {
        "species_id": sp_id,
        "track_name": track_name,
        "file_id": track_file,
        "user_id": "user001"
    }
    data = json.dumps(req)
    headers = {'Content-Type': 'application/json'}
    result = requests.post(url=url, data=data, headers=headers)
    response = json.loads(result.text)
    status = "adding"
    if "coverage_track_id" in response and "reads_track_id" in response:
        coverage_track_id = response["coverage_track_id"]
        reads_track_id = response["reads_track_id"]
        while status == "adding":
            time.sleep(3)
            reads_track = track_dao.get_track(reads_track_id)
            status = reads_track.status
        print(track_name, coverage_track_id, reads_track_id)
        return coverage_track_id, reads_track_id



def add_vcf_track(env, sp_id, track_name, track_file):
    url = env + "api/track/add"
    req = {
        "species_id": sp_id,
        "track_name": track_name,
        "file_id": track_file,
        "user_id": "user001"
    }
    data = json.dumps(req)
    headers = {'Content-Type': 'application/json'}
    result = requests.post(url=url, data=data, headers=headers)
    response = json.loads(result.text)
    status = "adding"
    if "track_id" in response and "sample_track_id" in response:
        track_id = response["track_id"]
        sample_track_id = response["sample_track_id"]
        while status == "adding":
            time.sleep(5)
            track = track_dao.get_track(track_id)
            status = track["status"]
            sample_track = track_dao.get_track(sample_track_id)
            if sample_track:
                status = sample_track["status"]
        print(track_name, track_id, sample_track_id)
        return track_id, sample_track_id























def add_ecoli_tracks(env):
    # fasta
    sp_id = add_species(env, "ecoli", "ecoli.fasta")
    # gff
    add_track(env, sp_id, "transcript", "ecoli.gff3")
    # vcf
    add_vcf_track(env, sp_id, "snp1", "ecol1.vcf")
    add_vcf_track(env, sp_id, "snp2", "ecol2.vcf")
    add_vcf_track(env, sp_id, "multisample", "ecol_multisample.vcf")
    # bigwig
    add_track(env, sp_id, "coverage hs15", "ecol_hs15.bw")
    add_track(env, sp_id, "coverage mp14", "ecol_mp14.bw")
    # bam
    add_bam_track(env, sp_id, "reads pair 676", "ecoli_pair_SRR12401676.bam")
    add_bam_track(env, sp_id, "sorted", "ecol_sorted.bam")
    add_bam_track(env, sp_id, "DRR148992", "ecoli_DRR148992.bam")
    add_bam_track(env, sp_id, "DRR148993", "ecoli_DRR148993.bam")
    add_bam_track(env, sp_id, "merged", "ecoli_merged.bam")
    add_bam_track(env, sp_id, "SRR12401676", "ecoli_SRR12401676.bam")
    print("adding ecoli tracks done")


# todo
def add_at_tracks(env):
    sp_id = add_species(env, "arabidopsis thaliana", "at.fasta")
    add_track(env, sp_id, "at transcript", "at.gff3")
    add_vcf_track(env, sp_id, "", ".vcf")
    add_track(env, sp_id, "", ".bw")
    add_track(env, sp_id, "", ".bw")
    add_bam_track(env, sp_id, "", ".bam")
    print("adding at tracks done")



# todo
def add_silk_tracks(env):
    sp_id = add_species(env, "silk", "silkDB3.1.5.fasta")
    add_track(env, sp_id, "", ".gff3")
    add_vcf_track(env, sp_id, "", ".vcf")
    add_track(env, sp_id, "", ".bw")
    add_track(env, sp_id, "", ".bw")
    add_bam_track(env, sp_id, "", ".bam")
    print("adding silk tracks done")



# todo
def add_homo_tracks(env):
    sp_id = add_species(env, "hg19", "hg19.fasta")
    add_track(env, sp_id, "", ".gff3")
    add_vcf_track(env, sp_id, "", ".vcf")
    add_track(env, sp_id, "", ".bw")
    add_track(env, sp_id, "", ".bw")
    add_bam_track(env, sp_id, "", ".bam")
    print("adding homo tracks done")

















