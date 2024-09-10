from old.track.single.gff.foerstner import gffpandas as gff3pd
import pandas as pd
import os



written_df = pd.DataFrame([
        ['NC_016810.1', 'RefSeq', 'region', 1, 4000, '.', '+', '.',
         'Dbxref=taxon:216597;ID=id0;gbkey=Src;genome=genomic;mol_type='
         'genomic DNA;serovar=Typhimurium;strain=SL1344'],
        ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
         'ID=gene1;Name=thrL;gbkey=Gene;gene=thrL;locus_tag=SL1344_0001'],
        ['NC_016810.1', 'RefSeq', 'CDS', 13, 235, '.', '+', '0',
         'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID='
         'cds0;Name=YP_005179941.1;Parent=gene1;gbkey=CDS;product=thr operon'
         ' leader peptide;protein_id=YP_005179941.1;transl_table=11'],
        ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
         'ID=gene2;Name=thrA;gbkey=Gene;gene=thrA;locus_tag=SL1344_0002'],
        ['NC_016810.1', 'RefSeq', 'CDS', 341, 523, '.', '+', '0',
         'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID='
         'cds0;Name=YP_005179941.1;Parent=gene2;gbkey=CDS;product=thr operon'
         ' leader peptide;protein_id=YP_005179941.1;transl_table=11'],
        ['NC_016810.1', 'RefSeq', 'gene', 1, 600, '.', '-', '.',
         'ID=gene3;Name=thrX;gbkey=Gene;gene=thrX;locus_tag=SL1344_0003'],
        ['NC_016810.1', 'RefSeq', 'CDS', 21, 345, '.', '-', '0',
         'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID='
         'cds0;Name=YP_005179941.1;Parent=gene3;gbkey=CDS;product=thr operon'
         ' leader peptide;protein_id=YP_005179941.1;transl_table=11'],
        ['NC_016810.1', 'RefSeq', 'gene', 41, 255, '.', '+', '.',
         'ID=gene4;Name=thrB;gbkey=Gene;gene=thrB;locus_tag=SL1344_0004'],
        ['NC_016810.1', 'RefSeq', 'CDS', 61, 195, '.', '+', '0',
         'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID='
         'cds0;Name=YP_005179941.1;Parent=gene4;gbkey=CDS;product=thr operon'
         ' leader peptide;protein_id=YP_005179941.1;transl_table=11'],
        ['NC_016810.1', 'RefSeq', 'gene', 170, 546, '.', '+', '.',
         'ID=gene5;Name=thrC;gbkey=Gene;gene=thrC;locus_tag=SL1344_0005'],
        ['NC_016810.1', 'RefSeq', 'CDS', 34, 335, '.', '+', '0',
         'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID='
         'cds0;Name=YP_005179941.1;Parent=gene5;gbkey=CDS;product=thr operon'
         ' leader peptide;protein_id=YP_005179941.1;transl_table=11'],
        ], columns=["seq_id", "source", "type", "start", "end",
                    "score", "strand", "phase", "attributes"])

written_header = ('##gff-version 3\n'
                  '##sequence-region NC_016810.1 1 20\n')


written_csv = ('seq_id,source,type,start,end,score,strand,phase,attributes\n'
               'NC_016810.1,RefSeq,region,1,4000,.,+,.,Dbxref=taxon:216597;ID='
               'id0;gbkey=Src;genome=genomic;mol_type=genomic DNA;serovar='
               'Typhimurium;strain=SL1344\n'
               'NC_016810.1,RefSeq,gene,1,20,.,+,.,ID=gene1;Name=thrL;gbkey='
               'Gene;gene=thrL;locus_tag=SL1344_0001\n'
               'NC_016810.1,RefSeq,CDS,13,235,.,+,0,Dbxref=UniProtKB%252FTr'
               'EMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name=YP_0051799'
               '41.1;Parent=gene1;gbkey=CDS;product=thr operon leader peptide;'
               'protein_id=YP_005179941.1;transl_table=11\n'
               'NC_016810.1,RefSeq,gene,1,20,.,+,.,ID=gene2;Name=thrA;gbkey='
               'Gene;gene=thrA;locus_tag=SL1344_0002\n'
               'NC_016810.1,RefSeq,CDS,341,523,.,+,0,Dbxref=UniProtKB%252FTr'
               'EMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name=YP_0051799'
               '41.1;Parent=gene2;gbkey=CDS;product=thr operon leader peptide;'
               'protein_id=YP_005179941.1;transl_table=11\n'
               'NC_016810.1,RefSeq,gene,1,600,.,-,.,ID=gene3;Name=thrX;gbkey='
               'Gene;gene=thrX;locus_tag=SL1344_0003\n'
               'NC_016810.1,RefSeq,CDS,21,345,.,-,0,Dbxref=UniProtKB%252FTr'
               'EMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name=YP_0051799'
               '41.1;Parent=gene3;gbkey=CDS;product=thr operon leader peptide;'
               'protein_id=YP_005179941.1;transl_table=11\n'
               'NC_016810.1,RefSeq,gene,41,255,.,+,.,ID=gene4;Name=thrB;gbkey='
               'Gene;gene=thrB;locus_tag=SL1344_0004\n'
               'NC_016810.1,RefSeq,CDS,61,195,.,+,0,Dbxref=UniProtKB%252FTr'
               'EMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name=YP_0051799'
               '41.1;Parent=gene4;gbkey=CDS;product=thr operon leader peptide;'
               'protein_id=YP_005179941.1;transl_table=11\n'
               'NC_016810.1,RefSeq,gene,170,546,.,+,.,ID=gene5;Name=thrC;gbkey'
               '=Gene;gene=thrC;locus_tag=SL1344_0005\n'
               'NC_016810.1,RefSeq,CDS,34,335,.,+,0,Dbxref=UniProtKB%252FTr'
               'EMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name=YP_0051799'
               '41.1;Parent=gene5;gbkey=CDS;product=thr operon leader peptide;'
               'protein_id=YP_005179941.1;transl_table=11\n')

written_tsv = ('seq_id\tsource\ttype\tstart\tend\tscore\tstrand\tphase\t'
               'attributes\n'
               'NC_016810.1\tRefSeq\tregion\t1\t4000\t.\t+\t.\tDbxref=taxon:21'
               '6597;ID=id0;gbkey=Src;genome=genomic;mol_type=genomic DNA;'
               'serovar=Typhimurium;strain=SL1344\n'
               'NC_016810.1\tRefSeq\tgene\t1\t20\t.\t+\t.\tID=gene1;Name=thrL;'
               'gbkey=Gene;gene=thrL;locus_tag=SL1344_0001\n'
               'NC_016810.1\tRefSeq\tCDS\t13\t235\t.\t+\t0\tDbxref=UniProtKB%2'
               '52FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name=YP_0051'
               '79941.1;Parent=gene1;gbkey=CDS;product=thr operon leader '
               'peptide;protein_id=YP_005179941.1;transl_table=11\n'
               'NC_016810.1\tRefSeq\tgene\t1\t20\t.\t+\t.\tID=gene2;Name=thrA;'
               'gbkey=Gene;gene=thrA;locus_tag=SL1344_0002\n'
               'NC_016810.1\tRefSeq\tCDS\t341\t523\t.\t+\t0\tDbxref=UniProtKB%'
               '252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name=YP_005'
               '179941.1;Parent=gene2;gbkey=CDS;product=thr operon leader '
               'peptide;protein_id=YP_005179941.1;transl_table=11\n'
               'NC_016810.1\tRefSeq\tgene\t1\t600\t.\t-\t.\tID=gene3;Name=thrX'
               ';gbkey=Gene;gene=thrX;locus_tag=SL1344_0003\n'
               'NC_016810.1\tRefSeq\tCDS\t21\t345\t.\t-\t0\tDbxref=UniProtKB%2'
               '52FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name=YP_0051'
               '79941.1;Parent=gene3;gbkey=CDS;product=thr operon leader '
               'peptide;protein_id=YP_005179941.1;transl_table=11\n'
               'NC_016810.1\tRefSeq\tgene\t41\t255\t.\t+\t.\tID=gene4;Name='
               'thrB;gbkey=Gene;gene=thrB;locus_tag=SL1344_0004\n'
               'NC_016810.1\tRefSeq\tCDS\t61\t195\t.\t+\t0\tDbxref=UniProtKB%2'
               '52FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name=YP_0051'
               '79941.1;Parent=gene4;gbkey=CDS;product=thr operon leader '
               'peptide;protein_id=YP_005179941.1;transl_table=11\n'
               'NC_016810.1\tRefSeq\tgene\t170\t546\t.\t+\t.\tID=gene5;Name='
               'thrC;gbkey=Gene;gene=thrC;locus_tag=SL1344_0005\n'
               'NC_016810.1\tRefSeq\tCDS\t34\t335\t.\t+\t0\tDbxref=UniProt'
               'KB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name='
               'YP_005179941.1;Parent=gene5;gbkey=CDS;product=thr operon '
               'leader peptide;protein_id=YP_005179941.1;transl_table=11\n')

written_gff = ('##gff-version 3\n'
               '##sequence-region NC_016810.1 1 20\n'
               'NC_016810.1	RefSeq	region	1	4000	.	+'
               '	.	Dbxref=taxon:216597;ID=id0;gbkey=Src;genome=ge'
               'nomic;mol_type=genomic DNA;serovar=Typhimurium;strain=SL1344\n'
               'NC_016810.1	RefSeq	gene	1	20	.	+'
               '	.	ID=gene1;Name=thrL;gbkey=Gene;gene=thrL;locus_'
               'tag=SL1344_0001\n'
               'NC_016810.1	RefSeq	CDS	13	235	.	+'
               '	0	Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:Y'
               'P_005179941.1;ID=cds0;Name=YP_005179941.1;Parent=gene1;gbkey=C'
               'DS;product=thr operon leader peptide;protein_id=YP_005179941.1'
               ';transl_table=11\n'
               'NC_016810.1	RefSeq	gene	1	20	.	+'
               '	.	ID=gene2;Name=thrA;gbkey=Gene;gene=thrA;locus_'
               'tag=SL1344_0002\n'
               'NC_016810.1	RefSeq	CDS	341	523	.	+'
               '	0	Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:Y'
               'P_005179941.1;ID=cds0;Name=YP_005179941.1;Parent=gene2;gbkey=C'
               'DS;product=thr operon leader peptide;protein_id=YP_005179941.1'
               ';transl_table=11\n'
               'NC_016810.1	RefSeq	gene	1	600	.	-'
               '	.	ID=gene3;Name=thrX;gbkey=Gene;gene=thrX;locus_'
               'tag=SL1344_0003\n'
               'NC_016810.1	RefSeq	CDS	21	345	.	-'
               '	0	Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:Y'
               'P_005179941.1;ID=cds0;Name=YP_005179941.1;Parent=gene3;gbkey=C'
               'DS;product=thr operon leader peptide;protein_id=YP_005179941.1'
               ';transl_table=11\n'
               'NC_016810.1	RefSeq	gene	41	255	.	+'
               '	.	ID=gene4;Name=thrB;gbkey=Gene;gene=thrB;locus_'
               'tag=SL1344_0004\n'
               'NC_016810.1	RefSeq	CDS	61	195	.	+'
               '	0	Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:Y'
               'P_005179941.1;ID=cds0;Name=YP_005179941.1;Parent=gene4;gbkey=C'
               'DS;product=thr operon leader peptide;protein_id=YP_005179941.1'
               ';transl_table=11\n'
               'NC_016810.1	RefSeq	gene	170	546	.	+'
               '	.	ID=gene5;Name=thrC;gbkey=Gene;gene=thrC;locus_'
               'tag=SL1344_0005\n'
               'NC_016810.1	RefSeq	CDS	34	335	.	+'
               '	0	Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:Y'
               'P_005179941.1;ID=cds0;Name=YP_005179941.1;Parent=gene5;gbkey=C'
               'DS;product=thr operon leader peptide;protein_id=YP_005179941.1'
               ';transl_table=11\n')


written_filtered_length = pd.DataFrame([
    ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
     'ID=gene1;Name=thrL;gbkey=Gene;gene=thrL;locus_tag=SL1344_0001'],
    ['NC_016810.1', 'RefSeq', 'CDS', 13, 235, '.', '+', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name'
     '=YP_005179941.1;Parent=gene1;gbkey=CDS;product=thr operon leader peptide'
     ';protein_id=YP_005179941.1;transl_table=11'],
    ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
     'ID=gene2;Name=thrA;gbkey=Gene;gene=thrA;locus_tag=SL1344_0002'],
    ['NC_016810.1', 'RefSeq', 'CDS', 341, 523, '.', '+', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name'
     '=YP_005179941.1;Parent=gene2;gbkey=CDS;product=thr operon leader peptide'
     ';protein_id=YP_005179941.1;transl_table=11'],
    ['NC_016810.1', 'RefSeq', 'gene', 41, 255, '.', '+', '.',
     'ID=gene4;Name=thrB;gbkey=Gene;gene=thrB;locus_tag=SL1344_0004'],
    ['NC_016810.1', 'RefSeq', 'CDS', 61, 195, '.', '+', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name'
     '=YP_005179941.1;Parent=gene4;gbkey=CDS;product=thr operon leader peptide'
     ';protein_id=YP_005179941.1;transl_table=11'],
    ], columns=["seq_id", "source", "type", "start", "end",
                "score", "strand", "phase", "attributes"],
                                       index=[1, 2, 3, 4, 7, 8])

compare_get_feature_by_attribute = pd.DataFrame([
    ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
     'ID=gene1;Name=thrL;gbkey=Gene;gene=thrL;locus_tag=SL1344_0001'],
    ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
     'ID=gene2;Name=thrA;gbkey=Gene;gene=thrA;locus_tag=SL1344_0002'],
    ['NC_016810.1', 'RefSeq', 'gene', 1, 600, '.', '-', '.',
     'ID=gene3;Name=thrX;gbkey=Gene;gene=thrX;locus_tag=SL1344_0003'],
    ['NC_016810.1', 'RefSeq', 'gene', 41, 255, '.', '+', '.',
     'ID=gene4;Name=thrB;gbkey=Gene;gene=thrB;locus_tag=SL1344_0004'],
    ['NC_016810.1', 'RefSeq', 'gene', 170, 546, '.', '+', '.',
     'ID=gene5;Name=thrC;gbkey=Gene;gene=thrC;locus_tag=SL1344_0005'],
    ], columns=["seq_id", "source", "type", "start", "end",
                "score", "strand", "phase", "attributes"],
                                                index=[1, 3, 5, 7, 9])

compare_get_feature_by_attribute2 = pd.DataFrame([
    ['NC_016810.1', 'RefSeq', 'CDS', 341, 523, '.', '+', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name'
     '=YP_005179941.1;Parent=gene2;gbkey=CDS;product=thr operon leader peptide'
     ';protein_id=YP_005179941.1;transl_table=11'],
    ['NC_016810.1', 'RefSeq', 'CDS', 21, 345, '.', '-', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID='
     'cds0;Name=YP_005179941.1;Parent=gene3;gbkey=CDS;product=thr operon'
     ' leader peptide;protein_id=YP_005179941.1;transl_table=11'],
    ['NC_016810.1', 'RefSeq', 'CDS', 61, 195, '.', '+', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID='
     'cds0;Name=YP_005179941.1;Parent=gene4;gbkey=CDS;product=thr operon'
     ' leader peptide;protein_id=YP_005179941.1;transl_table=11'],
    ], columns=["seq_id", "source", "type", "start", "end",
                "score", "strand", "phase", "attributes"],
                                                index=[4, 6, 8])


written_attribute_df = pd.DataFrame([
        ['NC_016810.1', 'RefSeq', 'region', 1, 4000, '.', '+', '.',
         'Dbxref=taxon:216597;ID=id0;gbkey=Src;genome=genomic;mol_type=genomic'
         ' DNA;serovar=Typhimurium;strain=SL1344',
         'taxon:216597', 'id0', None, None, 'Src', None, 'genomic',
         None, 'genomic DNA', None, None, 'Typhimurium', 'SL1344',
         None],
        ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
         'ID=gene1;Name=thrL;gbkey=Gene;gene=thrL;locus_tag=SL1344_0001',
         None, 'gene1', 'thrL', None, 'Gene', 'thrL', None,
         'SL1344_0001', None, None, None, None, None, None],
        ['NC_016810.1', 'RefSeq', 'CDS', 13, 235, '.', '+', '0',
         'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;'
         'Name=YP_005179941.1;Parent=gene1;gbkey=CDS;product=thr operon leader'
         ' peptide;protein_id=YP_005179941.1;transl_table=11',
         'UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1',
         'cds0', 'YP_005179941.1', 'gene1', 'CDS', None, None,
         None, None, 'thr operon leader peptide',
         'YP_005179941.1', None, None, '11'],
        ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
         'ID=gene2;Name=thrA;gbkey=Gene;gene=thrA;locus_tag=SL1344_0002',
         None, 'gene2', 'thrA', None, 'Gene', 'thrA', None,
         'SL1344_0002', None, None, None, None, None, None],
        ['NC_016810.1', 'RefSeq', 'CDS', 341, 523, '.', '+', '0',
         'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;'
         'Name=YP_005179941.1;Parent=gene2;gbkey=CDS;product=thr operon leader'
         ' peptide;protein_id=YP_005179941.1;transl_table=11',
         'UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1', 'cds0',
         'YP_005179941.1', 'gene2', 'CDS', None, None, None, None,
         'thr operon leader peptide',
         'YP_005179941.1', None, None, '11'],
        ['NC_016810.1', 'RefSeq', 'gene', 1, 600, '.', '-', '.',
         'ID=gene3;Name=thrX;gbkey=Gene;gene=thrX;locus_tag=SL1344_0003',
         None, 'gene3', 'thrX', None, 'Gene', 'thrX', None,
         'SL1344_0003', None, None, None, None, None, None],
        ['NC_016810.1', 'RefSeq', 'CDS', 21, 345, '.', '-', '0',
         'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;'
         'Name=YP_005179941.1;Parent=gene3;gbkey=CDS;product=thr operon leader'
         ' peptide;protein_id=YP_005179941.1;transl_table=11',
         'UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1', 'cds0',
         'YP_005179941.1', 'gene3', 'CDS', None, None, None, None,
         'thr operon leader peptide',
         'YP_005179941.1', None, None, '11'],
        ['NC_016810.1', 'RefSeq', 'gene', 41, 255, '.', '+', '.',
         'ID=gene4;Name=thrB;gbkey=Gene;gene=thrB;locus_tag=SL1344_0004',
         None, 'gene4', 'thrB', None, 'Gene', 'thrB', None,
         'SL1344_0004', None, None, None, None, None, None],
        ['NC_016810.1', 'RefSeq', 'CDS', 61, 195, '.', '+', '0',
         'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;'
         'Name=YP_005179941.1;Parent=gene4;gbkey=CDS;product=thr operon leader'
         ' peptide;protein_id=YP_005179941.1;transl_table=11',
         'UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1', 'cds0',
         'YP_005179941.1', 'gene4', 'CDS', None, None, None, None,
         'thr operon leader peptide',
         'YP_005179941.1', None, None, '11'],
        ['NC_016810.1', 'RefSeq', 'gene', 170, 546, '.', '+', '.',
         'ID=gene5;Name=thrC;gbkey=Gene;gene=thrC;locus_tag=SL1344_0005',
         None, 'gene5', 'thrC', None, 'Gene', 'thrC', None,
         'SL1344_0005', None, None, None, None, None, None],
        ['NC_016810.1', 'RefSeq', 'CDS', 34, 335, '.', '+', '0',
         'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;'
         'Name=YP_005179941.1;Parent=gene5;gbkey=CDS;product=thr operon leader'
         ' peptide;protein_id=YP_005179941.1;transl_table=11',
         'UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1', 'cds0',
         'YP_005179941.1', 'gene5', 'CDS', None, None, None, None,
         'thr operon leader peptide',
         'YP_005179941.1', None, None, '11'],
        ], columns=["seq_id", "source", "type", "start", "end",
                    "score", "strand", "phase", "attributes", "Dbxref",
                    "ID", "Name", "Parent", "gbkey", "gene", "genome",
                    "locus_tag", "mol_type", "product", "protein_id",
                    "serovar", "strain", "transl_table"])


strand_counts = pd.value_counts(written_df['strand']).to_dict()
type_counts = pd.value_counts(written_df['type']).to_dict()


compare_stats_dic = {
    'Maximal_bp_length':
    599,
    'Minimal_bp_length':
    19,
    'Counted_strands':
    strand_counts,
    'Counted_feature_types':
    type_counts
    }


df_empty = pd.DataFrame({}, columns=["seq_id", "source", "type", "start",
                                     "end", "score", "strand", "phase",
                                     "attributes"], index=[])

redundant_entry = pd.DataFrame([
    ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
     'ID=gene2;Name=thrA;gbkey=Gene;gene=thrA;locus_tag=SL1344_0002'],
    ], columns=["seq_id", "source", "type", "start", "end", "score",
                "strand", "phase", "attributes"],
                               index=[3])

compare_filter_feature_df = pd.DataFrame([
    ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
     'ID=gene1;Name=thrL;gbkey=Gene;gene=thrL;locus_tag=SL1344_0001'],
    ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
     'ID=gene2;Name=thrA;gbkey=Gene;gene=thrA;locus_tag=SL1344_0002'],
    ['NC_016810.1', 'RefSeq', 'gene', 1, 600, '.', '-', '.',
     'ID=gene3;Name=thrX;gbkey=Gene;gene=thrX;locus_tag=SL1344_0003'],
    ['NC_016810.1', 'RefSeq', 'gene', 41, 255, '.', '+', '.',
     'ID=gene4;Name=thrB;gbkey=Gene;gene=thrB;locus_tag=SL1344_0004'],
    ['NC_016810.1', 'RefSeq', 'gene', 170, 546, '.', '+', '.',
     'ID=gene5;Name=thrC;gbkey=Gene;gene=thrC;locus_tag=SL1344_0005'],
    ], columns=["seq_id", "source", "type", "start", "end",
                "score", "strand", "phase", "attributes"],
                                         index=[1, 3, 5, 7, 9])

compare_overlap_gene_1_40 = pd.DataFrame([
    ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
     'ID=gene1;Name=thrL;gbkey=Gene;gene=thrL;locus_tag=SL1344_0001'],
    ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
     'ID=gene2;Name=thrA;gbkey=Gene;gene=thrA;locus_tag=SL1344_0002'],
    ], columns=["seq_id", "source", "type", "start", "end", "score",
                "strand", "phase", "attributes"],
                               index=[1, 3])

compare_overlap_40_300 = pd.DataFrame([
    ['NC_016810.1', 'RefSeq', 'region', 1, 4000, '.', '+', '.',
     'Dbxref=taxon:216597;ID=id0;gbkey=Src;genome=genomic;mol_type=genomic DNA'
     ';serovar=Typhimurium;strain=SL1344'],
    ['NC_016810.1', 'RefSeq', 'CDS', 13, 235, '.', '+', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name'
     '=YP_005179941.1;Parent=gene1;gbkey=CDS;product=thr operon leader peptide'
     ';protein_id=YP_005179941.1;transl_table=11'],
    ['NC_016810.1', 'RefSeq', 'gene', 41, 255, '.', '+', '.',
     'ID=gene4;Name=thrB;gbkey=Gene;gene=thrB;locus_tag=SL1344_0004'],
    ['NC_016810.1', 'RefSeq', 'CDS', 61, 195, '.', '+', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name'
     '=YP_005179941.1;Parent=gene4;gbkey=CDS;product=thr operon leader peptide'
     ';protein_id=YP_005179941.1;transl_table=11'],
    ['NC_016810.1', 'RefSeq', 'gene', 170, 546, '.', '+', '.',
     'ID=gene5;Name=thrC;gbkey=Gene;gene=thrC;locus_tag=SL1344_0005'],
    ['NC_016810.1', 'RefSeq', 'CDS', 34, 335, '.', '+', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name'
     '=YP_005179941.1;Parent=gene5;gbkey=CDS;product=thr operon leader peptide'
     ';protein_id=YP_005179941.1;transl_table=11'],
    ], columns=["seq_id", "source", "type", "start", "end", "score",
                "strand", "phase", "attributes"],
                               index=[0, 2, 7, 8, 9, 10])

compare_overlap_170_171 = pd.DataFrame([
    ['NC_016810.1', 'RefSeq', 'gene', 1, 600, '.', '-', '.',
     'ID=gene3;Name=thrX;gbkey=Gene;gene=thrX;locus_tag=SL1344_0003'],
    ['NC_016810.1', 'RefSeq', 'CDS', 21, 345, '.', '-', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name'
     '=YP_005179941.1;Parent=gene3;gbkey=CDS;product=thr operon leader peptide'
     ';protein_id=YP_005179941.1;transl_table=11'],
    ], columns=["seq_id", "source", "type", "start", "end", "score",
                "strand", "phase", "attributes"],
                               index=[5, 6])

compare_overlap_525_545 = pd.DataFrame([
    ['NC_016810.1', 'RefSeq', 'region', 1, 4000, '.', '+', '.',
     'Dbxref=taxon:216597;ID=id0;gbkey=Src;genome=genomic;mol_type=genomic DNA'
     ';serovar=Typhimurium;strain=SL1344'],
    ['NC_016810.1', 'RefSeq', 'gene', 170, 546, '.', '+', '.',
     'ID=gene5;Name=thrC;gbkey=Gene;gene=thrC;locus_tag=SL1344_0005'],
    ], columns=["seq_id", "source", "type", "start", "end", "score",
                "strand", "phase", "attributes"],
                               index=[0, 9])

compare_overlap_341_500 = pd.DataFrame([
    ['NC_016810.1', 'RefSeq', 'region', 1, 4000, '.', '+', '.',
     'Dbxref=taxon:216597;ID=id0;gbkey=Src;genome=genomic;mol_type=genomic DNA'
     ';serovar=Typhimurium;strain=SL1344'],
    ['NC_016810.1', 'RefSeq', 'CDS', 341, 523, '.', '+', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;'
     'Name=YP_005179941.1;Parent=gene2;gbkey=CDS;product=thr operon leader pep'
     'tide;protein_id=YP_005179941.1;transl_table=11'],
    ['NC_016810.1', 'RefSeq', 'gene', 170, 546, '.', '+', '.',
     'ID=gene5;Name=thrC;gbkey=Gene;gene=thrC;locus_tag=SL1344_0005'],
    ], columns=["seq_id", "source", "type", "start", "end", "score",
                "strand", "phase", "attributes"],
                               index=[0, 4, 9])


compare_complement = pd.DataFrame([
    ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
     'ID=gene1;Name=thrL;gbkey=Gene;gene=thrL;locus_tag=SL1344_0001'],
    ['NC_016810.1', 'RefSeq', 'gene', 1, 20, '.', '+', '.',
     'ID=gene2;Name=thrA;gbkey=Gene;gene=thrA;locus_tag=SL1344_0002'],
    ['NC_016810.1', 'RefSeq', 'CDS', 341, 523, '.', '+', '0',
     'Dbxref=UniProtKB%252FTrEMBL:E1W7M4%2CGenbank:YP_005179941.1;ID=cds0;Name'
     '=YP_005179941.1;Parent=gene2;gbkey=CDS;product=thr operon leader peptide'
     ';protein_id=YP_005179941.1;transl_table=11'],
    ], columns=["seq_id", "source", "type", "start", "end", "score",
                "strand", "phase", "attributes"],
                               index=[1, 3, 4])


def generate_gff3_df():
    read_in_file = gff3pd.read_gff3('fixtures/test_file.gff')
    return read_in_file


def test_read_gff3_if_df_type():
    gff3_df = generate_gff3_df()
    assert type(gff3_df) == gff3pd.Gff3DataFrame
    pd.testing.assert_frame_equal(gff3_df.df, written_df)


def test_generate_gff_header():
    object_header = generate_gff3_df()
    generate_header = object_header._read_gff_header()
    assert type(object_header) == gff3pd.Gff3DataFrame
    assert object_header.header == written_header
    assert generate_header == written_header


def test_if_df_values_equal_gff_values():
    test_df_object = generate_gff3_df()
    test_df = test_df_object._read_gff3_to_df()
    assert type(test_df_object) == gff3pd.Gff3DataFrame
    pd.testing.assert_frame_equal(test_df, written_df)


def setup_module(module):
    gff3_df = generate_gff3_df()
    gff3_df.to_csv('temp.csv')
    gff3_df.to_tsv('temp.tsv')
    gff3_df.to_gff3('temp.gff')
    global csv_content
    global tsv_content
    global gff_content
    csv_content = open('temp.csv').read()
    tsv_content = open('temp.tsv').read()
    gff_content = open('temp.gff').read()


def test_to_csv():
    assert csv_content == written_csv


def test_to_tsv():
    assert tsv_content == written_tsv


def test_to_gff3():
    assert gff_content == written_gff
    read_gff_output = gff3pd.read_gff3('temp.gff')
    read_in_file = gff3pd.read_gff3('fixtures/test_file.gff')
    pd.testing.assert_frame_equal(read_in_file.df, read_gff_output.df)


def teardown_module(module):
    os.remove('temp.csv')
    os.remove('temp.tsv')
    os.remove('temp.gff')


def test_filter_feature_of_type():
    gff3_df = generate_gff3_df()
    object_type_df = gff3_df.filter_feature_of_type(['gene'])
    assert type(object_type_df) == gff3pd.Gff3DataFrame
    assert object_type_df.df.empty == compare_filter_feature_df.empty
    pd.testing.assert_frame_equal(object_type_df.df,
                                  compare_filter_feature_df)
    assert object_type_df.header == written_header


def test_filter_by_length():
    gff3_df = generate_gff3_df()
    filtered_length = gff3_df.filter_by_length(min_length=10, max_length=300)
    assert type(filtered_length) == gff3pd.Gff3DataFrame
    pd.testing.assert_frame_equal(filtered_length.df, written_filtered_length)
    assert filtered_length.header == written_header


def test_get_feature_by_attribute():
    gff3_df = generate_gff3_df()
    filtered_gff3_df = gff3_df.get_feature_by_attribute('gbkey', ['Gene'])
    filtered_gff3_df2 = gff3_df.get_feature_by_attribute('Parent',
                                                         ['gene2', 'gene3',
                                                          'gene4'])
    filtered_gff3_df3 = gff3_df.get_feature_by_attribute('locus_tag',
                                                         ['SL1344_0006'])
    assert type(filtered_gff3_df) == gff3pd.Gff3DataFrame
    assert type(filtered_gff3_df2) == gff3pd.Gff3DataFrame
    assert type(filtered_gff3_df3) == gff3pd.Gff3DataFrame
    assert filtered_gff3_df.df.shape == (5, 9)
    pd.testing.assert_frame_equal(filtered_gff3_df.df,
                                  compare_get_feature_by_attribute)
    pd.testing.assert_frame_equal(filtered_gff3_df2.df,
                                  compare_get_feature_by_attribute2)
    assert filtered_gff3_df3.df.shape == df_empty.shape


def test_attributes_to_columns():
    gff3_df = generate_gff3_df()
    gff3_df_with_attr_columns = gff3_df.attributes_to_columns()
    assert gff3_df_with_attr_columns.shape == (11, 23)
    assert gff3_df_with_attr_columns.shape == written_attribute_df.shape
    assert type(gff3_df_with_attr_columns) == type(written_attribute_df)
    pd.testing.assert_frame_equal(gff3_df_with_attr_columns,
                                  written_attribute_df)


def test_stats_dic():
    gff3_df = generate_gff3_df()
    stats_dict = gff3_df.stats_dic()
    assert type(stats_dict) == type(compare_stats_dic)
    assert stats_dict.keys() == compare_stats_dic.keys()
    assert stats_dict['Maximal_bp_length'] == compare_stats_dic[
        'Maximal_bp_length']
    assert stats_dict['Minimal_bp_length'] == compare_stats_dic[
        'Minimal_bp_length']
    assert stats_dict['Counted_strands'] == compare_stats_dic[
        'Counted_strands']
    assert stats_dict['Counted_feature_types'] == compare_stats_dic[
        'Counted_feature_types']


def test_overlaps_with():
    gff3_df = generate_gff3_df()
    overlap_gene_1_40 = gff3_df.overlaps_with(seq_id='NC_016810.1',
                                              type='gene', start=1,
                                              end=40, strand='+')
    overlap_40_300 = gff3_df.overlaps_with(seq_id='NC_016810.1',
                                           start=40, end=300, strand='+')
    overlap_170_171 = gff3_df.overlaps_with(seq_id='NC_016810.1',
                                            start=170, end=171, strand='-')
    overlap_525_545 = gff3_df.overlaps_with(seq_id='NC_016810.1',
                                            start=525, end=545, strand='+')
    overlap_341_500 = gff3_df.overlaps_with(seq_id='NC_016810.1',
                                            start=341, end=500, strand='+')
    complement_test = gff3_df.overlaps_with(seq_id='NC_016810.1',
                                            start=40, end=300, strand='+',
                                            complement=True)
    out_of_region = gff3_df.overlaps_with(seq_id='NC_016810.1',
                                          start=1, end=4000, strand='+',
                                          complement=True)
    assert type(overlap_gene_1_40) == gff3pd.Gff3DataFrame
    assert type(overlap_40_300) == gff3pd.Gff3DataFrame
    assert type(overlap_170_171) == gff3pd.Gff3DataFrame
    assert type(overlap_525_545) == gff3pd.Gff3DataFrame
    assert type(overlap_341_500) == gff3pd.Gff3DataFrame
    assert type(complement_test) == gff3pd.Gff3DataFrame
    assert type(out_of_region) == gff3pd.Gff3DataFrame
    pd.testing.assert_frame_equal(overlap_gene_1_40.df,
                                  compare_overlap_gene_1_40)
    pd.testing.assert_frame_equal(overlap_40_300.df, compare_overlap_40_300)
    pd.testing.assert_frame_equal(overlap_170_171.df, compare_overlap_170_171)
    pd.testing.assert_frame_equal(overlap_525_545.df, compare_overlap_525_545)
    pd.testing.assert_frame_equal(overlap_341_500.df, compare_overlap_341_500)
    pd.testing.assert_frame_equal(complement_test.df, compare_complement)
    assert out_of_region.df.shape == df_empty.shape


def test_find_duplicated_entries():
    gff3_df = generate_gff3_df()
    redundant_df = gff3_df.find_duplicated_entries(seq_id='NC_016810.1',
                                                   type='gene')
    redundant_df2 = gff3_df.find_duplicated_entries(seq_id='NC_016810.1',
                                                    type='CDS')
    assert type(redundant_df) == gff3pd.Gff3DataFrame
    assert type(redundant_df2) == gff3pd.Gff3DataFrame
    pd.testing.assert_frame_equal(redundant_df.df, redundant_entry)
    assert redundant_df2.df.shape == df_empty.shape
    assert redundant_df.df.empty == redundant_entry.empty
