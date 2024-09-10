// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:d4_scale/d4_scale.dart';
import 'package:flutter_smart_genome/browser/codon_table.dart';
import 'package:flutter_smart_genome/chart/scale/numeric_extents.dart';
import 'package:flutter_smart_genome/chart/scale/pow_scale.dart';
import 'package:flutter_smart_genome/chart/scale/scale.dart';
import 'package:flutter_smart_genome/chart/scale/value_sale_type.dart';
import 'package:flutter_smart_genome/components/blaster.dart';
import 'package:flutter_smart_genome/d3/d3_mixin.dart';
import 'package:flutter_test/flutter_test.dart';

String blastContent = '''BLASTP 2.8.0+
Reference: Stephen F. Altschul, Thomas L. Madden, Alejandro
A. Schaffer, Jinghui Zhang, Zheng Zhang, Webb Miller, and
David J. Lipman (1997), "Gapped BLAST and PSI-BLAST: a new
generation of protein database search programs", Nucleic
Acids Res. 25:3389-3402.


Reference for compositional score matrix adjustment: Stephen
F. Altschul, John C. Wootton, E. Michael Gertz, Richa
Agarwala, Aleksandr Morgulis, Alejandro A. Schaffer, and
Yi-Kuo Yu (2005) "Protein database searches using
compositionally adjusted substitution matrices", FEBS J.
272:5101-5109.


RID: BHP9V3E0013


Database: Non-redundant UniProtKB/SwissProt sequences
           469,156 sequences; 176,816,557 total letters
Query= lcl|FM180568.1_prot_CAS08764.1_1216 [gene=potC] [protein=polyamine
transporter subunit PotC] [protein_id=CAS08764.1]

Length=264


                                                                   Score     E
Sequences producing significant alignments:                       (Bits)  Value

P0AFK8.1  RecName: Full=Spermidine/putrescine transport system...  526     0.0   
Q83RR7.1  RecName: Full=Spermidine/putrescine transport system...  523     0.0   
P45169.1  RecName: Full=Spermidine/putrescine transport system...  361     5e-126
P0AFL2.1  RecName: Full=Putrescine transport system permease p...  172     2e-51 
P0AFR9.1  RecName: Full=Inner membrane ABC transporter permeas...  101     2e-24 
P47290.1  RecName: Full=Spermidine/putrescine transport system...  94.0    2e-21 
P75057.1  RecName: Full=Spermidine/putrescine transport system...  93.2    3e-21 
P41032.2  RecName: Full=Sulfate transport system permease prot...  66.2    2e-11 
P56343.1  RecName: Full=Probable sulfate transport system perm...  64.7    4e-11 
P9WG00.1  RecName: Full=Trehalose transport system permease pr...  61.6    6e-10 
P77156.1  RecName: Full=Inner membrane ABC transporter permeas...  60.8    1e-09 
O57893.1  RecName: Full=Molybdate/tungstate transport system p...  59.3    3e-09 
Q9TJR4.1  RecName: Full=Probable sulfate transport system perm...  59.3    3e-09 
P45170.1  RecName: Full=Spermidine/putrescine transport system...  58.2    9e-09 
D4GQ17.1  RecName: Full=Probable molybdenum ABC transporter pe...  56.6    3e-08 
P0A2J8.1  RecName: Full=Spermidine/putrescine transport system...  55.8    5e-08 
P0AFK4.1  RecName: Full=Spermidine/putrescine transport system...  55.8    6e-08 
O58760.1  RecName: Full=Probable ABC transporter permease prot...  54.7    1e-07 
Q9V2C1.1  RecName: Full=Molybdate/tungstate transport system p...  54.3    2e-07 
P0AF02.1  RecName: Full=Molybdenum transport system permease p...  50.1    4e-06 
Q5JEB3.1  RecName: Full=Molybdate/tungstate transport system p...  50.1    4e-06 
O32154.1  RecName: Full=Probable ABC transporter permease prot...  50.1    6e-06 
P96064.1  RecName: Full=Putative 2-aminoethylphosphonate trans...  49.3    8e-06 
Q57SD7.1  RecName: Full=Putative 2-aminoethylphosphonate trans...  49.3    9e-06 
Q5PFQ6.1  RecName: Full=Putative 2-aminoethylphosphonate trans...  49.3    1e-05 
Q9TKU8.1  RecName: Full=Probable sulfate transport system perm...  48.5    2e-05 
P55452.1  RecName: Full=Probable ABC transporter permease prot...  48.5    2e-05 
Q8U4K4.2  RecName: Full=Molybdate/tungstate transport system p...  47.4    4e-05 
Q01895.2  RecName: Full=Sulfate transport system permease prot...  46.6    7e-05 
Q8Z8W9.1  RecName: Full=Putative 2-aminoethylphosphonate trans...  46.6    8e-05 
Q6QJE2.1  RecName: Full=Sulfate permease 2, chloroplastic; Fla...  44.7    4e-04 
P31135.1  RecName: Full=Putrescine transport system permease p...  43.9    5e-04 
Q9KEE9.1  RecName: Full=L-arabinose transport system permease ...  41.6    0.004 
O32168.1  RecName: Full=Methionine import system permease prot...  39.7    0.013 
Q8RVC7.1  RecName: Full=Sulfate permease 1, chloroplastic; Fla...  40.0    0.014 
P37731.1  RecName: Full=Molybdenum transport system permease p...  39.3    0.016 
Q8ZH39.1  RecName: Full=D-methionine transport system permease...  37.7    0.052 
Q85AI0.1  RecName: Full=Probable sulfate transport system perm...  36.6    0.13  
O58967.1  RecName: Full=Probable ABC transporter permease prot...  36.2    0.17  
P53561.2  RecName: Full=Probable ABC transporter permease prot...  36.2    0.18  
Q8PFT1.1  RecName: Full=Tyrosine--tRNA ligase; AltName: Full=T...  31.6    7.5   
Q3BNC2.1  RecName: Full=Tyrosine--tRNA ligase; AltName: Full=T...  31.2    9.1   
Q5H5K1.2  RecName: Full=Tyrosine--tRNA ligase; AltName: Full=T...  31.2    9.7   

ALIGNMENTS
>P0AFK8.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotC
 P0AFK7.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotC
 P0AFK6.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotC
Length=264

 Score = 526 bits (1356),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 264/264 (100%), Positives = 264/264 (100%), Gaps = 0/264 (0%)

Query  1    MIGRLLRGGFMTAIYAYLYIPIIILIVNSFNSSRFGINWQGFTTKWYSLLMNNDSLLQAA  60
            MIGRLLRGGFMTAIYAYLYIPIIILIVNSFNSSRFGINWQGFTTKWYSLLMNNDSLLQAA
Sbjct  1    MIGRLLRGGFMTAIYAYLYIPIIILIVNSFNSSRFGINWQGFTTKWYSLLMNNDSLLQAA  60

Query  61   QHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFM  120
            QHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFM
Sbjct  61   QHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFM  120

Query  121  LLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPL  180
            LLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPL
Sbjct  121  LLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPL  180

Query  181  AMPAVAAGWVLSFTLSMDDVVVSSFVTGPSYEILPLKIYSMVKVGVSPEVNALATILLVL  240
            AMPAVAAGWVLSFTLSMDDVVVSSFVTGPSYEILPLKIYSMVKVGVSPEVNALATILLVL
Sbjct  181  AMPAVAAGWVLSFTLSMDDVVVSSFVTGPSYEILPLKIYSMVKVGVSPEVNALATILLVL  240

Query  241  SLVMVIASQLIARDKTKGNTGDVK  264
            SLVMVIASQLIARDKTKGNTGDVK
Sbjct  241  SLVMVIASQLIARDKTKGNTGDVK  264


>Q83RR7.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotC
Length=264

 Score = 523 bits (1348),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 263/264 (99%), Positives = 263/264 (99%), Gaps = 0/264 (0%)

Query  1    MIGRLLRGGFMTAIYAYLYIPIIILIVNSFNSSRFGINWQGFTTKWYSLLMNNDSLLQAA  60
            MIGRLLRGGFMTAIYAYLYIPIIILIVNSFNSSRFGINWQGFTTKWYSLLMNNDSLLQAA
Sbjct  1    MIGRLLRGGFMTAIYAYLYIPIIILIVNSFNSSRFGINWQGFTTKWYSLLMNNDSLLQAA  60

Query  61   QHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFM  120
            QHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFM
Sbjct  61   QHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFM  120

Query  121  LLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPL  180
            LLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPL
Sbjct  121  LLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPL  180

Query  181  AMPAVAAGWVLSFTLSMDDVVVSSFVTGPSYEILPLKIYSMVKVGVSPEVNALATILLVL  240
            AMPAVAAGWVLSFTLSMDDVVVSSFVTGPSYEILPLKIYSMVKVGVSPEVNALATILLVL
Sbjct  181  AMPAVAAGWVLSFTLSMDDVVVSSFVTGPSYEILPLKIYSMVKVGVSPEVNALATILLVL  240

Query  241  SLVMVIASQLIARDKTKGNTGDVK  264
            SLVMVIASQLIARDKTKGN GDVK
Sbjct  241  SLVMVIASQLIARDKTKGNGGDVK  264


>P45169.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotC
Length=257

 Score = 361 bits (926),  Expect = 5e-126, Method: Compositional matrix adjust.
 Identities = 179/252 (71%), Positives = 217/252 (86%), Gaps = 0/252 (0%)

Query  6    LRGGFMTAIYAYLYIPIIILIVNSFNSSRFGINWQGFTTKWYSLLMNNDSLLQAAQHSLT  65
            LR  FM  +YAYLYIPIIIL+ NSFN  R+G++W+GF+  WY  L NND+L+QAA HS+T
Sbjct  6    LRNAFMFVVYAYLYIPIIILVTNSFNKDRYGLSWKGFSWNWYERLFNNDTLIQAAIHSVT  65

Query  66   MAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFMLLGIQ  125
            +A F+AT AT++G LTA+ALYRYRFRGK  VSGMLF+VMMSPDIVMA+SLL LFM++GI 
Sbjct  66   IAFFAATLATIVGGLTAIALYRYRFRGKQAVSGMLFIVMMSPDIVMAVSLLALFMVVGIS  125

Query  126  LGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAV  185
            LGFWSLL +H+TFCLP+V VT++SRL GFD RMLEAAKDLGASE TILRKIILPLA+PAV
Sbjct  126  LGFWSLLLAHVTFCLPYVTVTIFSRLNGFDSRMLEAAKDLGASEVTILRKIILPLALPAV  185

Query  186  AAGWVLSFTLSMDDVVVSSFVTGPSYEILPLKIYSMVKVGVSPEVNALATILLVLSLVMV  245
             +GW+LSFT+S+DDVVVSSFV+G SYEILPL+I+S+VK GV+PEVNALATI++VLSL +V
Sbjct  186  VSGWLLSFTISLDDVVVSSFVSGVSYEILPLRIFSLVKTGVTPEVNALATIMIVLSLALV  245

Query  246  IASQLIARDKTK  257
            + SQLI R    
Sbjct  246  VLSQLITRKNNH  257


>P0AFL2.1 RecName: Full=Putrescine transport system permease protein PotI
 P0AFL1.1 RecName: Full=Putrescine transport system permease protein PotI
Length=281

 Score = 172 bits (435),  Expect = 2e-51, Method: Compositional matrix adjust.
 Identities = 101/251 (40%), Positives = 169/251 (67%), Gaps = 8/251 (3%)

Query  15   YAYLYIPIIILIVNSFNSSRFGINWQGFTTKWYSLLMNNDSLLQAAQHSLTMAVFSATFA  74
            + +LY P+++L++ SFNSS+    W G++T+WY  L+ +D+++ A   SLT+A  +AT A
Sbjct  20   FTFLYAPMLMLVIYSFNSSKLVTVWAGWSTRWYGELLRDDAMMSAVGLSLTIAACAATAA  79

Query  75   TLIGSLTAVALYRY-RFRGKPFVSGMLFVVMMSPDIVMAISLLVLFMLLGIQLGF-----  128
             ++G++ AV L R+ RFRG    + M+   ++ PD++  +SLL+LF+ L   +G+     
Sbjct  80   AILGTIAAVVLVRFGRFRGSNGFAFMITAPLVMPDVITGLSLLLLFVALAHAIGWPADRG  139

Query  129  -WSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAA  187
              ++  +H+TFC  +V V + SRL+  D  + EAA DLGA+   +   I LP+ MPA+ +
Sbjct  140  MLTIWLAHVTFCTAYVAVVISSRLRELDRSIEEAAMDLGATPLKVFFVITLPMIMPAIIS  199

Query  188  GWVLSFTLSMDDVVVSSFVTGPSYEILPLKIYSMVKVGVSPEVNALATILL-VLSLVMVI  246
            GW+L+FTLS+DD+V++SFV+GP    LP+ ++S V++GV+PE+NALAT++L  + +V  I
Sbjct  200  GWLLAFTLSLDDLVIASFVSGPGATTLPMLVFSSVRMGVNPEINALATLILGAVGIVGFI  259

Query  247  ASQLIARDKTK  257
            A  L+AR + +
Sbjct  260  AWYLMARAEKQ  270


>P0AFR9.1 RecName: Full=Inner membrane ABC transporter permease protein 
YdcV
 P0AFS0.1 RecName: Full=Inner membrane ABC transporter permease protein 
YdcV
Length=264

 Score = 101 bits (252),  Expect = 2e-24, Method: Compositional matrix adjust.
 Identities = 72/246 (29%), Positives = 136/246 (55%), Gaps = 4/246 (2%)

Query  17   YLYIPIIILIVNSFNSSR--FGINWQGFTTKWYSLLMNNDSLLQAAQHSLTMAVFSATFA  74
            +L+ PI+I+   +FN+    F    QG T +W+S+      +L A   SL +A  +   A
Sbjct  20   FLHFPILIIAAYAFNTEDAAFSFPPQGLTLRWFSVAAQRSDILDAVTLSLKVAALATLIA  79

Query  75   TLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFMLLGIQLGFWSLLFS  134
             ++G+L A AL+R  F GK  +S +L + +  P IV  ++LL  F  + ++ GF++++  
Sbjct  80   LVLGTLAAAALWRRDFFGKNAISLLLLLPIALPGIVTGLALLTAFKTINLEPGFFTIVVG  139

Query  135  HITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFT  194
            H TFC+  V   V +R +     ++EA+ DLGA+ +   R ++LP    A+ AG +L+F 
Sbjct  140  HATFCVVVVFNNVIARFRRTSWSLVEASMDLGANGWQTFRYVVLPNLSSALLAGGMLAFA  199

Query  195  LSMDDVVVSSFVTGPSYEILPLKIYSMV-KVGVSPEVNALATILLVLSLVMVIASQLIAR  253
            LS D+++V++F  G     LPL + + + +    P  N +A ++++++ + ++ +  + R
Sbjct  200  LSFDEIIVTTFTAG-HERTLPLWLLNQLGRPRDVPVTNVVALLVMLVTTLPILGAWWLTR  258

Query  254  DKTKGN  259
            +   G 
Sbjct  259  EGDNGQ  264


>P47290.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotC homolog
Length=284

 Score = 94.0 bits (232),  Expect = 2e-21, Method: Compositional matrix adjust.
 Identities = 77/270 (29%), Positives = 142/270 (53%), Gaps = 19/270 (7%)

Query  4    RLLRGGFMTAIYAYLYIPIIILIVNSFN--SSR------FG--INWQGFTTKWYSLLMNN  53
             L++  +   +   +Y+P++I+++ S N  SSR      FG  +N    +   Y  L   
Sbjct  7    NLIKNSYFFLLITLIYLPLLIVVLVSLNGSSSRGNIVLDFGNVLNPNPDSKSAYLRLGET  66

Query  54   DSLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAI  113
            D       +S+ + V +   +  I  ++A AL R R   K  + G+    + +PDI+ AI
Sbjct  67   D-FATPLINSIIIGVITVLVSVPIAVISAFALLRTRNALKKTIFGITNFSLATPDIITAI  125

Query  114  SLLVLF----MLLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASE  169
            SL++LF    +    QLGF++++ SHI+F +P+ ++ +Y +++  +  ++ A++DLG S 
Sbjct  126  SLVLLFANTWLSFNQQLGFFTIITSHISFSVPYALILIYPKIQKLNPNLILASQDLGYSP  185

Query  170  FTILRKIILPLAMPAVAAGWVLSFTLSMDDVVVSSFVTGPSYEILPLKIYSMVKVGVSPE  229
                  I LP  MP++ +  ++ F  S DD V++S V G S + +  ++YS  K G+   
Sbjct  186  LKTFFHITLPYLMPSIFSAVLVVFATSFDDYVITSLVQG-SVKTIATELYSFRK-GIKAW  243

Query  230  VNALATILLVLSL--VMVIASQLIARDKTK  257
              A  +IL+++S+  V +I  Q   R+K K
Sbjct  244  AIAFGSILILISVLGVCLITLQKYLREKRK  273


>P75057.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotC homolog
Length=286

 Score = 93.2 bits (230),  Expect = 3e-21, Method: Compositional matrix adjust.
 Identities = 72/258 (28%), Positives = 137/258 (53%), Gaps = 23/258 (9%)

Query  6    LRGGFMTAIYAYLYIPIIILIVNSFNSSRFGINWQGFTTKWYSLLMNNDSLLQAAQ----  61
            LRG F   +   +Y+P+II+++ SFN    G + +G     +  ++N +   ++A     
Sbjct  11   LRGSFFVIVLVLIYLPLIIVVLVSFN----GSSTRGNIVLDFGNVLNPNPDAKSAYLRLG  66

Query  62   ---------HSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMA  112
                     +S+ + + +   +  I  +TA AL R R      V G+    + +PDI+  
Sbjct  67   EADFAIPLLNSVIIGLITVIVSIPIAIMTAFALLRSRQWLNKTVFGIANFSLATPDIITG  126

Query  113  ISLLVLF----MLLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGAS  168
            ISL++LF    +    QLGF++++ SHI+F +P+ +V +Y +++  +  ++ A++DLG S
Sbjct  127  ISLVLLFANTWLSFNQQLGFFTIISSHISFSVPYALVLIYPKMQKLNRNLILASQDLGYS  186

Query  169  EFTILRKIILPLAMPAVAAGWVLSFTLSMDDVVVSSFVTGPSYEILPLKIYSMVKVGVSP  228
                   I LP  +P++ +  ++ F  S DD V++S V G S + +  ++YS  K G+  
Sbjct  187  PIATFFHITLPYLLPSILSAILVVFATSFDDYVITSLVQG-SVKTVASELYSFRK-GIKA  244

Query  229  EVNALATILLVLSLVMVI  246
               A  TIL+++S++ V+
Sbjct  245  WAIAFGTILILVSILAVL  262


>P41032.2 RecName: Full=Sulfate transport system permease protein CysT
Length=277

 Score = 66.2 bits (160),  Expect = 2e-11, Method: Compositional matrix adjust.
 Identities = 57/206 (28%), Positives = 96/206 (47%), Gaps = 15/206 (7%)

Query  47   YSLLMNNDSLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMS  106
            Y  ++ N  ++ A + +L  A  ++ F  + G L A  L RYRF G+  +  ++ +    
Sbjct  47   YWDVVTNPQVVAAYKVTLLAAFVASIFNGVFGLLMAWILTRYRFPGRTLLDALMDLPFAL  106

Query  107  PDIVMAISLLVLFMLLGIQLGFWSLLFSHITFC------------LPFVVVTVYSRLKGF  154
            P  V  ++L  LF + G    F +     +T+             +PFVV TV   L+  
Sbjct  107  PTAVAGLTLASLFSVNGFYGQFLAQFDIKVTYTWLGIAVAMAFTSIPFVVRTVQPVLEEL  166

Query  155  DVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDDVVVSSFVTGP---SY  211
                 EAA+ LGA+     RK++LP   PA+ AG  LSFT S+ +     F+ G      
Sbjct  167  GPEYEEAAQTLGATRLQSFRKVVLPELSPALIAGVALSFTRSLGEFGAVIFIAGNIAWKT  226

Query  212  EILPLKIYSMVKVGVSPEVNALATIL  237
            E+  L I+  ++    P  +A+A+++
Sbjct  227  EVTSLMIFVRLQEFDYPAASAIASVI  252


>P56343.1 RecName: Full=Probable sulfate transport system permease protein 
cysT
Length=266

 Score = 64.7 bits (156),  Expect = 4e-11, Method: Compositional matrix adjust.
 Identities = 49/172 (28%), Positives = 82/172 (48%), Gaps = 14/172 (8%)

Query  42   FTTKWYSLLMNNDSLLQAAQHSLT--MAVFSATFATLIGSLTAVALYRYRFRGKPFVSGM  99
            F   W+ +L      +  + + LT  MA ++A   ++ G +    L RY+F G+ F+   
Sbjct  33   FQNNWHEVLRKATDPIAVSAYLLTVQMAFYAALVNSIFGFIITWVLTRYQFWGREFLDAA  92

Query  100  LFVVMMSPDIVMAISLLV----------LFMLLGIQLGFWSL--LFSHITFCLPFVVVTV  147
            + +    P  V  ++L            LF L G Q+ F  +  L + I    PFV+ T+
Sbjct  93   VDLPFALPTSVAGLTLATVYGDQGWIGSLFNLFGFQIVFTKIGVLLAMIFVSFPFVIRTL  152

Query  148  YSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDD  199
               L+  +  + EAA  LGAS +   RK+ILP   PA+  G+ LSF+ ++ +
Sbjct  153  QPVLQEMEKSLEEAAWSLGASSWETFRKVILPTLWPALFTGFTLSFSRALGE  204


>P9WG00.1 RecName: Full=Trehalose transport system permease protein SugB
 P9WG01.1 RecName: Full=Trehalose transport system permease protein SugB
Length=274

 Score = 61.6 bits (148),  Expect = 6e-10, Method: Compositional matrix adjust.
 Identities = 40/153 (26%), Positives = 74/153 (48%), Gaps = 0/153 (0%)

Query  47   YSLLMNNDSLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMS  106
            Y  +   D    A  +S+ + + +   A ++G++ A A+ R  F GK  + G   ++ M 
Sbjct  53   YRGIFRGDLFSSALINSIGIGLITTVIAVVLGAMAAYAVARLEFPGKRLLIGAALLITMF  112

Query  107  PDIVMAISLLVLFMLLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLG  166
            P I +   L  +   +G+   +  L+  +ITF LP  + T+ +  +     + +AAK  G
Sbjct  113  PSISLVTPLFNIERAIGLFDTWPGLILPYITFALPLAIYTLSAFFREIPWDLEKAAKMDG  172

Query  167  ASEFTILRKIILPLAMPAVAAGWVLSFTLSMDD  199
            A+     RK+I+PLA P +    +L F  + +D
Sbjct  173  ATPGQAFRKVIVPLAAPGLVTAAILVFIFAWND  205


>P77156.1 RecName: Full=Inner membrane ABC transporter permease protein 
YdcU
Length=313

 Score = 60.8 bits (146),  Expect = 1e-09, Method: Compositional matrix adjust.
 Identities = 36/116 (31%), Positives = 62/116 (53%), Gaps = 1/116 (1%)

Query  140  LPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDD  199
            LPF+++ V + L+     +L+A+ DLGA      R ++LPLA+P +AAG + +F+L++ D
Sbjct  196  LPFMILPVQAALERLPPSLLQASADLGARPRQTFRYVVLPLAIPGIAAGSIFTFSLTLGD  255

Query  200  VVVSSFVTGPSYEILPLKIYSMVKVGVSPEVNALATILLVL-SLVMVIASQLIARD  254
             +V   V  P Y I  +       +G  P   A   + ++L +L +    +L A D
Sbjct  256  FIVPQLVGPPGYFIGNMVYSQQGAIGNMPMAAAFTLVPIILIALYLAFVKRLGAFD  311


>O57893.1 RecName: Full=Molybdate/tungstate transport system permease protein 
WtpB
Length=248

 Score = 59.3 bits (142),  Expect = 3e-09, Method: Compositional matrix adjust.
 Identities = 53/200 (27%), Positives = 95/200 (48%), Gaps = 8/200 (4%)

Query  1    MIGRLLRGGFMTAIYAYLYIPIIILIVNSFNSSRFGINWQGFTTKWYSLLMNNDSLLQAA  60
            M+GR     F  A+ ++L + I++ IV  F         Q    +     +++  +L+A 
Sbjct  1    MMGRDYALYFFAALGSFLVVYIVLPIVTIFAK-------QALDFEMLVKTVHDPLVLEAL  53

Query  61   QHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFM  120
            ++SL  A  +A  +   G      L R  FRGK FV  ++ V ++ P  V+ I LLV F 
Sbjct  54   RNSLLTATATALISLFFGVPLGYILARKDFRGKNFVQAIIDVPVVIPHSVVGIMLLVTFS  113

Query  121  LLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPL  180
               I   +  ++ + +    PF + +        D ++   A+ LGAS       I LP+
Sbjct  114  N-AILDSYKGIIAAMLFVSAPFAINSARDGFLAVDEKLEHVARTLGASRIRTFFSISLPM  172

Query  181  AMPAVAAGWVLSFTLSMDDV  200
            A+P++A+G ++++  SM +V
Sbjct  173  ALPSIASGGIMAWARSMSEV  192


>Q9TJR4.1 RecName: Full=Probable sulfate transport system permease protein 
cysT
Length=255

 Score = 59.3 bits (142),  Expect = 3e-09, Method: Compositional matrix adjust.
 Identities = 40/149 (27%), Positives = 76/149 (51%), Gaps = 12/149 (8%)

Query  63   SLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFMLL  122
            ++ MA+ +A F ++ G L    + RY F+GK F+   + +    P  V  ++L  ++   
Sbjct  45   TIKMALIAALFNSIFGFLITWVITRYEFKGKKFIDAAVDLPFALPTSVAGLTLATVYGNQ  104

Query  123  G-----IQLGFWSLLFSH-------ITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEF  170
            G     +++G   ++++        I    PFV+ ++   L+G D  + EAA  LGAS F
Sbjct  105  GWVGRFLKMGNLQIIYTKFGVLLAMIFVSFPFVIRSLQPVLQGLDHGLEEAAWCLGASSF  164

Query  171  TILRKIILPLAMPAVAAGWVLSFTLSMDD  199
                ++I P  +PA+  G+ LSF+ ++ +
Sbjct  165  QTFLRVIFPTLVPALVTGFTLSFSRALGE  193


>P45170.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotB
Length=286

 Score = 58.2 bits (139),  Expect = 9e-09, Method: Compositional matrix adjust.
 Identities = 28/69 (41%), Positives = 44/69 (64%), Gaps = 0/69 (0%)

Query  140  LPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDD  199
            LPF+++ +YS ++  D R+LEAA+DLGA+ F    ++ILPL MP + AG +L    +M  
Sbjct  163  LPFMILPLYSAIEKLDNRLLEAARDLGANTFQRFFRVILPLTMPGIIAGCLLVLLPAMGM  222

Query  200  VVVSSFVTG  208
              V+  + G
Sbjct  223  FYVADLLGG  231


>D4GQ17.1 RecName: Full=Probable molybdenum ABC transporter permease protein 
HVO_B0370
Length=269

 Score = 56.6 bits (135),  Expect = 3e-08, Method: Compositional matrix adjust.
 Identities = 43/157 (27%), Positives = 75/157 (48%), Gaps = 8/157 (5%)

Query  51   MNNDSLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIV  110
            + N+ +L AA +S+  A  S   A   G   A  L R  FRG+  +  ++ + ++ P +V
Sbjct  56   VTNEVVLTAATNSVVAATLSTLVAVAFGVPLAYWLSRTSFRGRDVILALVMLPLVLPPVV  115

Query  111  MAISLLVLFMLLGI-QL-------GFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAA  162
              + LL L    G+ QL         + ++ +      PF+VVT  +   G D ++  AA
Sbjct  116  SGMLLLRLVGPAGLGQLTSVPLTRSLFGVVLAQTYVASPFLVVTAKTAFDGVDRQLEAAA  175

Query  163  KDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDD  199
            + LG      +R++ LPLA   + AG  L+F  ++ +
Sbjct  176  RSLGEDRVGSVRRVTLPLAKQGILAGVTLTFARAIGE  212


>P0A2J8.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotB
 E1WF94.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotB
 P0CL49.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotB
Length=287

 Score = 55.8 bits (133),  Expect = 5e-08, Method: Compositional matrix adjust.
 Identities = 29/69 (42%), Positives = 43/69 (62%), Gaps = 0/69 (0%)

Query  140  LPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDD  199
            LPF+V+ +YS ++  D  +LEAA+DLGAS+     +II+PL MP + AG +L    +M  
Sbjct  162  LPFMVMPLYSSIEKLDKPLLEAARDLGASKMQTFIRIIIPLTMPGIVAGCLLVMLPAMGL  221

Query  200  VVVSSFVTG  208
              VS  + G
Sbjct  222  FYVSDLMGG  230


>P0AFK4.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotB
 P0AFK5.1 RecName: Full=Spermidine/putrescine transport system permease 
protein PotB
Length=275

 Score = 55.8 bits (133),  Expect = 6e-08, Method: Compositional matrix adjust.
 Identities = 29/69 (42%), Positives = 43/69 (62%), Gaps = 0/69 (0%)

Query  140  LPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDD  199
            LPF+V+ +YS ++  D  +LEAA+DLGAS+     +II+PL MP + AG +L    +M  
Sbjct  152  LPFMVMPLYSSIEKLDKPLLEAARDLGASKLQTFIRIIIPLTMPGIIAGCLLVMLPAMGL  211

Query  200  VVVSSFVTG  208
              VS  + G
Sbjct  212  FYVSDLMGG  220


>O58760.1 RecName: Full=Probable ABC transporter permease protein PH1036
Length=276

 Score = 54.7 bits (130),  Expect = 1e-07, Method: Compositional matrix adjust.
 Identities = 40/154 (26%), Positives = 74/154 (48%), Gaps = 1/154 (1%)

Query  58   QAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLV  117
            +  ++SL +A+ S     ++ SL A A  RY F  K ++   + ++M  P  +  + L  
Sbjct  68   EGLKNSLIVAIPSTIVPVIVASLAAYAFARYSFPIKHYLFAFIVLLMALPQQMTVVPLYF  127

Query  118  LFMLLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKII  177
            L     +   F  L+  H  + L +++  + +        + EAAK  GA++F I  KI+
Sbjct  128  LLRNAHLLNTFRGLIIVHSAWGLAWIIFFMRNYFSMLPTDVEEAAKIDGATDFQIFYKIV  187

Query  178  LPLAMPAVAAGWVLSFTLSMDDVVVS-SFVTGPS  210
            LP+A+P + +  +L FT    D  ++  F+  P 
Sbjct  188  LPMALPGLISASILQFTWVWSDFFLALVFLQNPE  221


>Q9V2C1.1 RecName: Full=Molybdate/tungstate transport system permease protein 
WtpB
Length=248

 Score = 54.3 bits (129),  Expect = 2e-07, Method: Compositional matrix adjust.
 Identities = 39/150 (26%), Positives = 76/150 (51%), Gaps = 1/150 (1%)

Query  51   MNNDSLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIV  110
            +++  +++A ++SL  A  +A  + L G      L R  FRGK  V  ++ V ++ P  V
Sbjct  44   IHDPLVIEALRNSLLTATATALISLLFGVPLGYVLARKDFRGKSLVQAIIDVPIVIPHSV  103

Query  111  MAISLLVLFMLLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEF  170
            + I LLV F    I   +  ++ + +    PF + +        D ++   A+ LGAS+ 
Sbjct  104  VGIMLLVTFSN-AILDSYKGIIAAMLFVSAPFAINSARDGFLAVDEKLEHVARTLGASKL  162

Query  171  TILRKIILPLAMPAVAAGWVLSFTLSMDDV  200
                 I LP+A+P++A+G ++++   + +V
Sbjct  163  RTFFSISLPIALPSIASGAIMAWARGISEV  192


>P0AF02.1 RecName: Full=Molybdenum transport system permease protein ModB
 P0AF01.1 RecName: Full=Molybdenum transport system permease protein ModB
Length=229

 Score = 50.1 bits (118),  Expect = 4e-06, Method: Compositional matrix adjust.
 Identities = 33/117 (28%), Positives = 64/117 (55%), Gaps = 4/117 (3%)

Query  141  PFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDDV  200
            P +V  +   L+G DV++ +AA+ LGA  + +   I LPL +P +  G VL+F  S+ + 
Sbjct  105  PLMVRAIRLALEGVDVKLEQAARTLGAGRWRVFFTITLPLTLPGIIVGTVLAFARSLGEF  164

Query  201  VVS-SFVTGPSYE--ILPLKIYSMVKV-GVSPEVNALATILLVLSLVMVIASQLIAR  253
              + +FV+    E   +P  +Y++++  G       L  I + L+++ ++ S+ +AR
Sbjct  165  GATITFVSNIPGETRTIPSAMYTLIQTPGGESGAARLCIISIALAMISLLISEWLAR  221


>Q5JEB3.1 RecName: Full=Molybdate/tungstate transport system permease protein 
WtpB
Length=247

 Score = 50.1 bits (118),  Expect = 4e-06, Method: Compositional matrix adjust.
 Identities = 39/150 (26%), Positives = 74/150 (49%), Gaps = 1/150 (1%)

Query  51   MNNDSLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIV  110
            +++  +++A ++SL  A  +A  A L G      L R  F GK  V  ++ V ++ P  V
Sbjct  43   LHDPYVIEAIRNSLLTATATALIALLFGVPLGYVLARKDFPGKSAVQALVDVPIVIPHSV  102

Query  111  MAISLLVLFMLLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEF  170
            + I LLV F    I   +  ++ + +    PF +          D ++   A+ LGAS +
Sbjct  103  VGIMLLVTFSN-SILDSYKGIVAAMLFVSAPFTINAARDGFLAVDEKLEAVARTLGASRW  161

Query  171  TILRKIILPLAMPAVAAGWVLSFTLSMDDV  200
                 I LP+A P++A+G ++++  ++ +V
Sbjct  162  RAFLSISLPMAFPSIASGAIMTWARAISEV  191


>O32154.1 RecName: Full=Probable ABC transporter permease protein YurM
Length=300

 Score = 50.1 bits (118),  Expect = 6e-06, Method: Compositional matrix adjust.
 Identities = 39/190 (21%), Positives = 89/190 (47%), Gaps = 25/190 (13%)

Query  12   TAIYAYLYI-------PIIILIVNSFNSSR--FGINW--------QGFTTKWYSLLMNND  54
            T+++ +L++       P++ +++++F +S   F  +W        + F + W      N 
Sbjct  35   TSVWVFLFLYLIAIAYPLLWMVMSAFKNSDDIFEHSWSLPSSWHPENFVSAW------NQ  88

Query  55   SLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGM-LFVVMMSPDIVMAI  113
             +     +S+ +   +      I +  A  L R+ F+GK F   + L  +M++P + + +
Sbjct  89   GISSYFMNSVIVTALTCVITVFISAWAAYGLSRFEFKGKGFFLVLCLGGLMLTPQVSL-V  147

Query  114  SLLVLFMLLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTIL  173
             L  +   LG+   +W+L+  +  + +PF ++ + S        + EAA   G + F + 
Sbjct  148  PLYSIIQSLGLYNTYWALILPYAAYRIPFTIILIRSYFLSISKELEEAAYLDGCTSFGVF  207

Query  174  RKIILPLAMP  183
             +I LP+++P
Sbjct  208  FRIFLPMSVP  217


>P96064.1 RecName: Full=Putative 2-aminoethylphosphonate transport system 
permease protein PhnU
Length=286

 Score = 49.3 bits (116),  Expect = 8e-06, Method: Compositional matrix adjust.
 Identities = 27/89 (30%), Positives = 46/89 (52%), Gaps = 0/89 (0%)

Query  132  LFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVL  191
            + + IT   P V+  + + L+  D   LEAA  LGA    ++ ++I P A+PA+ AG  L
Sbjct  158  ILAEITVFTPLVMRPLMAALRQIDKSQLEAASILGAHPLRVIGQVIFPAALPALMAGGSL  217

Query  192  SFTLSMDDVVVSSFVTGPSYEILPLKIYS  220
               L+ ++  +  F+       LP+ +YS
Sbjct  218  CLLLTTNEFGIVLFIGAKGVNTLPMMVYS  246


>Q57SD7.1 RecName: Full=Putative 2-aminoethylphosphonate transport system 
permease protein PhnU
Length=286

 Score = 49.3 bits (116),  Expect = 9e-06, Method: Compositional matrix adjust.
 Identities = 27/89 (30%), Positives = 46/89 (52%), Gaps = 0/89 (0%)

Query  132  LFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVL  191
            + + IT   P V+  + + L+  D   LEAA  LGA    ++ ++I P A+PA+ AG  L
Sbjct  158  ILAEITVFTPLVMRPLMAALRQIDKSQLEAASILGAHPLRVIGQVIFPAALPALMAGGSL  217

Query  192  SFTLSMDDVVVSSFVTGPSYEILPLKIYS  220
               L+ ++  +  F+       LP+ +YS
Sbjct  218  CLLLTTNEFGIVLFIGAKGVNTLPMMVYS  246


>Q5PFQ6.1 RecName: Full=Putative 2-aminoethylphosphonate transport system 
permease protein PhnU
Length=289

 Score = 49.3 bits (116),  Expect = 1e-05, Method: Compositional matrix adjust.
 Identities = 27/89 (30%), Positives = 46/89 (52%), Gaps = 0/89 (0%)

Query  132  LFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVL  191
            + + IT   P V+  + + L+  D   LEAA  LGA    ++ ++I P A+PA+ AG  L
Sbjct  158  ILAEITVFTPLVMRPLMAALRQIDKSQLEAASILGAHPLRVIGQVIFPAALPALMAGGSL  217

Query  192  SFTLSMDDVVVSSFVTGPSYEILPLKIYS  220
               L+ ++  +  F+       LP+ +YS
Sbjct  218  CLLLTTNEFGIVLFIGAKGVNTLPMMVYS  246


>Q9TKU8.1 RecName: Full=Probable sulfate transport system permease protein 
cysT
Length=284

 Score = 48.5 bits (114),  Expect = 2e-05, Method: Compositional matrix adjust.
 Identities = 40/149 (27%), Positives = 70/149 (47%), Gaps = 12/149 (8%)

Query  63   SLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFMLL  122
            +L+ A+ +A    + G L A  L RY F G+  +   + +    P  V  ++L  ++   
Sbjct  72   TLSSALIAALLNGVFGLLIAWVLVRYEFPGRRLLDAAVDLPFALPTSVAGLTLATVYSDQ  131

Query  123  G----------IQLGFWSL--LFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEF  170
            G          IQ+ F  L  + + +    PFVV T+   L+  +  + EAA  LGAS F
Sbjct  132  GWIGTWLSSLNIQVAFTRLGVMLAMLFVSFPFVVRTLQPVLQDMERELEEAAWSLGASPF  191

Query  171  TILRKIILPLAMPAVAAGWVLSFTLSMDD  199
                +++ P  MPA+  G  L+F+ ++ +
Sbjct  192  NTFLRVLCPPLMPAMMTGIALAFSRAVGE  220


>P55452.1 RecName: Full=Probable ABC transporter permease protein y4fN
Length=569

 Score = 48.5 bits (114),  Expect = 2e-05, Method: Compositional matrix adjust.
 Identities = 26/89 (29%), Positives = 49/89 (55%), Gaps = 0/89 (0%)

Query  126  LGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAV  185
            +G++ +LF+H      F  + + + ++  D   +EAA+ +GASE TILR ++LP+ +P V
Sbjct  146  IGWFGVLFAHTFLMTSFHFLFLRAAMRRVDYSTIEAARSMGASEMTILRCVVLPVILPTV  205

Query  186  AAGWVLSFTLSMDDVVVSSFVTGPSYEIL  214
             A  +L+   +M        + G  + +L
Sbjct  206  LAVTLLTLITAMGSFAAPQVLGGRDFHML  234


>Q8U4K4.2 RecName: Full=Molybdate/tungstate transport system permease protein 
WtpB
Length=249

 Score = 47.4 bits (111),  Expect = 4e-05, Method: Compositional matrix adjust.
 Identities = 39/143 (27%), Positives = 72/143 (50%), Gaps = 5/143 (3%)

Query  62   HSLTMAVFSATFATLIGSLTAV----ALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLV  117
             S+  ++F+AT +TL+G L  V     L R  F+GK FV  ++   ++ P  V+ I LLV
Sbjct  51   ESIRNSLFTATVSTLLGILFGVPLGYVLARKEFKGKNFVQALIDTPIVIPHSVVGIMLLV  110

Query  118  LFMLLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKII  177
             F    I   +  ++   +    PF+V +        D ++   A+ LGAS       + 
Sbjct  111  TFSD-AILDNYKGIVAVMLFVSSPFIVNSARDGFLSVDEKLEYVARTLGASGLRTFFSVT  169

Query  178  LPLAMPAVAAGWVLSFTLSMDDV  200
            LP A+ ++A+G ++++  ++ +V
Sbjct  170  LPNAIHSIASGAIMAWARAISEV  192


>Q01895.2 RecName: Full=Sulfate transport system permease protein CysT
Length=286

 Score = 46.6 bits (109),  Expect = 7e-05, Method: Compositional matrix adjust.
 Identities = 47/167 (28%), Positives = 76/167 (46%), Gaps = 21/167 (13%)

Query  54   DSLLQAAQHSLTMAVFSATFAT---------LIGSLTAVALYRYRFRGKPFVSGMLFVVM  104
            +   Q A   + ++ ++ TF T         ++G+L A  L R +F GK  V  M+ +  
Sbjct  55   EGFWQIATTPIAISTYNVTFITALAAGLVNGVMGTLVAWVLVRCQFPGKKIVDAMVDLPF  114

Query  105  MSPDIVMAISLLVL----------FMLLGIQLGFWSL-LFSHITF-CLPFVVVTVYSRLK  152
              P  V  + L  L          F   GIQ+ F  L +F  + F  LPF+V T+   L+
Sbjct  115  ALPTSVAGLVLATLYSQTGWVGRFFAPFGIQIAFSRLGVFVAMVFISLPFIVRTLQPVLQ  174

Query  153  GFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDD  199
              +    EAA  LGA+EF    ++I P  +P +  G  L F+ ++ +
Sbjct  175  ELEEEAEEAAWSLGATEFQTFWRVIFPPLIPPILTGIALGFSRAVGE  221


>Q8Z8W9.1 RecName: Full=Putative 2-aminoethylphosphonate transport system 
permease protein PhnU
Length=289

 Score = 46.6 bits (109),  Expect = 8e-05, Method: Compositional matrix adjust.
 Identities = 26/89 (29%), Positives = 45/89 (51%), Gaps = 0/89 (0%)

Query  132  LFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVL  191
            + + IT   P V+  + + L+  D   LEAA  LGA    ++ ++I P A+PA+ A   L
Sbjct  158  ILAEITVFTPLVMRPLMAALRQIDKSQLEAASILGAHPLRVIGQVIFPAALPALMASGSL  217

Query  192  SFTLSMDDVVVSSFVTGPSYEILPLKIYS  220
               L+ ++  +  F+       LP+ +YS
Sbjct  218  CLLLTTNEFGIVLFIGAKGVNTLPMMVYS  246


>Q6QJE2.1 RecName: Full=Sulfate permease 2, chloroplastic; Flags: Precursor
Length=369

 Score = 44.7 bits (104),  Expect = 4e-04, Method: Compositional matrix adjust.
 Identities = 34/139 (24%), Positives = 63/139 (45%), Gaps = 12/139 (9%)

Query  53   NDSLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMA  112
            +   L A + +L +A  +    T+ G++ A+ L R  F GK F+  +L +      +V  
Sbjct  146  DPDFLHALKMTLMLAFVTVPLNTVFGTVAAINLTRNEFPGKVFLMSLLDLPFSISPVVTG  205

Query  113  ISLLVLFMLLG------------IQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLE  160
            + L +L+   G            +   F  +  + +   LPFVV  +   L+  D+   E
Sbjct  206  LMLTLLYGRTGWFAALLRETGINVVFAFTGMALATMFVTLPFVVRELIPILENMDLSQEE  265

Query  161  AAKDLGASEFTILRKIILP  179
            AA+ LGA+++ +   + LP
Sbjct  266  AARTLGANDWQVFWNVTLP  284


>P31135.1 RecName: Full=Putrescine transport system permease protein PotH
Length=317

 Score = 43.9 bits (102),  Expect = 5e-04, Method: Compositional matrix adjust.
 Identities = 23/71 (32%), Positives = 39/71 (55%), Gaps = 0/71 (0%)

Query  140  LPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDD  199
            +PF+V+ +Y+ L   D  ++EAA DLGA        +I+PL    + AG +L F  ++ +
Sbjct  196  VPFMVLPIYTALIRIDYSLVEAALDLGARPLKTFFTVIVPLTKGGIIAGSMLVFIPAVGE  255

Query  200  VVVSSFVTGPS  210
             V+   + GP 
Sbjct  256  FVIPELLGGPD  266


>Q9KEE9.1 RecName: Full=L-arabinose transport system permease protein AraQ
Length=279

 Score = 41.6 bits (96),  Expect = 0.004, Method: Compositional matrix adjust.
 Identities = 33/125 (26%), Positives = 64/125 (51%), Gaps = 6/125 (5%)

Query  63   SLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLFMLL  122
            S+ + V S  F++++G   AV    Y F+G+ F   ++ +++M P  ++ + L  L + L
Sbjct  82   SIVIVVLSLLFSSMVGYALAV----YDFKGRNFFFLLVLIILMIPFEILMLPLFQLMIKL  137

Query  123  GIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAM  182
             +   + +++   I    P  V        G    +++AA+  G +E+ I  KI+LPL  
Sbjct  138  QLVNTYTAVILPAI--VAPIAVFFFRQYALGLPKELMDAARIDGCTEYGIFFKIMLPLMG  195

Query  183  PAVAA  187
            P++AA
Sbjct  196  PSLAA  200


>O32168.1 RecName: Full=Methionine import system permease protein MetP
Length=222

 Score = 39.7 bits (91),  Expect = 0.013, Method: Compositional matrix adjust.
 Identities = 24/68 (35%), Positives = 39/68 (57%), Gaps = 0/68 (0%)

Query  121  LLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILPL  180
            L+G  LG  + L + +    PF    V   L+  D  ++EAAK +GA   TI+ K+++P 
Sbjct  87   LVGTILGPNAALPALVIGSAPFYARLVEIALREVDKGVIEAAKSMGAKTSTIIFKVLIPE  146

Query  181  AMPAVAAG  188
            +MPA+ +G
Sbjct  147  SMPALISG  154


>Q8RVC7.1 RecName: Full=Sulfate permease 1, chloroplastic; Flags: Precursor
Length=411

 Score = 40.0 bits (92),  Expect = 0.014, Method: Compositional matrix adjust.
 Identities = 52/201 (26%), Positives = 95/201 (47%), Gaps = 17/201 (8%)

Query  63   SLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVMMSPDIVMAISLLVLF---  119
            + + ++ +A    + G + A  L RY F GK  +   + +    P  V  ++L  ++   
Sbjct  202  TFSCSLIAAAINCVFGFVLAWVLVRYNFAGKKILDAAVDLPFALPTSVAGLTLATVYGDE  261

Query  120  -------MLLGIQLGFWSL--LFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEF  170
                      G+Q+ F  L  + + I    PFVV T+   ++     M EAA  LGAS++
Sbjct  262  FFIGQFLQAQGVQVVFTRLGVVIAMIFVSFPFVVRTMQPVMQEIQKEMEEAAWSLGASQW  321

Query  171  TILRKIILPLAMPAVAAGWVLSFTLSMDD----VVVSSFVTGPSYEILPLKIYSMVKVGV  226
                 ++LP  +PA+  G  L+F+ ++ +    V+VSS        I P+ I+  ++   
Sbjct  322  RTFTDVVLPPLLPALLTGTALAFSRALGEFGSIVIVSSNFAFKDL-IAPVLIFQCLEQYD  380

Query  227  SPEVNALATILLVLSLVMVIA  247
                  + T+LL++SLVM++A
Sbjct  381  YVGATVIGTVLLLISLVMMLA  401


>P37731.1 RecName: Full=Molybdenum transport system permease protein ModB
Length=226

 Score = 39.3 bits (90),  Expect = 0.016, Method: Compositional matrix adjust.
 Identities = 41/162 (25%), Positives = 68/162 (42%), Gaps = 17/162 (10%)

Query  53   NDSLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGK--------------PFVSG  98
            ++  L A + +L +A  +     ++G+  A  L R R R K              P V G
Sbjct  4    SEHDLAAIRLTLELASLTTVLLLVVGTPIAWWLARTRSRLKGAIGAVVALPLVLPPTVLG  63

Query  99   MLFVVMMSPDIVMAISLLVLFMLLG-IQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVR  157
               +V M P     I  L  F+ LG +   F  L+ + + + LPFVV  + +  +    R
Sbjct  64   FYLLVTMGPH--GPIGQLTQFLGLGTLPFTFAGLVVASVFYSLPFVVQPLQNAFEAIGER  121

Query  158  MLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDD  199
             LE A  L A  +     +++PLA P      +L F  ++ +
Sbjct  122  PLEVASTLRAGPWDTFFTVVVPLARPGFITAAILGFAHTVGE  163


>Q8ZH39.1 RecName: Full=D-methionine transport system permease protein 
MetI
Length=217

 Score = 37.7 bits (86),  Expect = 0.052, Method: Compositional matrix adjust.
 Identities = 18/65 (28%), Positives = 35/65 (54%), Gaps = 0/65 (0%)

Query  120  MLLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKIILP  179
            M++G  +G  + +        PF+   V + L      ++EAA+ +GA+   I++K++LP
Sbjct  81   MIVGTSIGLQAAIVPLTVGAAPFIARMVENALLEIPSGLVEAARAMGATPMQIIKKVLLP  140

Query  180  LAMPA  184
             A+P 
Sbjct  141  EALPG  145


>Q85AI0.1 RecName: Full=Probable sulfate transport system permease protein 
cysT
Length=288

 Score = 36.6 bits (83),  Expect = 0.13, Method: Compositional matrix adjust.
 Identities = 46/172 (27%), Positives = 77/172 (45%), Gaps = 35/172 (20%)

Query  56   LLQAAQHSLTMAVFSATFAT---------LIGSLTAVALYRYRFRGK---------PF--  95
            LL+     + ++ ++ TF+T         L G + A  L +Y F GK         PF  
Sbjct  60   LLKVTTEPIILSAYATTFSTAFLAITINALFGLIIAWILVKYEFTGKETLDAIVDLPFAL  119

Query  96   ---VSGMLFVVMMSP-----DIVMAISLLVLFMLLGIQLGFWSLLFSHITFCLPFVVVTV  147
               V G+  + + S       I   + L ++F  LG+ +       + I   LPFVV T+
Sbjct  120  PASVGGLTLMTVYSDRGWMGPICSGLGLKIVFSRLGVPM-------ATIFVSLPFVVRTI  172

Query  148  YSRLKGFDVRMLEAAKDLGASEFTILRKIILPLAMPAVAAGWVLSFTLSMDD  199
               L+  +  + EAA  +GAS +T   +I LPL  P++  G  L F+ ++ +
Sbjct  173  QPVLQDVEEELEEAAWCIGASPWTTFCQISLPLLTPSLLTGTALGFSRAIGE  224


>O58967.1 RecName: Full=Probable ABC transporter permease protein PH1216
Length=275

 Score = 36.2 bits (82),  Expect = 0.17, Method: Compositional matrix adjust.
 Identities = 35/142 (25%), Positives = 63/142 (44%), Gaps = 7/142 (5%)

Query  62   HSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLFVVM----MSPDIVMAISLLV  117
            +SL    F+  F+T++GS+    + +   RG+  VS  L  ++      P   + I L+ 
Sbjct  70   NSLIFTTFATIFSTILGSIAGFTIAKL-VRGR--VSRQLLALISFGIFLPYQSILIPLVK  126

Query  118  LFMLLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKII  177
            +   LG+      L+ +H  + +P   +   +        ++EAAK  GA  + I  K+I
Sbjct  127  IISSLGLYNRILGLILTHTAYGIPITTLLFTNYYYEIPDELVEAAKIDGADPWKIYTKVI  186

Query  178  LPLAMPAVAAGWVLSFTLSMDD  199
            LPL+        +  FT   +D
Sbjct  187  LPLSKAPFVVTGIYQFTNIWND  208


>P53561.2 RecName: Full=Probable ABC transporter permease protein YtcP
Length=286

 Score = 36.2 bits (82),  Expect = 0.18, Method: Compositional matrix adjust.
 Identities = 46/189 (24%), Positives = 81/189 (43%), Gaps = 20/189 (11%)

Query  9    GFMTAIYAYLYIPIIILIVNSFN------SSRFGINWQGFTTKWYSLLMNNDSLLQAAQH  62
            GF+        +P I +I  SF       S +F +    F+   Y  + + D + ++   
Sbjct  12   GFLLMFALICVLPFIHVIAASFATVEEVVSKKFILIPTTFSLDAYRYIFSTDIIYKSLLV  71

Query  63   SLTMAVFSATFATLIGSLTAVALYRYRFRGKP-----FVSGMLFVVMMSPDIVMAISLLV  117
            S+ + V     +  + SL A  L R    G+       V  MLF   M P  ++  SL  
Sbjct  72   SVFVTVIGTAVSMFLSSLMAYGLSRRDLIGRQPLMFLVVFTMLFSGGMIPTFLVVKSL--  129

Query  118  LFMLLGIQLGFWSLLFSHITFCLPFVVVTVYSRLKGFDVRMLEAAKDLGASEFTILRKII  177
                 G+   +W+L+    T    F ++ + +  +     + E+AK  G ++  I  KI+
Sbjct  130  -----GLLDSYWALILP--TAINAFNLIILKNFFQNIPSSLEESAKIDGCNDLGIFFKIV  182

Query  178  LPLAMPAVA  186
            LPL++PA+A
Sbjct  183  LPLSLPAIA  191


>Q8PFT1.1 RecName: Full=Tyrosine--tRNA ligase; AltName: Full=Tyrosyl-tRNA 
synthetase; Short=TyrRS
Length=403

 Score = 31.6 bits (70),  Expect = 7.5, Method: Compositional matrix adjust.
 Identities = 21/102 (21%), Positives = 44/102 (43%), Gaps = 4/102 (4%)

Query  42   FTTKWYSLLMNNDSLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLF  101
            F ++W+  +   D +  +AQH++   +    FA   GS   +A++ + +   P V G   
Sbjct  121  FNSEWFGQMSAADMIKLSAQHTVARMLERDDFAKRFGSQQPIAIHEFLY---PLVQGYDS  177

Query  102  VVMMSPDIVMAISLLVLFMLLGIQLGFWSLLFSHITFCLPFV  143
            V + + D+ +  +     +L+G  L         I   +P +
Sbjct  178  VALKA-DVELGGTDQKFNLLMGRGLQEHYGQAPQIVLTMPLL  218


>Q3BNC2.1 RecName: Full=Tyrosine--tRNA ligase; AltName: Full=Tyrosyl-tRNA 
synthetase; Short=TyrRS
Length=403

 Score = 31.2 bits (69),  Expect = 9.1, Method: Compositional matrix adjust.
 Identities = 18/82 (22%), Positives = 39/82 (48%), Gaps = 4/82 (5%)

Query  42   FTTKWYSLLMNNDSLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLF  101
            F ++W+  +   D +  +AQH++   +    FA   GS   +A++ + +   P V G   
Sbjct  121  FNSEWFGQMSAADMIKLSAQHTVARMLERDDFAKRFGSQQPIAIHEFLY---PLVQGYDS  177

Query  102  VVMMSPDIVMAISLLVLFMLLG  123
            V + + D+ +  +     +L+G
Sbjct  178  VALKA-DVELGGTDQKFNLLMG  198


>Q5H5K1.2 RecName: Full=Tyrosine--tRNA ligase; AltName: Full=Tyrosyl-tRNA 
synthetase; Short=TyrRS
 Q2P892.1 RecName: Full=Tyrosine--tRNA ligase; AltName: Full=Tyrosyl-tRNA 
synthetase; Short=TyrRS
Length=403

 Score = 31.2 bits (69),  Expect = 9.7, Method: Compositional matrix adjust.
 Identities = 18/82 (22%), Positives = 39/82 (48%), Gaps = 4/82 (5%)

Query  42   FTTKWYSLLMNNDSLLQAAQHSLTMAVFSATFATLIGSLTAVALYRYRFRGKPFVSGMLF  101
            F ++W+  +   D +  +AQH++   +    FA   GS   +A++ + +   P V G   
Sbjct  121  FNSEWFGQMSAADMIKLSAQHTVARMLERDDFAKRFGSQQPIAIHEFLY---PLVQGYDS  177

Query  102  VVMMSPDIVMAISLLVLFMLLG  123
            V + + D+ +  +     +L+G
Sbjct  178  VALRA-DVELGGTDQKFNLLMG  198


Query= lcl|FM180568.1_prot_CAS08754.1_1206 [gene=mfd]
[protein=transcription-repair coupling factor] [protein_id=CAS08754.1]

Length=1148


                                                                   Score     E
Sequences producing significant alignments:                       (Bits)  Value

P30958.2  RecName: Full=Transcription-repair-coupling factor; ...  2348    0.0   
P45128.1  RecName: Full=Transcription-repair-coupling factor; ...  1548    0.0   
P57381.1  RecName: Full=Transcription-repair-coupling factor; ...  887     0.0   
Q89AK2.1  RecName: Full=Transcription-repair-coupling factor; ...  794     0.0   
P37474.1  RecName: Full=Transcription-repair-coupling factor; ...  715     0.0   
Q5HRQ2.1  RecName: Full=Transcription-repair-coupling factor; ...  704     0.0   
Q8CMT1.1  RecName: Full=Transcription-repair-coupling factor; ...  702     0.0   
Q4L3G0.1  RecName: Full=Transcription-repair-coupling factor; ...  698     0.0   
Q6GJG8.1  RecName: Full=Transcription-repair-coupling factor; ...  691     0.0   
Q5HIH2.1  RecName: Full=Transcription-repair-coupling factor; ...  690     0.0   
Q2G0R8.1  RecName: Full=Transcription-repair-coupling factor; ...  689     0.0   
Q7A7B2.1  RecName: Full=Transcription-repair-coupling factor; ...  689     0.0   
Q6GBY5.1  RecName: Full=Transcription-repair-coupling factor; ...  687     0.0   
Q2YVY2.1  RecName: Full=Transcription-repair-coupling factor; ...  685     0.0   
O52236.1  RecName: Full=Transcription-repair-coupling factor; ...  669     0.0   
Q49V12.1  RecName: Full=Transcription-repair-coupling factor; ...  667     0.0   
Q4UMJ0.1  RecName: Full=Transcription-repair-coupling factor; ...  620     0.0   
Q92H58.1  RecName: Full=Transcription-repair-coupling factor; ...  619     0.0   
O05955.2  RecName: Full=Transcription-repair-coupling factor; ...  616     0.0   
Q9AKD5.1  RecName: Full=Transcription-repair-coupling factor; ...  608     0.0   
Q1RI82.1  RecName: Full=Transcription-repair-coupling factor; ...  606     0.0   
Q55750.1  RecName: Full=Transcription-repair-coupling factor; ...  597     0.0   
O51568.1  RecName: Full=Transcription-repair-coupling factor; ...  590     0.0   
P64327.1  RecName: Full=Transcription-repair-coupling factor; ...  575     0.0   
Q9ZJ57.1  RecName: Full=Transcription-repair-coupling factor; ...  468     5e-146
O26066.1  RecName: Full=Transcription-repair-coupling factor; ...  466     2e-145
F4JFJ3.1  RecName: Full=ATP-dependent DNA helicase At3g02060, ...  400     2e-122
Q54900.2  RecName: Full=ATP-dependent DNA helicase RecG            265     7e-75 
Q55681.1  RecName: Full=ATP-dependent DNA helicase RecG            266     3e-74 
O34942.1  RecName: Full=ATP-dependent DNA helicase RecG            263     3e-74 
O67837.1  RecName: Full=ATP-dependent DNA helicase RecG            264     1e-73 
O51528.1  RecName: Full=ATP-dependent DNA helicase RecG            258     2e-72 
O50581.1  RecName: Full=ATP-dependent DNA helicase RecG            255     3e-71 
Q5HPW4.1  RecName: Full=ATP-dependent DNA helicase RecG            254     4e-71 
Q8CSV3.1  RecName: Full=ATP-dependent DNA helicase RecG            254     6e-71 
P64325.1  RecName: Full=ATP-dependent DNA helicase RecG            253     1e-70 
Q8NX11.1  RecName: Full=ATP-dependent DNA helicase RecG            250     1e-69 
Q6GHK8.1  RecName: Full=ATP-dependent DNA helicase RecG            249     3e-69 
P96130.1  RecName: Full=ATP-dependent DNA helicase RecG            241     2e-66 
Q9CMB4.1  RecName: Full=ATP-dependent DNA helicase RecG            239     1e-65 
P43809.1  RecName: Full=ATP-dependent DNA helicase RecG            238     2e-65 
Q8XD86.1  RecName: Full=ATP-dependent DNA helicase RecG            232     3e-63 
P24230.1  RecName: Full=ATP-dependent DNA helicase RecG            231     5e-63 
P64323.1  RecName: Full=ATP-dependent DNA helicase RecG            218     4e-58 
F4INA9.1  RecName: Full=ATP-dependent DNA helicase homolog REC...  219     2e-57 
O69460.2  RecName: Full=ATP-dependent DNA helicase RecG            202     5e-53 
Q9ZJA1.1  RecName: Full=ATP-dependent DNA helicase RecG            166     9e-42 
O26051.1  RecName: Full=ATP-dependent DNA helicase RecG            164     6e-41 
O50224.1  RecName: Full=ATP-dependent DNA helicase RecG            95.1    1e-18 
A9IR19.1  RecName: Full=UvrABC system protein B; Short=Protein...  83.6    5e-15 
Q7WK66.1  RecName: Full=UvrABC system protein B; Short=Protein...  79.0    1e-13 
Q7W8V6.1  RecName: Full=UvrABC system protein B; Short=Protein...  79.0    1e-13 
Q473K3.1  RecName: Full=UvrABC system protein B; Short=Protein...  76.3    8e-13 
Q2L244.1  RecName: Full=UvrABC system protein B; Short=Protein...  76.3    9e-13 
Q7VXH4.1  RecName: Full=UvrABC system protein B; Short=Protein...  75.9    1e-12 
Q62CK6.1  RecName: Full=UvrABC system protein B; Short=Protein...  75.5    1e-12 
C5CFR8.1  RecName: Full=UvrABC system protein B; Short=Protein...  75.1    2e-12 
Q73MY7.1  RecName: Full=UvrABC system protein B; Short=Protein...  74.7    2e-12 
P72174.2  RecName: Full=UvrABC system protein B; Short=Protein...  73.2    8e-12 
Q5P0E7.1  RecName: Full=UvrABC system protein B; Short=Protein...  71.6    2e-11 
Q6F9D2.1  RecName: Full=UvrABC system protein B; Short=Protein...  71.2    3e-11 
Q6LT47.1  RecName: Full=UvrABC system protein B; Short=Protein...  70.9    4e-11 
Q6D3C4.1  RecName: Full=UvrABC system protein B; Short=Protein...  70.5    5e-11 
Q3KF38.1  RecName: Full=UvrABC system protein B; Short=Protein...  70.5    5e-11 
C6DDU0.1  RecName: Full=UvrABC system protein B; Short=Protein...  70.1    8e-11 
Q884C9.1  RecName: Full=UvrABC system protein B; Short=Protein...  70.1    8e-11 
Q8Y0N2.1  RecName: Full=UvrABC system protein B; Short=Protein...  70.1    8e-11 
Q4KF19.1  RecName: Full=UvrABC system protein B; Short=Protein...  69.3    1e-10 
Q48KA6.1  RecName: Full=UvrABC system protein B; Short=Protein...  68.6    2e-10 
Q03JK4.1  RecName: Full=UvrABC system protein B; Short=Protein...  67.8    4e-10 
Q5LYS1.1  RecName: Full=UvrABC system protein B; Short=Protein...  67.8    4e-10 
A3N031.1  RecName: Full=UvrABC system protein B; Short=Protein...  67.8    4e-10 
Q7VLL3.1  RecName: Full=UvrABC system protein B; Short=Protein...  67.0    7e-10 
Q3ZZK7.1  RecName: Full=UvrABC system protein B; Short=Protein...  66.2    1e-09 
B4ESU7.1  RecName: Full=UvrABC system protein B; Short=Protein...  66.2    1e-09 
Q8P0J7.1  RecName: Full=UvrABC system protein B; Short=Protein...  65.9    1e-09 
B9DSH1.1  RecName: Full=UvrABC system protein B; Short=Protein...  65.9    1e-09 
Q48SZ1.1  RecName: Full=UvrABC system protein B; Short=Protein...  65.9    1e-09 
Q1JBD1.1  RecName: Full=UvrABC system protein B; Short=Protein...  65.9    1e-09 
A2RE43.1  RecName: Full=UvrABC system protein B; Short=Protein...  65.9    1e-09 
Q5XBN4.1  RecName: Full=UvrABC system protein B; Short=Protein...  65.5    2e-09 
Q8CWX7.1  RecName: Full=UvrABC system protein B; Short=Protein...  65.5    2e-09 
Q99ZA5.1  RecName: Full=UvrABC system protein B; Short=Protein...  65.5    2e-09 
Q1J665.1  RecName: Full=UvrABC system protein B; Short=Protein...  65.5    2e-09 
Q9CI06.1  RecName: Full=UvrABC system protein B; Short=Protein...  65.5    2e-09 
Q1JGE8.1  RecName: Full=UvrABC system protein B; Short=Protein...  65.5    2e-09 
Q8DYL6.1  RecName: Full=UvrABC system protein B; Short=Protein...  64.7    3e-09 
Q3K051.1  RecName: Full=UvrABC system protein B; Short=Protein...  64.7    3e-09 
B7KC96.1  RecName: Full=UvrABC system protein B; Short=Protein...  64.7    4e-09 
B4U3P4.1  RecName: Full=UvrABC system protein B; Short=Protein...  64.3    4e-09 
A4W1F7.1  RecName: Full=UvrABC system protein B; Short=Protein...  64.3    5e-09 
C0MDC6.1  RecName: Full=UvrABC system protein B; Short=Protein...  63.9    6e-09 
Q031G7.1  RecName: Full=UvrABC system protein B; Short=Protein...  63.5    7e-09 
A2RIP3.1  RecName: Full=UvrABC system protein B; Short=Protein...  63.5    7e-09 
P44647.1  RecName: Full=Primosomal protein N'; AltName: Full=A...  63.2    1e-08 
C0MBD7.1  RecName: Full=UvrABC system protein B; Short=Protein...  63.2    1e-08 
A8AX17.1  RecName: Full=UvrABC system protein B; Short=Protein...  63.2    1e-08 
A3CNJ9.1  RecName: Full=UvrABC system protein B; Short=Protein...  62.8    1e-08 
Q58796.1  RecName: Full=Probable ATP-dependent helicase MJ1401     62.4    2e-08 
Q74K90.1  RecName: Full=UvrABC system protein B; Short=Protein...  62.4    2e-08 

ALIGNMENTS
>P30958.2 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1148

 Score = 2348 bits (6085),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 1142/1148 (99%), Positives = 1146/1148 (99%), Gaps = 0/1148 (0%)

Query  1     MPEQYRYTLPVKAGEQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEIS  60
             MPEQYRYTLPVKAGEQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEIS
Sbjct  1     MPEQYRYTLPVKAGEQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEIS  60

Query  61    QFTDQMVMNLADWETLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPH  120
             QFTDQMVMNLADWETLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPH
Sbjct  61    QFTDQMVMNLADWETLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPH  120

Query  121   SFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPY  180
             SFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPY
Sbjct  121   SFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPY  180

Query  181   RLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFEVKRD  240
             RLDFFDDEIDSLRVFDVDSQRTLEEV+AINLLPAHEFPTDKAAIELFRSQWRDTFEVKRD
Sbjct  181   RLDFFDDEIDSLRVFDVDSQRTLEEVEAINLLPAHEFPTDKAAIELFRSQWRDTFEVKRD  240

Query  241   PEHIYQQVSKGTLPAGIEYWQPLFFSEPLPPLFSYFPANTLLVNTGDLENSAERFQADTL  300
             PEHIYQQVSKGTLPAGIEYWQPLFFSEPLPPLFSYFPANTLLVNTGDLE SAERFQADTL
Sbjct  241   PEHIYQQVSKGTLPAGIEYWQPLFFSEPLPPLFSYFPANTLLVNTGDLETSAERFQADTL  300

Query  301   ARFENRGVDPMRPLLPPQSLWLRVDELFSELKNWPRVQLKTEHLPTKAANANLGFQKLPD  360
             ARFENRGVDPMRPLLPPQSLWLRVDELFSELKNWPRVQLKTEHLPTKAANANLGFQKLPD
Sbjct  301   ARFENRGVDPMRPLLPPQSLWLRVDELFSELKNWPRVQLKTEHLPTKAANANLGFQKLPD  360

Query  361   LAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEASD  420
             LA+QAQQKAPLDALRKFLE+FDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEASD
Sbjct  361   LAVQAQQKAPLDALRKFLETFDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEASD  420

Query  421   RGRYLMIGAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRNLAELHIG  480
             RGRYLMIGAAEHGFVDTVRNLALICESDLLGERVARRRQDSRR INPDTLIRNLAELHIG
Sbjct  421   RGRYLMIGAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRTINPDTLIRNLAELHIG  480

Query  481   QPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAEENA  540
             QPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAEENA
Sbjct  481   QPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAEENA  540

Query  541   PLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSFPFE  600
             PLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSFPFE
Sbjct  541   PLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSFPFE  600

Query  601   TTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVPTTL  660
             TTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVPTTL
Sbjct  601   TTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVPTTL  660

Query  661   LAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKF  720
             LAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKF
Sbjct  661   LAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKF  720

Query  721   KDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIATPP  780
             KDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIATPP
Sbjct  721   KDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIATPP  780

Query  781   ARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEARIAI  840
             ARRLAVKTFVREYDS+VVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEARIAI
Sbjct  781   ARRLAVKTFVREYDSMVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEARIAI  840

Query  841   GHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLR  900
             GHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLR
Sbjct  841   GHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLR  900

Query  901   GRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLG  960
             GRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLG
Sbjct  901   GRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLG  960

Query  961   EEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFIPDV  1020
             EEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFIPDV
Sbjct  961   EEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFIPDV  1020

Query  1021  NTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKLEG  1080
             NTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKLEG
Sbjct  1021  NTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKLEG  1080

Query  1081  NEKGGVIEFAEKNHVNPAWLIGLLQKQPQHYRLDGPTRLKFIQDLSERKTRIEWVRQFMR  1140
             NEKGGVIEFAEKNHVNPAWLIGLLQKQPQHYRLDGPTRLKFIQDLSERKTRIEWVRQFMR
Sbjct  1081  NEKGGVIEFAEKNHVNPAWLIGLLQKQPQHYRLDGPTRLKFIQDLSERKTRIEWVRQFMR  1140

Query  1141  ELEENAIA  1148
             ELEENAIA
Sbjct  1141  ELEENAIA  1148


>P45128.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1146

 Score = 1548 bits (4008),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 732/1136 (64%), Positives = 924/1136 (81%), Gaps = 3/1136 (0%)

Query  9     LPVKAGEQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
             +P +  + ++LG +   A A  ++EI+E++    V++ PD ++A+RL   +S+ + Q V 
Sbjct  10    IPTQPNDHKILGNVLPGADALAISEISEQNQNLTVVVTPDTRSAVRLSRVLSELSSQDVC  69

Query  69    NLADWETLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHAL  128
                DWETLPYD+FSPHQ+IISSRLS L+ L   ++G+ ++P++TLMQR+CP  +L  + L
Sbjct  70    LFPDWETLPYDTFSPHQEIISSRLSALFHLQNAKKGIFLLPISTLMQRLCPPQYLQHNVL  129

Query  129   VMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDE  188
             ++KKG RL  D +R QL++AGYR V+QV+EHGEYA RGALLDLFPMGS +P+RLDFFDDE
Sbjct  130   LIKKGDRLVIDKMRLQLEAAGYRAVEQVLEHGEYAVRGALLDLFPMGSAVPFRLDFFDDE  189

Query  189   IDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTF-EVKRDPEHIYQQ  247
             IDS+R FDVD+QRTL+E+ +INLLPAHEFPTD   IE FR+Q+R+TF E++RDPEHIYQQ
Sbjct  190   IDSIRTFDVDTQRTLDEISSINLLPAHEFPTDDKGIEFFRAQFRETFGEIRRDPEHIYQQ  249

Query  248   VSKGTLPAGIEYWQPLFFSEPLPPLFSYFPANTLLVNTGDLENSAERFQADTLARFENRG  307
             +SKGTL +GIEYWQPLFF+E +  LF Y P  TL V+  + +   ERF  D   R+E R 
Sbjct  250   ISKGTLISGIEYWQPLFFAE-MATLFDYLPEQTLFVDMENNQTQGERFYQDAKQRYEQRK  308

Query  308   VDPMRPLLPPQSLWLRVDELFSELKNWPRVQLKTEHLPTKAANANLGFQKLPDLAIQAQQ  367
             VDPMRPLL P+ LWL VDE+   LK++PR+  K E + +     NL    LP++ IQ+QQ
Sbjct  309   VDPMRPLLSPEKLWLNVDEVNRRLKSYPRITFKAEKVRSSVRQKNLPVAALPEVTIQSQQ  368

Query  368   KAPLDALRKFLESFDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEASDRGRYLMI  427
             K PL  LR+F+E F G V+FSVE+EGRRE L +LL+ +K+ P++I  L++  +    L++
Sbjct  369   KEPLGQLRQFIEHFKGNVLFSVETEGRRETLLDLLSPLKLKPKQIQSLEQIENEKFSLLV  428

Query  428   GAAEHGFV-DTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRNLAELHIGQPVVHL  486
              + E GF+ +    +A+I E++LLG+R+ +R +D R+ INPDTL+RNLAEL IGQPVVHL
Sbjct  429   SSLEQGFIIEQSLPVAIIGEANLLGKRIQQRSRDKRKTINPDTLVRNLAELKIGQPVVHL  488

Query  487   EHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAEENAPLHKLG  546
             +HGVGRY G+ TL+ GGI  EYL+L YAN++KLYVPV+SLHLISRY GG++E+APLHKLG
Sbjct  489   DHGVGRYGGLVTLDTGGIKAEYLLLNYANESKLYVPVTSLHLISRYVGGSDESAPLHKLG  548

Query  547   GDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSFPFETTPDQA  606
              +AW+++RQKAAEK+RDVAAELLD+YAQR AK+GFAFK+DRE++Q F  +FPFE T DQ 
Sbjct  549   NEAWAKSRQKAAEKIRDVAAELLDVYAQREAKKGFAFKYDREEFQQFSATFPFEETYDQE  608

Query  607   QAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHY  666
              AINAV+SDMCQP AMDRLVCGDVGFGKTEVAMRAAFLAV NHKQVAVLVPTTLLAQQHY
Sbjct  609   MAINAVISDMCQPKAMDRLVCGDVGFGKTEVAMRAAFLAVMNHKQVAVLVPTTLLAQQHY  668

Query  667   DNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLL  726
             +NF+DRFAN PV +E++SRF++AKEQ QIL  +AEGK+DILIGTHKL+QSDVKF DLGLL
Sbjct  669   ENFKDRFANLPVNVEVLSRFKTAKEQKQILENLAEGKVDILIGTHKLIQSDVKFNDLGLL  728

Query  727   IVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLAV  786
             I+DEEHRFGV  KE+IK +RAN+DILTLTATPIPRTLNMAM+G+RDLSII+TPPARRL++
Sbjct  729   IIDEEHRFGVGQKEKIKQLRANIDILTLTATPIPRTLNMAMNGIRDLSIISTPPARRLSI  788

Query  787   KTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEARIAIGHGQMR  846
             KTFVR+ D LVVREAILREILRGGQVYYL+NDV +I+  AE+L  LVPEAR+ +GHGQMR
Sbjct  789   KTFVRQNDDLVVREAILREILRGGQVYYLHNDVASIENTAEKLTALVPEARVIVGHGQMR  848

Query  847   ERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRS  906
             ERELERVM+DF+HQR+NVLVC+TIIETGID+PTANTIIIERADHFGLAQLHQLRGRVGRS
Sbjct  849   ERELERVMSDFYHQRYNVLVCSTIIETGIDVPTANTIIIERADHFGLAQLHQLRGRVGRS  908

Query  907   HHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSGS  966
             HHQAYA+LLTP PK MT DA++RL+A+ +L++LGAGF LATHDLEIRGAGELLG EQSG 
Sbjct  909   HHQAYAYLLTPPPKMMTKDAERRLDALENLDNLGAGFILATHDLEIRGAGELLGNEQSGQ  968

Query  967   METIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFIPDVNTRLSF  1026
             +E+IGFSLYMELL+ AV ALK GREPSLE+LT QQ ++ELR+P+LLPDD++ DVN RLSF
Sbjct  969   IESIGFSLYMELLDAAVKALKEGREPSLEELTQQQADIELRVPALLPDDYLGDVNMRLSF  1028

Query  1027  YKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKLEGNEKGGV  1086
             YKRIA+A+++ EL+E+KVELIDRFGLLPD  + LL I  LR   + L + +++   +GG 
Sbjct  1029  YKRIAAAESKAELDELKVELIDRFGLLPDATKNLLQITELRLLVEPLNVVRIDAGTQGGF  1088

Query  1087  IEFAEKNHVNPAWLIGLLQKQPQHYRLDGPTRLKFIQDLSERKTRIEWVRQFMREL  1142
             IEF+ K  VNP   I L+QK+P  YR DGP + KF++DLS+ K R+E+V   +R +
Sbjct  1089  IEFSAKAQVNPDKFIQLIQKEPIVYRFDGPFKFKFMKDLSDNKVRLEFVVDLLRTI  1144


>P57381.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=812

 Score = 887 bits (2293),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 416/794 (52%), Positives = 578/794 (73%), Gaps = 1/794 (0%)

Query  355   FQKLPDLAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGELLARIKIAPQRIMR  414
             +QKL DL      +   + L  +L SF G ++FS+  E   + +   L R KI PQ I R
Sbjct  19    YQKLLDLFYNVNNQKKNNQLLSYLYSFSGKIIFSLTEEKSLKKILRFLMRHKIHPQYIKR  78

Query  415   L-DEASDRGRYLMIGAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRN  473
             + D   +   + MI   ++GF+D   N+  +C  DLL   +  +   + +    +    N
Sbjct  79    IIDIKKEIDYFYMIEEIKNGFIDKKNNILFLCTKDLLPILIDDKYIGNIKKNTNNINKFN  138

Query  474   LAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYA  533
             L++L +  PV+H+EHG+GRY G+TT+E   I  EYL+++YA   KLYVPVS+LHL+S Y 
Sbjct  139   LSQLILNHPVMHIEHGIGRYKGLTTIETASIQSEYLVISYAEGDKLYVPVSNLHLVSPYT  198

Query  534   GGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLF  593
             G + ENAPLHKLGGD W++ + K ++ V D AA+LL IYA+R +K GFAFK + E+Y LF
Sbjct  199   GTSIENAPLHKLGGDDWNKEKHKISKTVYDHAAQLLHIYAKRESKTGFAFKKNIEKYDLF  258

Query  594   CDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVA  653
             C+   F+TT DQ + +  VL DM +P+ MDRL+CGDVGFGKTE+AMRA+FLAV N KQVA
Sbjct  259   CNDCSFKTTSDQNEVMKFVLKDMSKPIPMDRLICGDVGFGKTEIAMRASFLAVSNKKQVA  318

Query  654   VLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKL  713
             +LVPTTLLAQQHY NF+ RF+NWPV I ++SRF++ KEQ  I      G+I+I+IGTHKL
Sbjct  319   ILVPTTLLAQQHYKNFKIRFSNWPVNINILSRFQTQKEQDLIFKHTKNGRINIIIGTHKL  378

Query  714   LQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDL  773
             L  ++++  LGLLI+DEEHRFGV HKE IK + +N+DILTLTATPIPRTLNMAM+G++DL
Sbjct  379   LFKNIEWCSLGLLIIDEEHRFGVSHKEIIKKIYSNIDILTLTATPIPRTLNMAMTGIKDL  438

Query  774   SIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELV  833
             SIIA PPA+RLA+KTF++EY  +++R+ ILREI RGGQVYY+YN V+NI   AERL+ L+
Sbjct  439   SIIAKPPAQRLAIKTFIQEYSPILIRKTILREISRGGQVYYIYNKVQNIMNIAERLSILI  498

Query  834   PEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGL  893
             PEA I IGHGQM+  +L++VMN+F++ +FNVL+CTTIIE+G+DI  ANTIIIE +DHFGL
Sbjct  499   PEASIKIGHGQMKNIDLKKVMNEFYNNKFNVLICTTIIESGVDIARANTIIIENSDHFGL  558

Query  894   AQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIR  953
             +QLHQLRGR+GRS++QAYA LL  +   +T+DA+KRLEAI+S+++ G GF+L+  DLEIR
Sbjct  559   SQLHQLRGRIGRSNNQAYALLLVNNFNKITSDAKKRLEAISSVDNFGGGFSLSNQDLEIR  618

Query  954   GAGELLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLP  1013
             G GE+LG+EQSG ++ IGFSLYM+LL+NA+D LK G+  S+E    +  E++L + SLLP
Sbjct  619   GVGEILGKEQSGHIKNIGFSLYMDLLKNAIDLLKNGKIFSVEKSLKKPLEIDLHVSSLLP  678

Query  1014  DDFIPDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKL  1073
               +I D+NTRL FYK++A+A  E ++EEIK ELID+FG LPD ++ L+ IA++R  A K+
Sbjct  679   SSYILDINTRLFFYKKLANAIHEKQIEEIKYELIDQFGKLPDFSKNLILIAKIRLIADKI  738

Query  1074  GIRKLEGNEKGGVIEFAEKNHVNPAWLIGLLQKQPQHYRLDGPTRLKFIQDLSERKTRIE  1133
             GI+ ++ N   G+IEF +   +N  +L+ + QK+P+ ++++  TR+KFI  L     R++
Sbjct  739   GIKYIKSNNNIGIIEFNDYGSINTEYLLKMFQKEPKIWKMETSTRIKFILHLKNDYLRLK  798

Query  1134  WVRQFMRELEENAI  1147
             W+   +R L +  I
Sbjct  799   WIINLLRNLFKKNI  812


>Q89AK2.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=697

 Score = 794 bits (2051),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 372/665 (56%), Positives = 495/665 (74%), Gaps = 0/665 (0%)

Query  471   IRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLIS  530
             I +L++L I QP+VH EHGVGRY G+TT+    I  E +++ YA ++KLYVP++ L+LIS
Sbjct  24    ICDLSKLKINQPIVHFEHGVGRYQGLTTVTTRNIKTECVVINYAQNSKLYVPITYLYLIS  83

Query  531   RYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQY  590
             RY G ++++ PLH+LG D W++ ++KA EK  D AA LL+IY+ R +++GF+FK    +Y
Sbjct  84    RYIGTSKKDIPLHRLGNDLWNKEKKKANEKAYDSAAILLNIYSHRISQKGFSFKKHHTKY  143

Query  591   QLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHK  650
             ++FC+ FPF  TPDQ  AIN+VLSDM +   MDRLVCGDVGFGKTEVAMRA FLAV N K
Sbjct  144   KIFCERFPFTLTPDQDSAINSVLSDMYKSTPMDRLVCGDVGFGKTEVAMRATFLAVCNQK  203

Query  651   QVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGT  710
             QVA+LVPTTLLAQQH++NF  RF  W  +IE++SRF+S  +  +I+  V  G + +LIGT
Sbjct  204   QVAILVPTTLLAQQHFNNFTLRFKYWSTKIEILSRFQSETKCNEIINNVNIGNVHVLIGT  263

Query  711   HKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGM  770
             HK+L  ++K+K+LGLLIVDEEHRFGV HKE+IK +  N+D+LTLTATPIPRTLNMA  G+
Sbjct  264   HKILLKNLKWKNLGLLIVDEEHRFGVHHKEQIKLISNNIDVLTLTATPIPRTLNMAFVGI  323

Query  771   RDLSIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLA  830
             RDLSIIATPP +RL VKTFVRE+   V+R+AILREILRGGQVYY+YN+V  I++    L 
Sbjct  324   RDLSIIATPPKQRLIVKTFVREFSYTVIRKAILREILRGGQVYYIYNNVNKIERKKIELK  383

Query  831   ELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADH  890
             +LVPEA I IGHGQ+R  +LE +MNDF+H+RFNVLVC+TIIETGIDIP  NTIIIE A++
Sbjct  384   KLVPEANIRIGHGQLRSTDLESIMNDFYHKRFNVLVCSTIIETGIDIPNVNTIIIENANN  443

Query  891   FGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDL  950
             FGLAQLHQLRGRVGRS HQAYAWLL P  K + +DA+KR++AI S+E  G+ F LA  DL
Sbjct  444   FGLAQLHQLRGRVGRSQHQAYAWLLVPSLKDIKSDAKKRIDAITSIESFGSCFELANRDL  503

Query  951   EIRGAGELLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPS  1010
             EIRG GE+LG  QSG +  IGFSLYM+LL NAV  +K G    L D+ +   ++EL + +
Sbjct  504   EIRGIGEILGNNQSGHITKIGFSLYMKLLMNAVRNIKNGYYKPLNDIINTYPKIELNVSN  563

Query  1011  LLPDDFIPDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQA  1070
             LLPD +I  VN RL FY +IA++    +LE+I++ L   FG LP+    L+ IA++R  +
Sbjct  564   LLPDSYIKKVNHRLFFYNKIATSNNFLDLEKIRLTLCKNFGNLPNSGDYLIKIAKIRLIS  623

Query  1071  QKLGIRKLEGNEKGGVIEFAEKNHVNPAWLIGLLQKQPQHYRLDGPTRLKFIQDLSERKT  1130
             +K+G++K++ + KGG IEF E + +N   L+   +K+   ++ D   RL+F ++      
Sbjct  624   KKIGVKKIKSDVKGGYIEFFEDSKINIQNLLKEFKKEKNCWKFDTSNRLRFSKNFKNNSE  683

Query  1131  RIEWV  1135
             RI+W+
Sbjct  684   RIDWI  688


>P37474.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1177

 Score = 715 bits (1845),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 406/1093 (37%), Positives = 639/1093 (58%), Gaps = 62/1093 (6%)

Query  15    EQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWE  74
             +++LL  L+G+A +   + +A     P+ LI  ++  A ++ D+++         L D  
Sbjct  26    KEQLLAGLSGSARSVFTSALANETNKPIFLITHNLYQAQKVTDDLTSL-------LEDRS  78

Query  75    TLPYDSFSPHQDIISS------------RLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSF  122
              L Y    P  ++ISS            RL  + +L   +  +++ PV  + + + P   
Sbjct  79    VLLY----PVNELISSEIAVASPELRAQRLDVINRLTNGEAPIVVAPVAAIRRMLPPVEV  134

Query  123   LHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRL  182
                  ++++ G  +  D L ++L   GY   D V   GE++ RG ++D++P+ SE P R+
Sbjct  135   WKSSQMLIQVGHDIEPDQLASRLVEVGYERSDMVSAPGEFSIRGGIIDIYPLTSENPVRI  194

Query  183   DFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEF---PTDKA-AIELFRSQWRDTFE-V  237
             + FD E+DS+R F+ D QR++E + +IN+ PA E    P +KA A+E   S    + + +
Sbjct  195   ELFDTEVDSIRSFNSDDQRSIETLTSINIGPAKELIIRPEEKARAMEKIDSGLAASLKKL  254

Query  238   KRDPE---------HIYQQVSKGTLPAGIEYWQPLFFSEPLPPLFSYFPANTLLV-----  283
             K D +         H  +++S+G     +  +   F+ +P   L  Y P NTLL+     
Sbjct  255   KADKQKEILHANISHDKERLSEGQTDQELVKYLSYFYEKP-ASLLDYTPDNTLLILDEVS  313

Query  284   NTGDLENSAERFQADTLARFENRGVDPMRPLLPPQSLWLRVDELFSELKN---WPRVQLK  340
                ++E   ++ +A+ +      G      +L    L     ++ +E K    +  + L+
Sbjct  314   RIHEMEEQLQKEEAEFITNLLEEG-----KILHDIRLSFSFQKIVAEQKRPLLYYSLFLR  368

Query  341   TEHLPTKAANANLGFQKLPDLAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGE  400
               H  +     N+  +++   +   Q       + +F +S +  VVF   ++ R + L  
Sbjct  369   HVHHTSPQNIVNVSGRQMQ--SFHGQMNVLAGEMERFKKS-NFTVVFLGANKERTQKLSS  425

Query  401   LLARIKIAPQRIMRLDEASDRGR-YLMIGAAEHGFVDTVRNLALICESDLLGERVARRRQ  459
             +LA   I    +    +A  +G+ Y+M G  + GF   +  LA+I E +L   RV  +++
Sbjct  426   VLADYDIEAA-MTDSKKALVQGQVYIMEGELQSGFELPLMKLAVITEEELFKNRV--KKK  482

Query  460   DSRRAINPDTLIRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKL  519
               ++ +     I++ +EL IG  VVH+ HG+G+Y G+ TLE  GI  +YL + Y    KL
Sbjct  483   PRKQKLTNAERIKSYSELQIGDYVVHINHGIGKYLGIETLEINGIHKDYLNIHYQGSDKL  542

Query  520   YVPVSSLHLISRYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKE  579
             YVPV  +  + +Y G   +   L+KLGG  W R ++K    V+D+A +L+ +YA+R A +
Sbjct  543   YVPVEQIDQVQKYVGSEGKEPKLYKLGGSEWKRVKKKVETSVQDIADDLIKLYAEREASK  602

Query  580   GFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAM  639
             G+AF  D E  + F  +FP++ T DQ ++I+ +  DM +   MDRL+CGDVG+GKTEVA+
Sbjct  603   GYAFSPDHEMQREFESAFPYQETEDQLRSIHEIKKDMERERPMDRLLCGDVGYGKTEVAI  662

Query  640   RAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEV  699
             RAAF A+ + KQVA+LVPTT+LAQQHY+  ++RF ++P+ I ++SRFR+ KE  + +  +
Sbjct  663   RAAFKAIGDGKQVALLVPTTILAQQHYETIKERFQDYPINIGLLSRFRTRKEANETIKGL  722

Query  700   AEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPI  759
               G +DI+IGTH+LL  DV +KDLGLLI+DEE RFGV HKE+IK ++ANVD+LTLTATPI
Sbjct  723   KNGTVDIVIGTHRLLSKDVVYKDLGLLIIDEEQRFGVTHKEKIKQIKANVDVLTLTATPI  782

Query  760   PRTLNMAMSGMRDLSIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDV  819
             PRTL+M+M G+RDLS+I TPP  R  V+T+V EY+  +VREAI RE+ RGGQVY+LYN V
Sbjct  783   PRTLHMSMLGVRDLSVIETPPENRFPVQTYVVEYNGALVREAIERELARGGQVYFLYNRV  842

Query  820   ENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPT  879
             E+I++ A+ ++ LVP+A++A  HG+M E ELE VM  F     +VLV TTIIETG+DIP 
Sbjct  843   EDIERKADEISMLVPDAKVAYAHGKMTENELETVMLSFLEGESDVLVSTTIIETGVDIPN  902

Query  880   ANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDL  939
              NT+I+  AD  GL+QL+QLRGRVGRS+  AYA+      K +T  A+KRL+AI    +L
Sbjct  903   VNTLIVFDADKMGLSQLYQLRGRVGRSNRVAYAYFTYRRDKVLTEVAEKRLQAIKEFTEL  962

Query  940   GAGFALATHDLEIRGAGELLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTS  999
             G+GF +A  DL IRGAG LLG +Q G ++++GF LY ++L+ A++  K G     E    
Sbjct  963   GSGFKIAMRDLTIRGAGNLLGAQQHGFIDSVGFDLYSQMLKEAIEERK-GDTAKTEQF--  1019

Query  1000  QQTEVELRMPSLLPDDFIPDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPART  1059
              +TE+++ + + +P+ +I D   ++  YKR  S  T  E  E++ E+IDRFG  P     
Sbjct  1020  -ETEIDVELDAYIPETYIQDGKQKIDMYKRFRSVATIEEKNELQDEMIDRFGNYPKEVEY  1078

Query  1060  LLDIARLRQQAQK  1072
             L  +A ++  A++
Sbjct  1079  LFTVAEMKVYARQ  1091


>Q5HRQ2.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1169

 Score = 704 bits (1816),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 399/1106 (36%), Positives = 638/1106 (58%), Gaps = 60/1106 (5%)

Query  15    EQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN---LA  71
             E  L+  L+ +A AT++AE   +    ++L+  ++  A ++  +I Q+ D   +    + 
Sbjct  25    ENILVTGLSPSAKATIIAEKYLKDHKQMLLVTNNLYQADKIETDILQYVDDSEVYKYPVQ  84

Query  72    DWETLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHALVMK  131
             D  T  + + SP   ++S R+ TL  L   ++G+ IVP+N   + + P      H + +K
Sbjct  85    DIMTEEFSTQSPQ--LMSERVRTLTALAQGEKGLFIVPLNGFKKWLTPVDLWKDHQMTLK  142

Query  132   KGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPM-GSELPYRLDFFDDEID  190
              GQ +  DA   +L + GYR    V   GE++ RG ++D++P+ G+  P R++ FD E+D
Sbjct  143   VGQDIDVDAFLNKLVNMGYRRESVVSHIGEFSLRGGIIDIYPLIGT--PVRIELFDTEVD  200

Query  191   SLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFEVKRDP-EHIYQQVS  249
             S+R FDV++QR+ + ++ + +  A ++      I+  +++ +  +E  R   E   +   
Sbjct  201   SIRDFDVETQRSNDNINQVEITTASDYIITDEVIQHLQNELKKAYEYTRPKIEKSVRNDL  260

Query  250   KGTLPAGIEYWQPLFFSEPL------------PPLFSYFPANTLLVNTGDLENSAERFQA  297
             K T  +  + ++  FF   L              L  YF  N ++V              
Sbjct  261   KETYES-FKLFESTFFDHQLLRRLVSFMYEKPSTLIDYFQKNAIIV-------------V  306

Query  298   DTLARFENRGV-------DPMRPLLPPQSLWLRVDELFSELKNWPRV--QLKTEHLPTKA  348
             D   R +           D M  L+   + +  + + F + +++  +  Q    +     
Sbjct  307   DEFNRIKETEETLTTEVEDFMSNLIESGNGF--IGQGFMKYESFDALLEQHAVAYFTLFT  364

Query  349   ANANLGFQKLPDLAIQAQQK--APLDALRKFLESF---DGPVVFSVESEGRREALGELLA  403
             ++  +  Q +   + +  Q+     D +R   + +   D  VV  VE+E + E +  +L 
Sbjct  365   SSMQVPLQHIIKFSCKPVQQFYGQYDIMRSEFQRYVHQDYTVVVLVETETKVERIQSMLN  424

Query  404   RIKIAPQRIMRLDEASDRGRYLMI-GAAEHGFVDTVRNLALICESDLLGERVARRRQDSR  462
              + I    +  + E  D G+ ++  G+   GF      L +I E +L   R  ++R+ ++
Sbjct  425   EMHIPT--VSNIHEDIDGGQVVVTEGSLSEGFELPYMQLVVITERELFKTRQKKQRKRTK  482

Query  463   RAINPDTLIRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVP  522
                N +  I++  +L++G  +VH+ HGVGRY G+ TLE G    +Y+ L Y    +L+VP
Sbjct  483   TISNAEK-IKSYQDLNVGDYIVHVHHGVGRYLGVETLEVGDTHRDYIKLQYKGTDQLFVP  541

Query  523   VSSLHLISRYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFA  582
             V  +  + +Y    +++  L+KLGG  W + + K  + V D+A EL+D+Y +R    G+ 
Sbjct  542   VDQMDQVQKYVASEDKSPRLNKLGGTEWKKTKAKVQQSVEDIADELIDLYKEREMSVGYQ  601

Query  583   FKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAA  642
             +  D  +   F   FP+E TPDQ+++I+ +  DM +   MDRL+CGDVG+GKTEVA+RAA
Sbjct  602   YGQDTAEQSAFEHDFPYELTPDQSKSIDEIKGDMERARPMDRLLCGDVGYGKTEVAVRAA  661

Query  643   FLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEG  702
             F AV + KQVA LVPTT+LAQQHY+   +R  ++PV I+++SRFR+AKE  +    +  G
Sbjct  662   FKAVMDGKQVAFLVPTTILAQQHYETLLERMQDFPVEIQLVSRFRTAKEIRETKEGLKSG  721

Query  703   KIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRT  762
              +DI++GTHKLL  D+++KDLGLLIVDEE RFGVRHKERIK ++ NVD+LTLTATPIPRT
Sbjct  722   YVDIVVGTHKLLGKDIQYKDLGLLIVDEEQRFGVRHKERIKTLKKNVDVLTLTATPIPRT  781

Query  763   LNMAMSGMRDLSIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENI  822
             L+M+M G+RDLS+I TPP  R  V+T+V E ++  ++EA+ RE+ R GQV+YLYN V++I
Sbjct  782   LHMSMLGVRDLSVIETPPENRFPVQTYVLEQNTNFIKEALERELSRDGQVFYLYNKVQSI  841

Query  823   QKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANT  882
              +  E+L  L+P+A IA+ HGQM ER+LE  M  F +  +++LV TTIIETG+D+P ANT
Sbjct  842   YEKREQLQRLMPDANIAVAHGQMTERDLEETMLSFINHEYDILVTTTIIETGVDVPNANT  901

Query  883   IIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAG  942
             +IIE AD FGL+QL+QLRGRVGRS    YA+ L P  K +   A++RL+AI    +LG+G
Sbjct  902   LIIEEADRFGLSQLYQLRGRVGRSSRIGYAYFLHPANKVLNETAEERLQAIKEFTELGSG  961

Query  943   FALATHDLEIRGAGELLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQT  1002
             F +A  DL IRGAG LLG++Q G ++++GF LY ++LE AV+  +  +E S +   +   
Sbjct  962   FKIAMRDLNIRGAGNLLGKQQHGFIDSVGFDLYSQMLEEAVNEKRGIKEESPD---APDI  1018

Query  1003  EVELRMPSLLPDDFIPDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLD  1062
             EVEL + + LP ++I     ++  YK++   +TE +L ++K ELIDRF   P     LLD
Sbjct  1019  EVELHLDAYLPAEYIQSEQAKIEIYKKLRKVETEEQLFDVKDELIDRFNDYPIEVERLLD  1078

Query  1063  IARLRQQAQKLGIRKLEGNEKGGVIE  1088
             I  ++  A   G+  ++  +KG  I+
Sbjct  1079  IVEIKVHALHAGVELIK--DKGKSIQ  1102


>Q8CMT1.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1169

 Score = 702 bits (1813),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 398/1106 (36%), Positives = 637/1106 (58%), Gaps = 60/1106 (5%)

Query  15    EQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN---LA  71
             E  L+  L+ +A AT++AE   +    ++L+  ++  A ++  +I Q+ D   +    + 
Sbjct  25    ENILVTGLSPSAKATIIAEKYLKDHKQMLLVTNNLYQADKIETDILQYVDDSEVYKYPVQ  84

Query  72    DWETLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHALVMK  131
             D  T  + + SP   ++S R+ TL  L   ++G+ IVP+N   + + P      H + +K
Sbjct  85    DIMTEEFSTQSPQ--LMSERVRTLTALAQGEKGLFIVPLNGFKKWLTPVDLWKDHQMTLK  142

Query  132   KGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPM-GSELPYRLDFFDDEID  190
              GQ +  DA   +L + GYR    V   GE++ RG ++D++P+ G+  P R++ FD E+D
Sbjct  143   VGQDIDVDAFLNKLVNMGYRRESVVSHIGEFSLRGGIIDIYPLIGT--PVRIELFDTEVD  200

Query  191   SLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFEVKRDP-EHIYQQVS  249
             S+R FDV++QR+ + ++ + +  A ++      I+  +++ +  +E  R   E   +   
Sbjct  201   SIRDFDVETQRSNDNINQVEITTASDYIITDEVIQHLQNELKKAYEYTRPKIEKSVRNDL  260

Query  250   KGTLPAGIEYWQPLFFSEPL------------PPLFSYFPANTLLVNTGDLENSAERFQA  297
             K T  +  + ++  FF   L              L  YF  N ++V              
Sbjct  261   KETYES-FKLFESTFFDHQLLRRLVSFMYEKPSTLIDYFQKNAIIV-------------V  306

Query  298   DTLARFENRGV-------DPMRPLLPPQSLWLRVDELFSELKNWPRV--QLKTEHLPTKA  348
             D   R +           D M  L+   + +  + + F + +++  +  Q    +     
Sbjct  307   DEFNRIKETEETLTTEVEDFMSNLIESGNGF--IGQGFMKYESFDALLEQHAVAYFTLFT  364

Query  349   ANANLGFQKLPDLAIQAQQK--APLDALRKFLESF---DGPVVFSVESEGRREALGELLA  403
             ++  +  Q +   + +  Q+     D +R   + +   D  VV  VE+E + E +  +L 
Sbjct  365   SSMQVPLQHIIKFSCKPVQQFYGQYDIMRSEFQRYVHQDYTVVVLVETETKVERIQSMLN  424

Query  404   RIKIAPQRIMRLDEASDRGRYLMI-GAAEHGFVDTVRNLALICESDLLGERVARRRQDSR  462
              + I    +  + E  D G+ ++  G+   GF      L +I E +L   R  ++R+ ++
Sbjct  425   EMHIPT--VSNIHEDIDGGQVVVTEGSLSEGFELPYMQLVVITERELFKTRQKKQRKRTK  482

Query  463   RAINPDTLIRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVP  522
                N +  I++  +L++G  +VH+ HGVGRY G+ TLE G    +Y+ L Y    +L+VP
Sbjct  483   TISNAEK-IKSYQDLNVGDYIVHVHHGVGRYLGVETLEVGDTHRDYIKLQYKGTDQLFVP  541

Query  523   VSSLHLISRYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFA  582
             V  +  + +Y    +++  L+KLGG  W + + K  + V D+A EL+D+Y +R    G+ 
Sbjct  542   VDQMDQVQKYVASEDKSPRLNKLGGTEWKKTKAKVQQSVEDIADELIDLYKEREMSVGYQ  601

Query  583   FKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAA  642
             +  D  +   F   FP+E TPDQ+++I+ +  DM +   MDRL+CGDVG+GKTEVA+RAA
Sbjct  602   YGQDTAEQSAFEHDFPYELTPDQSKSIDEIKGDMERARPMDRLLCGDVGYGKTEVAVRAA  661

Query  643   FLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEG  702
             F AV + KQVA LVPTT+LAQQHY+   +R  ++PV I+++SRFR+AKE  +    +  G
Sbjct  662   FKAVMDGKQVAFLVPTTILAQQHYETLLERMQDFPVEIQLVSRFRTAKEIRETKEGLKSG  721

Query  703   KIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRT  762
              +DI++GTHKLL  D+++KDLGLLIVDEE RFGVRHKERIK ++ NVD+LTLTATPIPRT
Sbjct  722   YVDIVVGTHKLLGKDIQYKDLGLLIVDEEQRFGVRHKERIKTLKKNVDVLTLTATPIPRT  781

Query  763   LNMAMSGMRDLSIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENI  822
             L+M+M G+RDLS+I TPP  R  V+T+V E ++  ++EA+ RE+ R GQV+YLYN V++I
Sbjct  782   LHMSMLGVRDLSVIETPPENRFPVQTYVLEQNTNFIKEALERELSRDGQVFYLYNKVQSI  841

Query  823   QKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANT  882
              +  E+L  L+P+A IA+ HGQM ER+LE  M  F +  +++LV TTIIETG+D+P ANT
Sbjct  842   YEKREQLQRLMPDANIAVAHGQMTERDLEETMLSFINHEYDILVTTTIIETGVDVPNANT  901

Query  883   IIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAG  942
             +IIE AD FGL+QL+QLRGRVGRS    YA+ L P  K +   A++RL+ I    +LG+G
Sbjct  902   LIIEEADRFGLSQLYQLRGRVGRSSRIGYAYFLHPANKVLNETAEERLQTIKEFTELGSG  961

Query  943   FALATHDLEIRGAGELLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQT  1002
             F +A  DL IRGAG LLG++Q G ++++GF LY ++LE AV+  +  +E S +   +   
Sbjct  962   FKIAMRDLNIRGAGNLLGKQQHGFIDSVGFDLYSQMLEEAVNEKRGIKEESPD---APDI  1018

Query  1003  EVELRMPSLLPDDFIPDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLD  1062
             EVEL + + LP ++I     ++  YK++   +TE +L ++K ELIDRF   P     LLD
Sbjct  1019  EVELHLDAYLPAEYIQSEQAKIEIYKKLRKVETEEQLFDVKDELIDRFNDYPIEVERLLD  1078

Query  1063  IARLRQQAQKLGIRKLEGNEKGGVIE  1088
             I  ++  A   G+  ++  +KG  I+
Sbjct  1079  IVEIKVHALHAGVELIK--DKGKSIQ  1102


>Q4L3G0.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1169

 Score = 698 bits (1802),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 403/1101 (37%), Positives = 641/1101 (58%), Gaps = 52/1101 (5%)

Query  18    LLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN---LADWE  74
             L+  L+ +A AT++AE   +    ++LI  ++  A +L  +I Q+ D   +    + D  
Sbjct  28    LVTGLSPSAKATIIAEKYLKDQKQMLLITNNLYQADKLETDILQYIDHSEVYKYPVQDIM  87

Query  75    TLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHALVMKKGQ  134
             T  + + SP   ++S R+ TL  L   ++G+ IVP+N L + + P      H + ++ G+
Sbjct  88    TEEFSTQSPQ--LMSERVRTLTALAHNKKGLFIVPLNGLKKWLTPFELWKDHQITLRVGE  145

Query  135   RLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRV  194
              +  D    +L + GYR    V   GE++ RG ++D++P+  + P R++ FD E+DS+R 
Sbjct  146   DIDVDEFLNKLVNMGYRRESVVSHIGEFSLRGGIIDIYPLIGQ-PVRIELFDTEVDSIRD  204

Query  195   FDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFE---------VKRDPEHIY  245
             FDV++QR+ + ++ +++  A ++      I+  +S+ +  +E         V+ D +  Y
Sbjct  205   FDVETQRSNDNIEEVSITTASDYVITDDVIQHLQSELKTAYEATRPKIDKSVRNDLKETY  264

Query  246   QQVSKGTLPAGIEYWQPLFFSEPL------------PPLFSYFPANTLLV-NTGDLENSA  292
             +           + ++  FF   L              L  YF  + ++V +  +     
Sbjct  265   E---------SFKLFETTFFDHQLLRRLVAFMYEQPSTLIDYFAKDAIIVADEYNRIKET  315

Query  293   ERFQADTLARFENRGVDPMRPLLPPQSLWLRVDELFSELKNWP--RVQLKTEHLPTKAAN  350
             E+     +  F    ++     +  QS +++ D   S LK++P     L T  +P +  +
Sbjct  316   EKTLTTEVDDFIQNLIESGNGFIG-QS-FMQYDGFESLLKDYPVTYFTLFTSTMPVQLQH  373

Query  351   ANLGFQKLPDLAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGELLARIKIAPQ  410
               + F   P      Q        ++++ + D  +V  VE+E + E +  +L  + I   
Sbjct  374   I-IKFSCKPVQQFYGQYDIMRSEFQRYVHN-DYHIVVLVETETKVERIQSMLNEMHIPTV  431

Query  411   RIMRLDEASDRGRYLMI-GAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPDT  469
               ++ D  S  G+ ++  G+   GF      L +I E +L   +  ++R+ ++   N + 
Sbjct  432   TNVQNDIKS--GQVVVTEGSLSEGFELPYMQLVVITERELFKTKQKKQRKRTKTLSNAEK  489

Query  470   LIRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLI  529
              I++  +L++G  VVH+ HGVGRY G+ TLE G +  +Y+ L Y    +L+VPV  +  +
Sbjct  490   -IKSYQDLNVGDYVVHVHHGVGRYLGVETLEVGDVHRDYIKLQYKGTDQLFVPVDQMDQV  548

Query  530   SRYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQ  589
              +Y    +++  L+KLGG  W + + K  + V D+A EL+ +Y +R    G+ +  D  +
Sbjct  549   QKYVASEDKSPKLNKLGGSEWKKTKAKVQQSVEDIADELIALYKEREMSVGYQYGEDTAE  608

Query  590   YQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNH  649
                F   FP+E TPDQA++I+ +  DM +   MDRL+CGDVG+GKTEVA+RAAF AV   
Sbjct  609   QSAFEMDFPYELTPDQAKSIDEIKGDMERERPMDRLLCGDVGYGKTEVAVRAAFKAVMEG  668

Query  650   KQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIG  709
             KQVA LVPTT+LAQQHY+   +R  ++PV+IE+ISRFRS KE  +    +  G +DI++G
Sbjct  669   KQVAFLVPTTILAQQHYETLIERMQDFPVQIELISRFRSTKEVKETKEGLKSGYVDIVVG  728

Query  710   THKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSG  769
             THKLL  D+ +KDLGLLIVDEE RFGVRHKERIK M+ NVD+LTLTATPIPRTL+M+M G
Sbjct  729   THKLLGKDIHYKDLGLLIVDEEQRFGVRHKERIKTMKTNVDVLTLTATPIPRTLHMSMLG  788

Query  770   MRDLSIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERL  829
             +RDLS+I TPP  R  V+T+V E +S  ++EA+ RE+ R GQV+YLYN V++I +  E+L
Sbjct  789   VRDLSVIETPPENRFPVQTYVLEQNSNFIKEALERELSRDGQVFYLYNRVQSIYEKREQL  848

Query  830   AELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERAD  889
               L+P+A IA+ HGQM ER+LE  M  F +  F++LV TTIIETG+D+P ANT+IIE AD
Sbjct  849   QMLMPDANIAVAHGQMTERDLEETMLSFINGEFDILVTTTIIETGVDVPNANTLIIEEAD  908

Query  890   HFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHD  949
              FGL+QL+QLRGRVGRS    YA+ L    K +T  A++RL+AI    +LG+GF +A  D
Sbjct  909   RFGLSQLYQLRGRVGRSSRIGYAYFLHSANKVLTETAEERLQAIKEFTELGSGFKIAMRD  968

Query  950   LEIRGAGELLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMP  1009
             L IRGAG LLG++Q G ++++GF LY ++LE AV+  +  +E   E+  + + E+EL + 
Sbjct  969   LNIRGAGNLLGKQQHGFIDSVGFDLYSQMLEEAVNEKRGIKE---EEPDAPEVEMELNLD  1025

Query  1010  SLLPDDFIPDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQ  1069
             + LP ++I +   ++  YK++   +TE +L +IK ELIDRF   P     LL++  ++  
Sbjct  1026  AYLPAEYIQNEQAKIEIYKKLRKVETEEQLFDIKDELIDRFNDYPVEVERLLEMVEIKIH  1085

Query  1070  AQKLGIRKLEGNEKGGVIEFA  1090
             A   G+  ++  +KG  IE +
Sbjct  1086  ALHAGVTLIK--DKGKQIEVS  1104


>Q6GJG8.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1168

 Score = 691 bits (1782),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 400/1091 (37%), Positives = 633/1091 (58%), Gaps = 36/1091 (3%)

Query  18    LLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN---LADWE  74
             L+  L+ +A  T++AE   +    ++LI  ++  A +L  ++ QF D   +    + D  
Sbjct  27    LVTGLSPSAKVTMIAEKYAQSNQQLLLITNNLYQADKLETDLLQFVDVEELYKYPVQDIM  86

Query  75    TLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHALVMKKGQ  134
             T  + + SP   ++S R+ TL  L   ++G+ IVP+N L + + P      H + ++ G+
Sbjct  87    TEEFSTQSPQ--LMSERIRTLTALAQGKKGLFIVPLNGLKKWLTPVEMWQNHQMTLRVGE  144

Query  135   RLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRV  194
              +  D    +L + GY+    V   GE++ RG ++D+FP+  E P R++ FD EIDS+R 
Sbjct  145   DIDVDQFLNKLVNMGYKRESVVSHIGEFSLRGGIIDIFPLIGE-PIRIELFDTEIDSIRD  203

Query  195   FDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFE---------VKRDPEHIY  245
             FDV++QR+ + ++ +++  A ++   +  I   + + +  +E         V+ D +  Y
Sbjct  204   FDVETQRSKDNIEEVDITTASDYIITEEVISHLKEELKTAYENTRPKIDKSVRNDLKETY  263

Query  246   QQVS---KGTLPAGIEYWQPLFFSEPLPPLFSYFPANTLLV--NTGDLENSAERFQADTL  300
             +             I      F  E    +  YF  + ++       ++ + E    ++ 
Sbjct  264   ESFKLFESTYFDHQILRRLVAFMYETPSTIIDYFQKDAIIAVDEFNRIKETEESLTVESD  323

Query  301   ARFENRGVDPMRPLLPPQSLWLRVDELFSELKNWP--RVQLKTEHLPTKAANANLGFQKL  358
             +   N  V         QS +++ D+  + ++ +P     L    +P K  N  + F   
Sbjct  324   SFISN--VIESGNGFIGQS-FIKYDDFETLIEGYPVTYFSLFATTMPIKL-NHIIKFSCK  379

Query  359   PDLAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEA  418
             P      Q        ++++   +  +V  VE+E + E +  +L+ + I    I +L  +
Sbjct  380   PVQQFYGQYDIMRSEFQRYVNQ-NYHIVVLVETETKVERMQAMLSEMHIPS--ITKLHRS  436

Query  419   SDRGRYLMI-GAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRNLAEL  477
                G+ ++I G+   GF      L +I E +L   +  ++R+   +AI+    I++  +L
Sbjct  437   MSSGQAVIIEGSLSEGFELPDMGLVVITERELFKSKQKKQRK-RTKAISNAEKIKSYQDL  495

Query  478   HIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAE  537
             ++G  +VH+ HGVGRY G+ TLE G I  +Y+ L Y    +L+VPV  +  + +Y    +
Sbjct  496   NVGDYIVHVHHGVGRYLGVETLEVGQIHRDYIKLQYKGTDQLFVPVDQMDQVQKYVASED  555

Query  538   ENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSF  597
             +   L+KLGG  W + + K  + V D+A EL+D+Y +R   EG+ +  D  +   F   F
Sbjct  556   KTPKLNKLGGSEWKKTKAKVQQSVEDIAEELIDLYKEREMAEGYQYGEDTAEQTTFELDF  615

Query  598   PFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVP  657
             P+E TPDQA++I+ +  DM +   MDRL+CGDVG+GKTEVA+RAAF AV   KQVA LVP
Sbjct  616   PYELTPDQAKSIDEIKDDMQKSRPMDRLLCGDVGYGKTEVAVRAAFKAVMEGKQVAFLVP  675

Query  658   TTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSD  717
             TT+LAQQHY+   +R  ++PV I+++SRFR+ KE  Q    +  G +DI++GTHKLL  D
Sbjct  676   TTILAQQHYETLIERMQDFPVEIQLMSRFRTPKEIKQTKEGLKTGFVDIVVGTHKLLSKD  735

Query  718   VKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIA  777
             +++KDLGLLIVDEE RFGVRHKERIK ++ NVD+LTLTATPIPRTL+M+M G+RDLS+I 
Sbjct  736   IQYKDLGLLIVDEEQRFGVRHKERIKTLKHNVDVLTLTATPIPRTLHMSMLGVRDLSVIE  795

Query  778   TPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEAR  837
             TPP  R  V+T+V E +   ++EA+ RE+ R GQV+YLYN V++I +  E+L  L+P+A 
Sbjct  796   TPPENRFPVQTYVLEQNMSFIKEALERELSRDGQVFYLYNKVQSIYEKREQLQMLMPDAN  855

Query  838   IAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLH  897
             IA+ HGQM ER+LE  M  F +  +++LV TTIIETG+D+P ANT+IIE AD FGL+QL+
Sbjct  856   IAVAHGQMTERDLEETMLSFINNEYDILVTTTIIETGVDVPNANTLIIEDADRFGLSQLY  915

Query  898   QLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGE  957
             QLRGRVGRS    YA+ L P  K +T  A+ RL+AI    +LG+GF +A  DL IRGAG 
Sbjct  916   QLRGRVGRSSRIGYAYFLHPANKVLTETAEDRLQAIKEFTELGSGFKIAMRDLNIRGAGN  975

Query  958   LLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFI  1017
             LLG++Q G ++T+GF LY ++LE AV+  +  +EP        + EV+L + + LP ++I
Sbjct  976   LLGKQQHGFIDTVGFDLYSQMLEEAVNEKRGIKEPE---SEVPEVEVDLNLDAYLPTEYI  1032

Query  1018  PDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRK  1077
              +   ++  YK++   +T +++ +IK ELIDRF   P     LLDI  ++  A   GI  
Sbjct  1033  ANEQAKIEIYKKLRKTETFDQIIDIKDELIDRFNDYPVEVARLLDIVEIKVHALHSGITL  1092

Query  1078  LEGNEKGGVIE  1088
             ++  +KG +I+
Sbjct  1093  IK--DKGKIID  1101


>Q5HIH2.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1168

 Score = 690 bits (1781),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 403/1107 (36%), Positives = 637/1107 (58%), Gaps = 68/1107 (6%)

Query  18    LLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN---LADWE  74
             L+  L+ +A  T++AE   +    ++LI  ++  A +L  ++ QF D   +    + D  
Sbjct  27    LVTGLSPSAKVTMIAEKYAQSNQQLLLITNNLYQADKLETDLLQFIDAEELYKYPVQDIM  86

Query  75    TLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHALVMKKGQ  134
             T  + + SP   ++S R+ TL  L   ++G+ IVP+N L + + P      H + ++ G+
Sbjct  87    TEEFSTQSPQ--LMSERIRTLTALAQGKKGLFIVPLNGLKKWLTPVEMWQNHQMTLRVGE  144

Query  135   RLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRV  194
              +  D    +L + GY+    V   GE++ RG ++D+FP+  E P R++ FD EIDS+R 
Sbjct  145   DIDVDQFLNKLVNMGYKRESVVSHIGEFSLRGGIIDIFPLIGE-PIRIELFDTEIDSIRD  203

Query  195   FDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFE---------VKRDPEHIY  245
             FDV++QR+ + V+ +++  A ++   +  I   + + +  +E         V+ D +  Y
Sbjct  204   FDVETQRSKDNVEEVDITTASDYIITEEVISHLKEELKTAYENTRPKIDKSVRNDLKETY  263

Query  246   QQVSKGTLPAGIEYWQPLFFSEPLP---PLFSYFPANTLLVNTGDLENSAERFQADTLAR  302
             +           + ++  +F   +      F Y   +T++          E FQ D +  
Sbjct  264   E---------SFKLFESTYFDHQILRRLVAFMYETPSTII----------EYFQKDAIIA  304

Query  303   FE--NRGVDPMRPL-LPPQSL---------------WLRVDELFSELKNWP--RVQLKTE  342
              +  NR  +    L + P S                +++ D+  + ++ +P     L   
Sbjct  305   VDEFNRIKETEESLTVEPDSFISNIIESGNGFIGQSFIKYDDFETLIEGYPVTYFSLFAT  364

Query  343   HLPTKAANANLGFQKLPDLAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGELL  402
              +P K  N  + F   P      Q        ++++   +  +V  VE+E + E +  +L
Sbjct  365   TMPIKL-NHIIKFSCKPVQQFYGQYDIMRSEFQRYVNQ-NYHIVVLVETETKVERMQAML  422

Query  403   ARIKIAPQRIMRLDEASDRGRYLMI-GAAEHGFVDTVRNLALICESDLLGERVARRRQDS  461
             + + I    I +L  +   G+ ++I G+   GF      L +I E +L   +  ++R+  
Sbjct  423   SEMHIPS--ITKLHRSMSSGQAVIIEGSLSEGFELPDMGLVVITERELFKSKQKKQRK-R  479

Query  462   RRAINPDTLIRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYV  521
              +AI+    I++  +L++G  +VH+ HGVGRY G+ TLE G    +Y+ L Y    +L+V
Sbjct  480   TKAISNAEKIKSYQDLNVGDYIVHVHHGVGRYLGVETLEVGQTHRDYIKLQYKGTDQLFV  539

Query  522   PVSSLHLISRYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGF  581
             PV  +  + +Y    ++   L+KLGG  W + + K  + V D+A EL+D+Y +R   EG+
Sbjct  540   PVDQMDQVQKYVASEDKTPKLNKLGGSEWKKTKAKVQQSVEDIAEELIDLYKEREMAEGY  599

Query  582   AFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRA  641
              +  D  +   F   FP+E TPDQA++I+ +  DM +   MDRL+CGDVG+GKTEVA+RA
Sbjct  600   QYGEDTAEQTTFELDFPYELTPDQAKSIDEIKDDMQKSRPMDRLLCGDVGYGKTEVAVRA  659

Query  642   AFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAE  701
             AF AV   KQVA LVPTT+LAQQHY+   +R  ++PV I+++SRFR+ KE  Q    +  
Sbjct  660   AFKAVMEGKQVAFLVPTTILAQQHYETLIERMQDFPVEIQLMSRFRTPKEIKQTKEGLKT  719

Query  702   GKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPR  761
             G +DI++GTHKLL  D+++KDLGLLIVDEE RFGVRHKERIK ++ NVD+LTLTATPIPR
Sbjct  720   GFVDIVVGTHKLLSKDIQYKDLGLLIVDEEQRFGVRHKERIKTLKHNVDVLTLTATPIPR  779

Query  762   TLNMAMSGMRDLSIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVEN  821
             TL+M+M G+RDLS+I TPP  R  V+T+V E +   ++EA+ RE+ R GQV+YLYN V++
Sbjct  780   TLHMSMLGVRDLSVIETPPENRFPVQTYVLEQNMSFIKEALERELSRDGQVFYLYNKVQS  839

Query  822   IQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTAN  881
             I +  E+L  L+P+A IA+ HGQM ER+LE  M  F +  +++LV TTIIETG+D+P AN
Sbjct  840   IYEKREQLQMLMPDANIAVAHGQMTERDLEETMLSFINNEYDILVTTTIIETGVDVPNAN  899

Query  882   TIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGA  941
             T+IIE AD FGL+QL+QLRGRVGRS    YA+ L P  K +T  A+ RL+AI    +LG+
Sbjct  900   TLIIEDADRFGLSQLYQLRGRVGRSSRIGYAYFLHPANKVLTETAEDRLQAIKEFTELGS  959

Query  942   GFALATHDLEIRGAGELLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQ  1001
             GF +A  DL IRGAG LLG++Q G ++T+GF LY ++LE AV+  +  +EP        +
Sbjct  960   GFKIAMRDLNIRGAGNLLGKQQHGFIDTVGFDLYSQMLEEAVNEKRGIKEPE---SEVPE  1016

Query  1002  TEVELRMPSLLPDDFIPDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLL  1061
              EV+L + + LP ++I +   ++  YK++   +T +++ +IK ELIDRF   P     LL
Sbjct  1017  VEVDLNLDAYLPTEYIANEQAKIEIYKKLRKTETFDQIIDIKDELIDRFNDYPVEVARLL  1076

Query  1062  DIARLRQQAQKLGIRKLEGNEKGGVIE  1088
             DI  ++  A   GI  ++  +KG +I+
Sbjct  1077  DIVEIKVHALHSGITLIK--DKGKIID  1101


>Q2G0R8.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
 Q2FJD8.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1168

 Score = 689 bits (1778),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 399/1091 (37%), Positives = 634/1091 (58%), Gaps = 36/1091 (3%)

Query  18    LLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN---LADWE  74
             L+  L+ +A  T++AE   +    ++LI  ++  A +L  ++ QF D   +    + D  
Sbjct  27    LVTGLSPSAKVTMIAEKYAQSNQQLLLITNNLYQADKLETDLLQFIDAEELYKYPVQDIM  86

Query  75    TLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHALVMKKGQ  134
             T  + + SP   ++S R+ TL  L   ++G+ IVP+N L + + P      H + ++ G+
Sbjct  87    TEEFSTQSPQ--LMSERIRTLTALAQGKKGLFIVPLNGLKKWLTPVEMWQNHQMTLRVGE  144

Query  135   RLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRV  194
              +  D    +L + GY+    V   GE++ RG ++D+FP+  E P R++ FD EIDS+R 
Sbjct  145   DIDVDQFLNKLVNMGYKRESVVSHIGEFSLRGGIIDIFPLIGE-PIRIELFDTEIDSIRD  203

Query  195   FDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFE---------VKRDPEHIY  245
             FDV++QR+ + V+ +++  A ++   +  I   + + +  +E         V+ D +  Y
Sbjct  204   FDVETQRSKDNVEEVDITTASDYIITEEVISHLKEELKTAYENTRPKIDKSVRNDLKETY  263

Query  246   QQVS---KGTLPAGIEYWQPLFFSEPLPPLFSYFPANTLLV--NTGDLENSAERFQADTL  300
             +             I      F  E    +  YF  + ++       ++ + E    ++ 
Sbjct  264   ESFKLFESTYFDHQILRRLVAFMYETPSTIIEYFQKDAIIAVDEFNRIKETEESLTVES-  322

Query  301   ARFENRGVDPMRPLLPPQSLWLRVDELFSELKNWP--RVQLKTEHLPTKAANANLGFQKL  358
               F +  ++     +  QS +++ D+  + ++ +P     L    +P K  N  + F   
Sbjct  323   DSFISNIIESGNGFIG-QS-FIKYDDFETLIEGYPVTYFSLFATTMPIKL-NHIIKFSCK  379

Query  359   PDLAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEA  418
             P      Q        ++++   +  +V  VE+E + E +  +L+ + I    I +L  +
Sbjct  380   PVQQFYGQYDIMRSEFQRYVNQ-NYHIVVLVETETKVERMQAMLSEMHIPS--ITKLHRS  436

Query  419   SDRGRYLMI-GAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRNLAEL  477
                G+ ++I G+   GF      L +I E +L   +  ++R+   +AI+    I++  +L
Sbjct  437   MSSGQAVIIEGSLSEGFELPDMGLVVITERELFKSKQKKQRK-RTKAISNAEKIKSYQDL  495

Query  478   HIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAE  537
             ++G  +VH+ HGVGRY G+ TLE G    +Y+ L Y    +L+VPV  +  + +Y    +
Sbjct  496   NVGDYIVHVHHGVGRYLGVETLEVGQTHRDYIKLQYKGTDQLFVPVDQMDQVQKYVASED  555

Query  538   ENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSF  597
             +   L+KLGG  W + + K  + V D+A EL+D+Y +R   EG+ +  D  +   F   F
Sbjct  556   KTPKLNKLGGSEWKKTKAKVQQSVEDIAEELIDLYKEREMAEGYQYGEDTAEQTTFELDF  615

Query  598   PFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVP  657
             P+E TPDQA++I+ +  DM +   MDRL+CGDVG+GKTEVA+RAAF AV   KQVA LVP
Sbjct  616   PYELTPDQAKSIDEIKDDMQKSRPMDRLLCGDVGYGKTEVAVRAAFKAVMEGKQVAFLVP  675

Query  658   TTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSD  717
             TT+LAQQHY+   +R  ++PV I+++SRFR+ KE  Q    +  G +DI++GTHKLL  D
Sbjct  676   TTILAQQHYETLIERMQDFPVEIQLMSRFRTPKEIKQTKEGLKTGFVDIVVGTHKLLSKD  735

Query  718   VKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIA  777
             +++KDLGLLIVDEE RFGVRHKERIK ++ NVD+LTLTATPIPRTL+M+M G+RDLS+I 
Sbjct  736   IQYKDLGLLIVDEEQRFGVRHKERIKTLKHNVDVLTLTATPIPRTLHMSMLGVRDLSVIE  795

Query  778   TPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEAR  837
             TPP  R  V+T+V E +   ++EA+ RE+ R GQV+YLYN V++I +  E+L  L+P+A 
Sbjct  796   TPPENRFPVQTYVLEQNMSFIKEALERELSRDGQVFYLYNKVQSIYEKREQLQMLMPDAN  855

Query  838   IAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLH  897
             IA+ HGQM ER+LE  M  F +  +++LV TTIIETG+D+P ANT+IIE AD FGL+QL+
Sbjct  856   IAVAHGQMTERDLEETMLSFINNEYDILVTTTIIETGVDVPNANTLIIEDADRFGLSQLY  915

Query  898   QLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGE  957
             QLRGRVGRS    YA+ L P  K +T  A+ RL+AI    +LG+GF +A  DL IRGAG 
Sbjct  916   QLRGRVGRSSRIGYAYFLHPANKVLTETAEDRLQAIKEFTELGSGFKIAMRDLNIRGAGN  975

Query  958   LLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFI  1017
             LLG++Q G ++T+GF LY ++LE AV+  +  +EP        + EV+L + + LP ++I
Sbjct  976   LLGKQQHGFIDTVGFDLYSQMLEEAVNEKRGIKEPE---SEVPEVEVDLNLDAYLPTEYI  1032

Query  1018  PDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRK  1077
              +   ++  YK++   +T +++ +IK ELIDRF   P     LLDI  ++  A   GI  
Sbjct  1033  ANEQAKIEIYKKLRKTETFDQIIDIKDELIDRFNDYPVEVARLLDIVEIKVHALHSGITL  1092

Query  1078  LEGNEKGGVIE  1088
             ++  +KG +I+
Sbjct  1093  IK--DKGKIID  1101


>Q7A7B2.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
 Q99WA0.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1168

 Score = 689 bits (1777),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 398/1091 (36%), Positives = 634/1091 (58%), Gaps = 36/1091 (3%)

Query  18    LLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN---LADWE  74
             L+  L+ +A  T++AE   +    ++LI  ++  A +L  ++ QF D   +    + D  
Sbjct  27    LVTGLSPSAKVTMIAEKYAQSNQQLLLITNNLYQADKLETDLLQFIDAEELYKYPVQDIM  86

Query  75    TLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHALVMKKGQ  134
             T  + + SP   ++S R+ TL  L   ++G+ IVP+N L + + P      H + ++ G+
Sbjct  87    TEEFSTQSPQ--LMSERIRTLTALAQGKKGLFIVPLNGLKKWLTPVEMWQNHQMTLRVGE  144

Query  135   RLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRV  194
              +  D    +L + GY+    V   GE++ RG ++D+FP+  E P R++ FD EIDS+R 
Sbjct  145   DIDVDQFLNKLVNMGYKRESVVSHIGEFSLRGGIIDIFPLIGE-PIRIELFDTEIDSIRD  203

Query  195   FDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFE---------VKRDPEHIY  245
             FDV++QR+ + ++ +++  A ++   +  I   + + +  +E         V+ D +  Y
Sbjct  204   FDVETQRSKDNIEEVDITTASDYIITEEVIRHLKEELKTAYENTRPKIDKSVRNDLKETY  263

Query  246   QQVS---KGTLPAGIEYWQPLFFSEPLPPLFSYFPANTLLV--NTGDLENSAERFQADTL  300
             +             I      F  E    +  YF  + ++       ++ + E    ++ 
Sbjct  264   ESFKLFESTYFDHQILRRLVAFMYETPSTIIEYFQKDAIIAVDEFNRIKETEESLTVES-  322

Query  301   ARFENRGVDPMRPLLPPQSLWLRVDELFSELKNWP--RVQLKTEHLPTKAANANLGFQKL  358
               F +  ++     +  QS +++ D+  + ++ +P     L    +P K  N  + F   
Sbjct  323   DSFISNIIESGNGFIG-QS-FIKYDDFETLIEGYPVTYFSLFATTMPIKL-NHIIKFSCK  379

Query  359   PDLAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEA  418
             P      Q        ++++   +  +V  VE+E + E +  +L+ + I    I +L  +
Sbjct  380   PVQQFYGQYDIMRSEFQRYVNQ-NYHIVVLVETETKVERMQAMLSEMHIPS--ITKLHRS  436

Query  419   SDRGRYLMI-GAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRNLAEL  477
                G+ ++I G+   GF      L +I E +L   +  ++R+   +AI+    I++  +L
Sbjct  437   MSSGQAVIIEGSLSEGFELPDMGLVVITERELFKSKQKKQRK-RTKAISNAEKIKSYQDL  495

Query  478   HIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAE  537
             ++G  +VH+ HGVGRY G+ TLE G    +Y+ L Y    +L+VPV  +  + +Y    +
Sbjct  496   NVGDYIVHVHHGVGRYLGVETLEVGQTHRDYIKLQYKGTDQLFVPVDQMDQVQKYVASED  555

Query  538   ENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSF  597
             +   L+KLGG  W + + K  + V D+A EL+D+Y +R   EG+ +  D  +   F   F
Sbjct  556   KTPKLNKLGGSEWKKTKAKVQQSVEDIAEELIDLYKEREMAEGYQYGEDTAEQTTFELDF  615

Query  598   PFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVP  657
             P+E TPDQA++I+ +  DM +   MDRL+CGDVG+GKTEVA+RAAF AV   KQVA LVP
Sbjct  616   PYELTPDQAKSIDEIKDDMQKSRPMDRLLCGDVGYGKTEVAVRAAFKAVMEGKQVAFLVP  675

Query  658   TTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSD  717
             TT+LAQQHY+   +R  ++PV I+++SRFR+ KE  Q    +  G +DI++GTHKLL  D
Sbjct  676   TTILAQQHYETLIERMQDFPVEIQLMSRFRTPKEIKQTKEGLKTGFVDIVVGTHKLLSKD  735

Query  718   VKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIA  777
             +++KDLGLLIVDEE RFGVRHKERIK ++ NVD+LTLTATPIPRTL+M+M G+RDLS+I 
Sbjct  736   IQYKDLGLLIVDEEQRFGVRHKERIKTLKHNVDVLTLTATPIPRTLHMSMLGVRDLSVIE  795

Query  778   TPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEAR  837
             TPP  R  V+T+V E +   ++EA+ RE+ R GQV+YLYN V++I +  E+L  L+P+A 
Sbjct  796   TPPENRFPVQTYVLEQNMSFIKEALERELSRDGQVFYLYNKVQSIYEKREQLQMLMPDAN  855

Query  838   IAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLH  897
             IA+ HGQM ER+LE  M  F +  +++LV TTIIETG+D+P ANT+IIE AD FGL+QL+
Sbjct  856   IAVAHGQMTERDLEETMLSFINNEYDILVTTTIIETGVDVPNANTLIIEDADRFGLSQLY  915

Query  898   QLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGE  957
             QLRGRVGRS    YA+ L P  K +T  A+ RL+AI    +LG+GF +A  DL IRGAG 
Sbjct  916   QLRGRVGRSSRIGYAYFLHPANKVLTETAEDRLQAIKEFTELGSGFKIAMRDLNIRGAGN  975

Query  958   LLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFI  1017
             LLG++Q G ++T+GF LY ++LE AV+  +  +EP        + EV+L + + LP ++I
Sbjct  976   LLGKQQHGFIDTVGFDLYSQMLEEAVNEKRGIKEPE---SEVPEVEVDLNLDAYLPTEYI  1032

Query  1018  PDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRK  1077
              +   ++  YK++   +T +++ +IK ELIDRF   P     LLDI  ++  A   GI  
Sbjct  1033  ANEQAKIEIYKKLRKTETFDQIIDIKDELIDRFNDYPVEVARLLDIVEIKVHALHSGITL  1092

Query  1078  LEGNEKGGVIE  1088
             ++  +KG +I+
Sbjct  1093  IK--DKGKIID  1101


>Q6GBY5.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
 Q8NXZ6.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1168

 Score = 687 bits (1774),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 398/1091 (36%), Positives = 634/1091 (58%), Gaps = 36/1091 (3%)

Query  18    LLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN---LADWE  74
             L+  L+ +A  T++AE   +    ++LI  ++  A +L  ++ QF D   +    + D  
Sbjct  27    LVTGLSPSAKVTMIAEKYAQSNQQLLLITNNLYQADKLETDLLQFIDAEELYKYPVQDIM  86

Query  75    TLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHALVMKKGQ  134
             T  + + SP   ++S R+ TL  L   ++G+ IVP+N L + + P      H + ++ G+
Sbjct  87    TEEFSTQSPQ--LMSERIRTLTALAQGKKGLFIVPLNGLKKWLTPVEMWQNHQMTLRVGE  144

Query  135   RLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRV  194
              +  D    +L + GY+    V   GE++ RG ++D+FP+  E P R++ FD +IDS+R 
Sbjct  145   DIDVDQFLNKLVNMGYKRESVVSHIGEFSLRGGIIDIFPLIGE-PIRIELFDTKIDSIRD  203

Query  195   FDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFE---------VKRDPEHIY  245
             FDV++QR+ + V+ +++  A ++   +  I   + + +  +E         V+ D +  Y
Sbjct  204   FDVETQRSKDNVEEVDITTASDYIITEEVISHLKEELKTAYENTRPKIDKSVRNDLKETY  263

Query  246   QQVS---KGTLPAGIEYWQPLFFSEPLPPLFSYFPANTLLV--NTGDLENSAERFQADTL  300
             +             I      F  E    +  YF  + ++       ++ + E    ++ 
Sbjct  264   ESFKLFESTYFDHQILRRLVAFMYETPSTIIEYFQKDAIIAVDEFNRIKETEESLTVES-  322

Query  301   ARFENRGVDPMRPLLPPQSLWLRVDELFSELKNWP--RVQLKTEHLPTKAANANLGFQKL  358
               F +  ++     +  QS +++ D+  + ++ +P     L    +P K  N  + F   
Sbjct  323   DSFISNIIESGNGFIG-QS-FIKYDDFETLIEGYPVTYFSLFATTMPIKL-NHIIKFSCK  379

Query  359   PDLAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEA  418
             P      Q        ++++   +  +V  VE+E + E +  +L+ + I    I +L  +
Sbjct  380   PVQQFYGQYDIMRSEFQRYVNQ-NYHIVVLVETETKVERMQAMLSEMHIPS--ITKLHRS  436

Query  419   SDRGRYLMI-GAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRNLAEL  477
                G+ ++I G+   GF      L +I E +L   +  ++R+   +AI+    I++  +L
Sbjct  437   MSSGQAVIIEGSLSEGFELPDMGLVVITERELFKSKQKKQRK-RTKAISNAEKIKSYQDL  495

Query  478   HIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAE  537
             ++G  +VH+ HGVGRY G+ TLE G    +Y+ L Y    +L+VPV  +  + +Y    +
Sbjct  496   NVGDYIVHVHHGVGRYLGVETLEVGQTHRDYIKLQYKGTDQLFVPVDQMDQVQKYVASED  555

Query  538   ENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSF  597
             +   L+KLGG  W + + K  + V D+A EL+D+Y +R   EG+ +  D  +   F   F
Sbjct  556   KTPKLNKLGGSEWKKTKAKVQQSVEDIAEELIDLYKEREMAEGYQYGEDTAEQTTFELDF  615

Query  598   PFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVP  657
             P+E TPDQA++I+ +  DM +   MDRL+CGDVG+GKTEVA+RAAF AV   KQVA LVP
Sbjct  616   PYELTPDQAKSIDEIKDDMQKSRPMDRLLCGDVGYGKTEVAVRAAFKAVMEGKQVAFLVP  675

Query  658   TTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSD  717
             TT+LAQQHY+   +R  ++PV I+++SRFR+ KE  Q    +  G +DI++GTHKLL  D
Sbjct  676   TTILAQQHYETLIERMQDFPVEIQLMSRFRTPKEIKQTKEGLKTGFVDIVVGTHKLLSKD  735

Query  718   VKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIA  777
             +++KDLGLLIVDEE RFGVRHKERIK ++ NVD+LTLTATPIPRTL+M+M G+RDLS+I 
Sbjct  736   IQYKDLGLLIVDEEQRFGVRHKERIKTLKHNVDVLTLTATPIPRTLHMSMLGVRDLSVIE  795

Query  778   TPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEAR  837
             TPP  R  V+T+V E +   ++EA+ RE+ R GQV+YLYN V++I +  E+L  L+P+A 
Sbjct  796   TPPENRFPVQTYVLEQNMSFIKEALERELSRDGQVFYLYNKVQSIYEKREQLQMLMPDAN  855

Query  838   IAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLH  897
             IA+ HGQM ER+LE  M  F +  +++LV TTIIETG+D+P ANT+IIE AD FGL+QL+
Sbjct  856   IAVAHGQMTERDLEETMLSFINNEYDILVTTTIIETGVDVPNANTLIIEDADRFGLSQLY  915

Query  898   QLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGE  957
             QLRGRVGRS    YA+ L P  K +T  A+ RL+AI    +LG+GF +A  DL IRGAG 
Sbjct  916   QLRGRVGRSSRIGYAYFLHPANKVLTETAEDRLQAIKEFTELGSGFKIAMRDLNIRGAGN  975

Query  958   LLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFI  1017
             LLG++Q G ++T+GF LY ++LE AV+  +  +EP        + EV+L + + LP ++I
Sbjct  976   LLGKQQHGFIDTVGFDLYSQMLEEAVNEKRGIKEPE---SEVPEVEVDLNLDAYLPTEYI  1032

Query  1018  PDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRK  1077
              +   ++  YK++   +T +++ +IK ELIDRF   P     LLDI  ++  A   GI  
Sbjct  1033  ANEQAKIEIYKKLRKTETFDQIIDIKDELIDRFNDYPVEVARLLDIVEIKVHALHSGITL  1092

Query  1078  LEGNEKGGVIE  1088
             ++  +KG +I+
Sbjct  1093  IK--DKGKIID  1101


>Q2YVY2.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1168

 Score = 685 bits (1767),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 395/1091 (36%), Positives = 631/1091 (58%), Gaps = 36/1091 (3%)

Query  18    LLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN---LADWE  74
             L+  L+ +A  T++AE   +    ++LI  ++  A +L  ++ QF D   +    + D  
Sbjct  27    LVTGLSPSAKVTMIAEKYAQSNQQLLLITNNLYQADKLETDLLQFIDAEELYKYPVQDIM  86

Query  75    TLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHALVMKKGQ  134
             T  + + SP   ++S R+ TL  L   ++G+ IVP+N L + +        H + ++ G+
Sbjct  87    TEEFSTQSPQ--LMSERIRTLTALAQGKKGLFIVPLNGLKKWLTSVEMWQNHQMTLRVGE  144

Query  135   RLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRV  194
              +  D    +L + GY+    V   GE++ RG ++D+FP+  E P R++ FD EIDS+R 
Sbjct  145   DIDVDQFLNKLVNMGYKRESVVSHIGEFSLRGGIIDIFPLIGE-PIRIELFDTEIDSIRD  203

Query  195   FDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFE---------VKRDPEHIY  245
             FDV++QR+ + ++ +++  A ++   +  I   + + +  +E         V+ D +  Y
Sbjct  204   FDVETQRSKDNIEEVDITTASDYIITEEVIRHLKEELKTAYENTRPKIDKSVRNDLKETY  263

Query  246   QQVS---KGTLPAGIEYWQPLFFSEPLPPLFSYFPANTLLV--NTGDLENSAERFQADTL  300
             +             I      F  E    +  YF  + ++       ++ + E    ++ 
Sbjct  264   ESFKLFESTYFDHQILRRLVAFMYETPSTIIDYFQKDAIIAVDEFNRIKETEESLTVES-  322

Query  301   ARFENRGVDPMRPLLPPQSLWLRVDELFSELKNWP--RVQLKTEHLPTKAANANLGFQKL  358
               F +  ++     +     +++ D+  + ++ +P     L    +P K  N  + F   
Sbjct  323   DSFISNIIESGNGFIGQS--FIKYDDFETLIEGYPVTYFSLFATTMPIKL-NHIIKFSCK  379

Query  359   PDLAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEA  418
             P      Q        ++++   +  +V  VE+E + E +  +L+ + I    I +L  +
Sbjct  380   PVQQFYGQYDIMRSEFQRYVNQ-NYHIVVLVETETKVERMQAMLSEMHIPS--ITKLHRS  436

Query  419   SDRGRYLMI-GAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRNLAEL  477
                G+ ++I G+   GF      L +I E +L   +  ++R+   +AI+    I++  +L
Sbjct  437   MSSGQAVIIEGSLSEGFELPDMGLVVITERELFKSKQKKQRK-RTKAISNAEKIKSYQDL  495

Query  478   HIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAE  537
             ++G  +VH+ HGVGRY G+ TLE G    +Y+ L Y    +L+VPV  +  + +Y    +
Sbjct  496   NVGDYIVHVHHGVGRYLGVETLEVGQTHRDYIKLQYKGTDQLFVPVDQMDQVQKYVASED  555

Query  538   ENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSF  597
             +   L+KLGG  W + + K  + V D+A EL+D+Y +R   EG+ +  D  +   F   F
Sbjct  556   KTPKLNKLGGSEWKKTKAKVQQSVEDIAEELIDLYKEREMAEGYQYGEDTAEQTTFELDF  615

Query  598   PFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVP  657
             P+E TPDQA++I+ +  DM +   MDRL+CGDVG+GKTEVA+RAAF AV   KQVA LVP
Sbjct  616   PYELTPDQAKSIDEIKDDMQKSRPMDRLLCGDVGYGKTEVAVRAAFKAVMEGKQVAFLVP  675

Query  658   TTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSD  717
             TT+LAQQHY+   +R  ++PV I+++SRFR+ KE  Q    +  G +DI++GTHKLL  D
Sbjct  676   TTILAQQHYETLIERMQDFPVEIQLMSRFRTPKEIKQTKEGLKTGFVDIVVGTHKLLSKD  735

Query  718   VKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIA  777
             +++KDLGLLIVDEE RFGVRHKERIK ++ NVD+LTLTATPIPRTL+M+M G+RDLS+I 
Sbjct  736   IQYKDLGLLIVDEEQRFGVRHKERIKTLKHNVDVLTLTATPIPRTLHMSMLGVRDLSVIE  795

Query  778   TPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEAR  837
             TPP  R  V+T+V E +   ++EA+ RE+ R GQV+YLYN V++I +  E+L  L+P+A 
Sbjct  796   TPPENRFPVQTYVLEQNMSFIKEALERELSRDGQVFYLYNKVQSIYEKREQLQMLMPDAN  855

Query  838   IAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLH  897
             IA+ HGQM ER+LE  M  F +  +++LV TTIIETG+D+P ANT+IIE AD FGL+QL+
Sbjct  856   IAVAHGQMTERDLEETMLSFINNEYDILVTTTIIETGVDVPNANTLIIEDADRFGLSQLY  915

Query  898   QLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGE  957
             QLRGRVGRS    YA+ L P  K +T  A+ RL+AI    +LG+GF +A  DL IRGAG 
Sbjct  916   QLRGRVGRSSRIGYAYFLHPANKVLTETAEDRLQAIKEFTELGSGFKIAMRDLNIRGAGN  975

Query  958   LLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFI  1017
             LLG++Q G ++T+GF LY ++LE AV+  +  +EP        + EV+L + + LP ++I
Sbjct  976   LLGKQQHGFIDTVGFDLYSQMLEEAVNEKRGIKEPE---SEVPEVEVDLNLDAYLPTEYI  1032

Query  1018  PDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRK  1077
              +   ++  YK++   +T +++ +IK ELIDRF   P     LLDI  ++  A   GI  
Sbjct  1033  ANEQAKIEIYKKLRKTETFDQIIDIKDELIDRFNDYPVEVARLLDIVEIKVHALHSGITL  1092

Query  1078  LEGNEKGGVIE  1088
             ++  +KG +I+
Sbjct  1093  IK--DKGKIID  1101


>O52236.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1201

 Score = 669 bits (1726),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 336/690 (49%), Positives = 473/690 (69%), Gaps = 8/690 (1%)

Query  424   YLMIGAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRNLAELHIGQPV  483
             +L  G   HGFVD    LA++ + ++ G R  RR + S++    D       +L  G  +
Sbjct  482   HLFTGEVSHGFVDGPGGLAVLADEEIFGARARRRPKRSKKL---DAFGSGFGDLKEGDLI  538

Query  484   VHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAEENAPLH  543
             VH + G+GRYAG+T +E  G+ G++L+L YA   K+Y+PV  + LI +++GG      L 
Sbjct  539   VHTDFGIGRYAGLTKMEVNGVPGDFLVLEYAGRDKIYLPVGRMRLIQKFSGGDPTQVQLD  598

Query  544   KLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSFPFETTP  603
             KLG  +W + +++  E++  +AAELL I A R A  G AF      +  F   F FE TP
Sbjct  599   KLGTTSWEKTKKRVKEQLLKMAAELLQIAAARKAHPGHAFSAPDRYFAQFEADFEFEETP  658

Query  604   DQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVPTTLLAQ  663
             DQA+AI  VL+DM +P  MDRLVCGDVG+GKTEVAMRAAF A  + KQVAVLVPTT+LAQ
Sbjct  659   DQAKAIEDVLADMQKPEPMDRLVCGDVGYGKTEVAMRAAFKAALDRKQVAVLVPTTVLAQ  718

Query  664   QHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDL  723
             QH+ +F+ RFA++PV +E+IS  + A E  +IL    EGK+DILIGTHKLL  +V FK+L
Sbjct  719   QHFLSFKKRFADYPVTVEVISGLKKAPEVREILKRAKEGKVDILIGTHKLLGGEVAFKEL  778

Query  724   GLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIATPPARR  783
             GL+IVDEE RFGV+ KE +K  R+ +D+LTLTATPIPRTL+M+MSG+RD+SIIATPP  R
Sbjct  779   GLMIVDEEQRFGVKQKESLKKWRSQIDVLTLTATPIPRTLHMSMSGVRDMSIIATPPQDR  838

Query  784   LAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEARIAIGHG  843
              A++TFV +Y+  VV+EAI RE+ RGGQV++++N VE++     +L  LVP+  I + HG
Sbjct  839   RAIRTFVMKYEDTVVKEAIEREVARGGQVFFVHNRVESLPSIETQLRALVPQVSIGVAHG  898

Query  844   QMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRV  903
             QM E +LE+VM  F  +++ VL+CT+IIE+GIDI +ANT+I+ RAD FGLAQL+QLRGRV
Sbjct  899   QMGEGQLEKVMLAFTEKKYQVLLCTSIIESGIDISSANTMIVNRADQFGLAQLYQLRGRV  958

Query  904   GRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQ  963
             GRS  +AYA+LL P  +A+T DAQ+RLE + +  +LGAGF++A+HDLEIRGAG LLG++Q
Sbjct  959   GRSKERAYAYLLVPSRRAVTKDAQRRLEVLQNFTELGAGFSIASHDLEIRGAGNLLGDKQ  1018

Query  964   SGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFIPDVNTR  1023
             SG++  IGF +Y +LLE AV  ++ G+ P ++     + +V L MP+L+PDD++ DV+ R
Sbjct  1019  SGAIAEIGFDMYAQLLEEAVAEMQ-GQPPKVQ----IEPDVTLPMPALIPDDYVSDVHQR  1073

Query  1024  LSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKLEGNEK  1083
             L FYKR + A   +E+ +++ EL+DR+G  PD    L ++  L+   + L +R LE    
Sbjct  1074  LVFYKRFSQASHPDEVTDLRAELVDRYGEAPDEVDHLSELTLLKIDMRDLRLRGLEVGTT  1133

Query  1084  GGVIEFAEKNHVNPAWLIGLLQKQPQHYRL  1113
               V+       ++   + GL+Q+    YRL
Sbjct  1134  RLVVTLGADALLDGPKVAGLVQRSKGVYRL  1163


 Score = 97.1 bits (240),  Expect = 6e-19, Method: Compositional matrix adjust.
 Identities = 70/214 (33%), Positives = 111/214 (52%), Gaps = 8/214 (4%)

Query  11   VKAGEQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQM----  66
            ++AG++     L GAA   ++A +      P+V +A D + A  L  ++S F        
Sbjct  38   LRAGQRVRTQGLKGAARGHVLARLHGALRAPLVCVAVDEEAADALAADLSFFLGGQGSLL  97

Query  67   ---VMNLADWETLPYDSFSPHQDIISSRLSTLYQLPTMQR-GVLIVPVNTLMQRVCPHSF  122
               V+ L   E LPYD  SP    ++ RL  L+ L    R   L++ V  L ++V P + 
Sbjct  98   APRVLRLPADEVLPYDEVSPDAAAVTERLGALFHLGQGTRFPALVLSVRALHRKVLPLAV  157

Query  123  LHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRL  182
            +   A  +  GQ   RD+L  +L   GY++   V + G ++ RG LLD+F    + P RL
Sbjct  158  MRALAARVAVGQDFDRDSLARRLVRMGYQNSPLVEDVGTFSVRGDLLDVFSPLYDKPVRL  217

Query  183  DFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHE  216
            +FF D I+S+R FD  SQRT++ +  ++L+PA E
Sbjct  218  EFFGDTIESIRAFDPQSQRTVDALKEVDLVPARE  251


>Q49V12.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1170

 Score = 667 bits (1721),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 396/1120 (35%), Positives = 637/1120 (57%), Gaps = 37/1120 (3%)

Query  11    VKAGEQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN-  69
             V   E  L+  L+GAA AT++AE        ++++  ++  A +L  ++ QF +   +  
Sbjct  21    VFGKENVLVTGLSGAAKATIIAEKYLNSEQQLLVVTNNLYQADKLESDLLQFVEDSEIYK  80

Query  70    --LADWETLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHA  127
               + D  T  + + SP    +S R+ TL  L   +RG+ IVP+N L + + P      H 
Sbjct  81    YPMQDIMTEEFSTQSPQ--FMSERVRTLTALAQEERGLFIVPLNGLKKWLTPVDMWKSHQ  138

Query  128   LVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDD  187
             L +  G  +  D    +L + GYR    V   GE++ RG ++D++P+  + P R++FFD 
Sbjct  139   LTLNVGDDIDIDEFLNKLVNMGYRRESVVSHIGEFSLRGGIVDIYPLIGK-PVRIEFFDT  197

Query  188   EIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFEVKRDPEHIYQQ  247
             E+DS+R FDV+SQR+   ++ +++  A ++   +  ++  + + +  +E   D     ++
Sbjct  198   EVDSIRDFDVESQRSEGNIEHVDITTASDYIITEDVLKHTKHKLKQAYE---DTRPKIEK  254

Query  248   VSKGTLPAGIEYWQPL---------------FFSEPLPPLFSYFPANTLL-VNTGDLENS  291
               +  L    E +Q                 F  E    +  YF  + ++ V+  +    
Sbjct  255   SVRNELKETYESFQLFEAEMFDHQVLRRLVAFMYEQPATIMDYFKEDAIIAVDEYNRIKE  314

Query  292   AERFQADTLARFENRGVDPMRPLLPPQSLWLRVDELFSELKNW--PRVQLKTEHLPTKAA  349
              E      +  F    ++  +  +  QS +L+ +   + LK +      L T  +P +  
Sbjct  315   TETTLVTEIDEFMQNLIESGKGFID-QS-FLQYEGFENLLKPFAVTYFTLFTATMPVQL-  371

Query  350   NANLGFQKLPDLAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGELLARIKIAP  409
             N  + F   P      Q        ++F+++ D  +V   E+E ++E +  +L  + I P
Sbjct  372   NEIIKFSCKPVQQFYGQYDIMRSEFQRFIQN-DYTIVVLAETETKKERIQSMLNEMHI-P  429

Query  410   QRIMRLDEASDRGRYLMI-GAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPD  468
               I      ++ G  ++  G+   GF      L ++ E +L   +  ++ +  +   N +
Sbjct  430   TFIDTPSRRNEGGSAIITEGSLSEGFELPYMQLVVVTERELFKSKQKKKPKQHKTLTNAE  489

Query  469   TLIRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHL  528
               I++  +L +G  VVH+ HGVGRY G+ TLE GG+  +Y+ L Y    +L+VPV  +  
Sbjct  490   K-IKSYQDLKVGDYVVHVHHGVGRYLGVETLEVGGVHKDYIKLQYKGTDQLFVPVDQMDQ  548

Query  529   ISRYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDRE  588
             + +Y    +++  L+KLGG  W + + K  + V D+A EL+++Y  R    G+ F  D  
Sbjct  549   VQKYVASEDKSPKLNKLGGTEWKKTKAKVQQSVEDMADELIELYKAREMSVGYKFGPDTA  608

Query  589   QYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDN  648
             +   F   FP+E TPDQ+++I  +  DM     MDRL+CGDVG+GKTEVA+RAAF AV  
Sbjct  609   EQNDFEIDFPYELTPDQSKSIEEIKQDMEIERPMDRLLCGDVGYGKTEVAVRAAFKAVME  668

Query  649   HKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILI  708
              KQVA LVPTT+LAQQHY+   +R  ++P+ +++ISRFR+ KE  +    +  G +DI++
Sbjct  669   GKQVAFLVPTTILAQQHYETLIERMQDFPIEVQLISRFRTTKEVKETKEGLKSGFVDIVV  728

Query  709   GTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMS  768
             GTHKLL  D+++KDLGLLIVDEE RFGVRHKERIK+++ NVD+LTLTATPIPRTL+M+M 
Sbjct  729   GTHKLLGKDIQYKDLGLLIVDEEQRFGVRHKERIKSLKNNVDVLTLTATPIPRTLHMSML  788

Query  769   GMRDLSIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAER  828
             G+RDLS+I TPP  R  V+T+V E ++  ++EA+ RE+ R GQV+YLYN V++I +  E+
Sbjct  789   GVRDLSVIETPPENRFPVQTYVLEQNTNFIKEALERELSRDGQVFYLYNKVQSIYEKREQ  848

Query  829   LAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERA  888
             L  L+P+A I + HGQM ER+LE  M  F +  ++++V TTIIETG+D+P ANT+IIE A
Sbjct  849   LQMLMPDANIGVAHGQMNERDLEETMLSFINHEYDIIVTTTIIETGVDVPNANTLIIEDA  908

Query  889   DHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATH  948
             D FGL+QL+QLRGRVGRS    YA+ L P  K ++  A+ RL+AI    +LG+GF +A  
Sbjct  909   DRFGLSQLYQLRGRVGRSSRIGYAYFLHPTNKVLSETAEDRLQAIKEFTELGSGFKIAMR  968

Query  949   DLEIRGAGELLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRM  1008
             DL IRGAG LLG++Q G ++++GF LY ++LE AV+  K G +   +D  + + E+EL +
Sbjct  969   DLNIRGAGNLLGKQQHGFIDSVGFDLYSQMLEEAVNE-KRGIKAEKQD--APEIEIELNI  1025

Query  1009  PSLLPDDFIPDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQ  1068
              + LP ++IP+  +++  YK++   ++E +L ++K ELIDRF   P     LL++  ++ 
Sbjct  1026  DAYLPAEYIPNEQSKIEIYKKLRKIESETQLMDVKDELIDRFNDYPIEVERLLEMMEIKV  1085

Query  1069  QAQKLGIRKLEGNEKGGVIEFAEKNHVNPAWLIGLLQKQP  1108
              A   G+  ++   K   +  +EK   +        Q QP
Sbjct  1086  HALHAGVTLIKDVGKQVEVYLSEKGTTDINGETLFKQTQP  1125


>Q4UMJ0.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1142

 Score = 620 bits (1598),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 368/1119 (33%), Positives = 609/1119 (54%), Gaps = 47/1119 (4%)

Query  43    VLIAPDMQNALRLHDEISQFT-DQMVMNLADWETLPYDSFSPHQDIISSRLSTLYQLPTM  101
             +L + +   AL+L+ +   F+ ++ +     ++T+PYD  SP+ +I+S R   L +L T 
Sbjct  28    ILSSSNEDEALQLYKQALFFSSNENIYYFPSYDTIPYDHTSPNANILSRRAEILTKLTTN  87

Query  102   QRG--VLIVPVNTLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEH  159
                  +LI     L+ ++ P  F   + L +    + + D L   L    +      ++ 
Sbjct  88    NSNGKLLITYAANLLNKLPPKDFFSKYFLKLSPKMKFTTDELAMFLVENSFTRNASSIDV  147

Query  160   GEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPT  219
             GE+A RG ++D+   G +  YR++F  D I+S++ FD+D+Q + +    + + PA+E   
Sbjct  148   GEFAVRGEIIDIILPGPK-AYRINFSWDYIESIKEFDIDTQISTKSCSELVISPANEIVL  206

Query  220   DKAAIELFRSQWRDTFEVKRDPEHIYQQVSKGTLPAGIEYWQPLFFSEPLPPLFSYFPAN  279
             +      F++ +   F V      +Y+ V  G   AG E   PLF++     L  Y    
Sbjct  207   NSETNGNFKNNYLRNFGVNHTDNPLYEAVISGRKFAGYEQLLPLFYN-SCSSLVDYLNDP  265

Query  280   TLLVNTG------DLENSAERFQADTLARFENRGV--DPMRPLLPPQSLWLRVDELFSEL  331
               + +        + E+S   F +   AR E   +  +   P L P  L+    E+   L
Sbjct  266   IFIFDNLSKQAILEFEHSYNDFYS---ARSEVNKLKFNSFYPTLSPTDLYFTASEITELL  322

Query  332   KNWPRVQLKTEHLPTKAANANLGFQKLPDLAIQAQQKAPLDALRKFLESFDGP-VVFSVE  390
             +    + +  E+        N+            ++K   D L + +++     +V    
Sbjct  323   EQKNNIFISYENSEQATLIENISSASF------IEKKTVFDKLFEIIKAHSSKKIVIGAA  376

Query  391   SEGRREALGELLARIKIAPQRIMRLDEASDRGRYLMIGAAEHGFVDTVRNLALICESDLL  450
             S    E +  +    +     I +LDEA  +   + +G          +    I  S+LL
Sbjct  377   SLSGLERIKSITQNYEYKYNEINKLDEA--KASVINVGIIPLNQSFYTKEYLFITASELL  434

Query  451   GERVARRRQDSRRAINPDTLIRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLM  510
              E+ +     +++  N    + NLAE   G+ VVH +HG+G++  +  LE  G   ++L 
Sbjct  435   EEK-SSSTNTNKKLKNILLELDNLAE---GEFVVHKDHGIGQFLKLEALEIKGKLHDFLK  490

Query  511   LTYANDAKLYVPVSSLHLISRYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLD  570
             + YA + KLY+PV ++ +I +Y     +NA L KLG  +W R++ K   +++++A  L+ 
Sbjct  491   ILYAGNDKLYIPVENIEVIKKYGN---DNAELDKLGSSSWQRSKAKLKNRIKEIALHLIQ  547

Query  571   IYAQRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDV  630
             I A+R      + + D E+Y  FC +FPF  T DQ  AIN +  D+   + MDRL+CGDV
Sbjct  548   IAAKRKLNSSASVEFDLEEYDKFCANFPFSETEDQLTAINDIKEDLRNGMLMDRLICGDV  607

Query  631   GFGKTEVAMRAAFL---AVDNH-KQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRF  686
             GFGKTEVAMRA F+   +++ H  QVAV+VPTT+L  QH+  F +RF  + + I+ +S  
Sbjct  608   GFGKTEVAMRAVFMVAKSLNEHLPQVAVVVPTTILCSQHFSRFIERFKGFGLNIKQLSSV  667

Query  687   RSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMR  746
              SAKE   I +E+  GKI+I+IGTH LL  + KF +L LLI+DEE  FGV  KE +K+++
Sbjct  668   ISAKEAKIIRSELESGKINIIIGTHSLLHKNTKFFNLKLLIIDEEQHFGVGQKEFLKSLK  727

Query  747   ANVDILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFVREYDSLVVREAILREI  806
             ++  +L ++ATPIPRTL M+M+G+++LSIIATPP  RL V+T V  +D +++R+A+LRE 
Sbjct  728   SSSHVLAMSATPIPRTLQMSMTGLKELSIIATPPLNRLEVRTMVMPFDPVIIRDALLREH  787

Query  807   LRGGQVYYLYNDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLV  866
              RGG+ +Y+   +++I+   ++L ++VPE    I HG+M   +++ VM++F+  +F++LV
Sbjct  788   FRGGRSFYVVPRIKDIEDIEKQLKQIVPELSYKIAHGKMTPSKIDEVMSEFYAGKFDILV  847

Query  867   CTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDA  926
              TTIIE+GIDI  ANT++I +AD  GL+QL+QLRGR+GR   + YA+L     K MT+ +
Sbjct  848   STTIIESGIDIAEANTMVIHKADMLGLSQLYQLRGRIGRGKVRGYAYLTVASHKKMTSHS  907

Query  927   QKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSGSMETIGFSLYMELLENAVDAL  986
              +RLE I +   LG+GF +A+HD+++RG G L+GEEQSG ++ +G  LY E+LE  +   
Sbjct  908   LRRLEIIQNSCALGSGFTIASHDMDLRGFGNLIGEEQSGQIKEVGTELYQEMLEEQIAIF  967

Query  987   KAGREPSLEDLTSQQT---EVELRMPSLLPDDFIPDVNTRLSFYKRIASAKTENELEEIK  1043
             K       E + S+Q     + L +   +PD++I D   +L  Y+RI +   E E+E+ K
Sbjct  968   KD------EPIVSEQLFIPTINLGLSVFIPDNYISDSALKLGLYRRIGNLSNEIEVEKFK  1021

Query  1044  VELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKLEGNEKGGVIEFAEKNHVNPAWLIGL  1103
              E+IDRFG LP     LLDI +++    KL I  L+  + G VI+F  KN      ++  
Sbjct  1022  DEMIDRFGSLPIEFNNLLDIVKIKLLCFKLNIENLDSGDNGFVIKFY-KNADMTDKILKF  1080

Query  1104  LQKQPQHYRLDGPTRLKFIQDLSERKTRIEWVRQFMREL  1142
             +       ++    +L +I+ L ++   +E V Q + +L
Sbjct  1081  VSTYSNQAKIKPDNKLVYIKKLVDKNIIVE-VNQLLWKL  1118


>Q92H58.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1122

 Score = 619 bits (1595),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 371/1122 (33%), Positives = 608/1122 (54%), Gaps = 48/1122 (4%)

Query  43    VLIAPDMQNALRLHDEISQFT-DQMVMNLADWETLPYDSFSPHQDIISSRLSTLYQLPTM  101
             +L A + + AL+L+ +   F+ ++ +     + T+PYD  SP+ +I+S R  TL +L T 
Sbjct  28    ILSASNEEEALQLYKQALFFSSNENIYYFPSYNTIPYDHTSPNANILSRRAETLIKLTTN  87

Query  102   QRG---VLIVPVNTLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVME  158
                   +LI     L+ ++ P  F   + L +    + + D L   L    +      ++
Sbjct  88    NSNSNKLLITHTANLLNKLPPKDFFSKYFLKLSPKMKFTTDELAMFLVENSFTRNASSID  147

Query  159   HGEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFP  218
              GE+A RG ++D+   G +  YR+ F    I+S++ FD+D+Q + +    + + PA+E  
Sbjct  148   VGEFAVRGEIIDIILSGPK-AYRIHFSWGYIESIKEFDIDTQISTKSCRELIISPANEIV  206

Query  219   TDKAAIELFRSQWRDTFEVKRDPEHIYQQVSKGTLPAGIEYWQPLFFSEPLPPLFSYFPA  278
              +   I  F++ +   F V      +Y+ V  G    G E   PLF+ +    L  Y   
Sbjct  207   LNSETIGNFKNNYLRNFGVNHTDNALYEAVISGRKFTGYEQLLPLFY-DSCSNLIDYLND  265

Query  279   NTLLVNTG------DLENSAERFQADTLARFENRGV--DPMRPLLPPQSLWLRVDELFSE  330
                + +        + E+S   F +   AR E   +  +   P L P SL+    E+   
Sbjct  266   PIFIFDNLSKKAILEFEHSYNDFYS---ARSEANKLKFNSFYPTLSPTSLYFTASEITEL  322

Query  331   LKNWPRVQLKTEHLPTKAANANLGFQKLPDLAIQAQQKAPLDALRKFLESFD-GPVVFSV  389
             L+    + L  E+    +   N+            ++K   D L + +++     ++   
Sbjct  323   LEQKNNILLTFENSEQASLIKNIAATSF------IEKKTVFDKLFEVIKANSHKKIIIGS  376

Query  390   ESEGRREALGELLARIKIAPQRIMRLDEASDRGRYLMIGAAEHGFVDTVRNLALICESDL  449
                   E +  ++   +     I +LDEA      + I      F    +    I  S+L
Sbjct  377   SVLSSFERIKSIIQNYEYKYNEINKLDEAKASIINVAIIPLNQSFY--TKEYLFITASEL  434

Query  450   LGERVARRRQDSRRAINPDTLIRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYL  509
             L E+ +    + ++  N    + NLAE   G+ VVH +HG+G++  +  LE  G   ++L
Sbjct  435   LEEKPSSTNTN-KKLKNILLELDNLAE---GEFVVHKDHGIGQFLKLEALEIKGKPHDFL  490

Query  510   MLTYANDAKLYVPVSSLHLISRYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELL  569
              + YA + KLY+PV S+ +I +Y     +NA L KLG  +W R++ K  ++++++A  L+
Sbjct  491   KILYAGNDKLYIPVESIEVIKKYGN---DNAELDKLGSVSWQRSKAKLKKRIKEIALHLI  547

Query  570   DIYAQRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGD  629
              I A+R      + + D E+Y  FC +FPF  T DQ  AIN +  D+   + MDRL+CGD
Sbjct  548   QIAAKRKLNSSASVEFDLEEYDKFCANFPFSETEDQLIAINDIKEDLRNGMLMDRLICGD  607

Query  630   VGFGKTEVAMRAAFL---AVDNH-KQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISR  685
             VGFGKTEVAMRA F+   +++ H  QVAV+VPTT+L  QH+  F +RF  + + I+ +S 
Sbjct  608   VGFGKTEVAMRAVFMVAKSLNEHLPQVAVVVPTTILCSQHFSRFIERFKGFGLNIKQLSS  667

Query  686   FRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAM  745
               S+KE   I +E+  GKI+I+IGTH LL  ++KF +L LLI+DEE  FGV  KE +K++
Sbjct  668   VISSKEAKIIRSELESGKINIIIGTHSLLHKNIKFFNLKLLIIDEEQHFGVGQKEFLKSL  727

Query  746   RANVDILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFVREYDSLVVREAILRE  805
             +++  +L ++ATPIPRTL M+M+G+++LSIIATPP  RL V T V  YD +++R+A+LRE
Sbjct  728   KSSSHVLAMSATPIPRTLQMSMTGLKELSIIATPPLNRLEVHTSVMPYDPVIIRDALLRE  787

Query  806   ILRGGQVYYLYNDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVL  865
               RGG+ +Y+   +++I+  A++L ++VPE    I +G+M   +++ VM++F+  +F++L
Sbjct  788   HFRGGRSFYVVPRIKDIEDIAKQLKQIVPELSYKIAYGKMTPSKIDEVMSEFYAGKFDIL  847

Query  866   VCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTD  925
             V TTIIE+GIDI  ANT+II  AD  GL+QL+QLRGR+GR   + YA+L     K MT+ 
Sbjct  848   VSTTIIESGIDIAEANTMIIHNADMLGLSQLYQLRGRIGRGKMRGYAYLTVASHKKMTSH  907

Query  926   AQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSGSMETIGFSLYMELLENAVDA  985
             + +RLE I +   LG+GF +A+ D+++RG G L+GEEQSG ++ +G  LY E+LE  +  
Sbjct  908   SLRRLEIIQNSCALGSGFTIASRDMDLRGFGNLIGEEQSGQIKEVGTELYQEMLEEQIAI  967

Query  986   LKAGREPSLEDLTSQQ---TEVELRMPSLLPDDFIPDVNTRLSFYKRIASAKTENELEEI  1042
              K       E + S+Q     + L +   +PD+++ D   +L  Y+RI +   E E+E  
Sbjct  968   FKD------ESIVSEQPFIPTINLGLSVFIPDNYVADAALKLGLYRRIGNLSNEIEVETF  1021

Query  1043  KVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKLEGNEKGGVIEFAEKNHVNPAWLIG  1102
             K E+IDRFGLLP     LLDI +++    KL I  L+  + G VI+F  KN      ++ 
Sbjct  1022  KDEMIDRFGLLPIEFNNLLDIVKIKLLCFKLNIENLDSGDNGFVIKFY-KNADMTDKILK  1080

Query  1103  LLQKQPQHYRLDGPTRLKFIQDLSERKTRIEWVRQFMRELEE  1144
              +       ++    +L +I+ L ++   +E   Q +  L E
Sbjct  1081  FVTTYSNQAKIKPDNKLVYIKKLVDKNIIVE-ANQLLWNLSE  1121


>O05955.2 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1120

 Score = 616 bits (1589),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 368/1142 (32%), Positives = 612/1142 (54%), Gaps = 54/1142 (5%)

Query  25    AACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFT-DQMVMNLADWETLPYDSFSP  83
             A C  ++    +      +L   + + AL+L+ +   F+ +  +     ++T+PYD  SP
Sbjct  10    AKCFYVIDNFTKNLNQDFILSVSNEEEALQLYKQALFFSSNDNIYYFPSYDTIPYDHTSP  69

Query  84    HQDIISSRLSTLYQLPTMQRG-VLIVPVNTLMQRVCPHSFLHGHALVMKKGQRLSRDALR  142
             + +I+S R  TL +L T  +G +LI     L+ ++ P  F   + L +    + + D L 
Sbjct  70    NANIVSRRAETLTKLITNSKGKLLITHAANLLNKLPPKDFFSKYFLKLYPKIKFTMDELS  129

Query  143   TQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRVFDVDSQRT  202
               L    +      ++ GE+A RG ++D+   G +  YR++F  D I+S++ FD+++Q +
Sbjct  130   MLLVENSFTRNTSSIDVGEFAVRGEIIDIILPGPK-GYRINFSWDYIESIKEFDINTQIS  188

Query  203   LEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFEVKRDPEHIYQQVSKGTLPAGIEYWQP  262
              +    + + PA+E   +   I  F++ +   F V      +Y+ V  G   AG E   P
Sbjct  189   TKYCAELVISPANEIVLNSETIGNFKNNYLRNFGVNHTDNPLYEAVISGRKFAGYEQLLP  248

Query  263   LFF----------SEPLPPLFSYFPANTLLVNTGDLENSAERFQADTLARFE-NR-GVDP  310
             LF+          + P+  +F       +L    + ENS   F    LAR + N+  V+ 
Sbjct  249   LFYYSCSSLVDYLNNPIC-IFDNLSKQAIL----EFENSYNDFY---LARSKANKLKVNN  300

Query  311   MRPLLPPQSLWLRVDELFSELKNWPRVQLKTEHLPTKAANANLGFQKLPDLAIQAQQKAP  370
               P L P SL+     +   L+    + +  E+    +   N+            ++K  
Sbjct  301   FYPTLSPTSLYFTASAITELLEQKNNILISYENSEQASLIGNISSISF------IEKKTI  354

Query  371   LDALRKFLES-FDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEASDRGRYLMIGA  429
              D L + +++ F   ++         E +  ++   +     I +LDEA  +   + IG 
Sbjct  355   FDKLFEIIKANFHKKIIICSSVLSSFERIKSIIQNYEYTFNEINKLDEA--KASVINIGI  412

Query  430   AEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRNLAELHIGQPVVHLEHG  489
                      +    I  S+LL E+      + +       ++  L  L  G+ VVH +HG
Sbjct  413   IPLNQSFYTKEYLFITSSELLEEKTLYTNTNKKLK----NILLELDNLKEGEFVVHKDHG  468

Query  490   VGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAEENAPLHKLGGDA  549
             +G++  +   +  G   ++L + Y  + KLYVPV ++ +I +Y     +NA L+KLG  A
Sbjct  469   IGQFLKLEAFKIQGKLHDFLKILYFGNDKLYVPVENIEVIKKYGS---DNAELNKLGSVA  525

Query  550   WSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAI  609
             W++++ K   ++++++  L+ I A+R        + D E Y  FC +FPF  T DQ  AI
Sbjct  526   WNKSKAKLKNRIKEISLHLIQIAAKRKLNISTPIELDLEAYDKFCANFPFSETEDQLTAI  585

Query  610   NAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHK----QVAVLVPTTLLAQQH  665
             N +  D+   + MDRL+CGDVGFGKTEVAMRA F+   +      QVAV+VPTT+L  QH
Sbjct  586   NDIREDLTNGMLMDRLICGDVGFGKTEVAMRAVFMVAKSLNEYLPQVAVVVPTTILCSQH  645

Query  666   YDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGL  725
             +  F +RF  + + I+ +S   S+KE   I  E+A GKI+I+IGTH LL  + KF +L L
Sbjct  646   FSRFIERFKGFGLNIKQLSSVISSKEANIIRLELASGKINIIIGTHALLHKNTKFFNLKL  705

Query  726   LIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLA  785
             LI+DEE  FGV  KE +K+++++  +L ++ATPIPRTL M+M+G+++LSIIATPP  RL 
Sbjct  706   LIIDEEQHFGVSQKEFLKSLKSSTHVLAMSATPIPRTLQMSMTGLKELSIIATPPLNRLE  765

Query  786   VKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEARIAIGHGQM  845
             V+T V  +D +++R+A+LRE  RGG+ +Y+   +++++   ++L ++VPE    I HG+M
Sbjct  766   VRTSVMPFDPVIIRDALLREHFRGGRSFYVAPRIKDMEDIEKQLKQIVPELSYKIAHGKM  825

Query  846   RERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGR  905
                +++ VM++F+  +F++L+ TTIIE+GIDI  ANT+II +AD  GL+QL+QLRGR+GR
Sbjct  826   TPSKIDEVMSEFYVGKFDILISTTIIESGIDIAEANTMIIHKADTLGLSQLYQLRGRIGR  885

Query  906   SHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSG  965
                + YA+L     K +T+ + +RLE I +   LG+GF +A+HD ++RG G L+GEEQSG
Sbjct  886   GKIRGYAYLTVASNKKITSHSLRRLEIIQNSCSLGSGFTIASHDADLRGFGNLIGEEQSG  945

Query  966   SMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQT---EVELRMPSLLPDDFIPDVNT  1022
              ++ +G  LY E+LE  +  LK       + +  +Q     + L +   +PD ++ D   
Sbjct  946   QIKEVGTELYQEMLEEQIALLKD------DPIVLEQAFIPNINLGLSVFIPDSYVSDSAL  999

Query  1023  RLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKLEGNE  1082
             ++  Y+RI +   E E+E+ K E+IDRFGLLP     LLDI +++    KL I  L+  +
Sbjct  1000  KIGLYRRIGNLSNEMEVEKFKDEMIDRFGLLPIEFNNLLDIVKIKLLCFKLNIENLDSGD  1059

Query  1083  KGGVIEFAEKNHVNPAWLIGLLQKQPQHYRLDGPTRLKFIQDLSERKTRIEWVRQFMREL  1142
              G VI F  KN      ++  + +     ++    +L FI+ L + K  I  V Q +  L
Sbjct  1060  DGFVIRFY-KNADMTDKILKFVSRYSNQTKIKPNNKLVFIKKLVD-KNIITEVNQLLWTL  1117

Query  1143  EE  1144
              E
Sbjct  1118  LE  1119


>Q9AKD5.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1120

 Score = 608 bits (1567),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 360/1127 (32%), Positives = 598/1127 (53%), Gaps = 45/1127 (4%)

Query  25    AACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFT-DQMVMNLADWETLPYDSFSP  83
             A C   +    +      +L   + + AL+L+ +   F+ ++ +     ++T+PYD  SP
Sbjct  10    AKCFFAIDNFTKHLNQDFILSVNNEEEALKLYKQAFFFSSNENIYYFPSYDTIPYDYTSP  69

Query  84    HQDIISSRLSTLYQLPTMQRG-VLIVPVNTLMQRVCPHSFLHGHALVMKKGQRLSRDALR  142
             + +IIS R  TL +L T     +LI     L+ ++ P  F   + L +    + + D L 
Sbjct  70    NTNIISRRAETLTKLITNNNSKLLITHAANLLNKLPPKDFFSKYFLKLYPKIKFTIDELS  129

Query  143   TQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRVFDVDSQRT  202
               L    +       + GE++ RG ++D+   G +  YR++F  D I+S++ FD+++Q +
Sbjct  130   MLLVENSFTRNISSNDVGEFSVRGEIIDIILPGPK-AYRINFSWDYIESIKEFDINTQIS  188

Query  203   LEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFEVKRDPEHIYQQVSKGTLPAGIEYWQP  262
              +    + + P  E   +   I  F++ +   F V      +Y+ V  G    G E   P
Sbjct  189   TKYCTELVISPVSEIVLNSKTIGNFKNNYLRNFGVNHTDNPLYEAVISGRKFPGYEQLLP  248

Query  263   LFFSEPLPPLFSYFPANTLLVNTG------DLENSAERFQADTLARFENRG--VDPMRPL  314
             LF+ +    L  Y      + +        + ENS   F    LAR       V+   P 
Sbjct  249   LFY-DSCSSLVDYLNDPICIFDNLSKQEILEFENSCNDFY---LARSNANKLKVNNFYPA  304

Query  315   LPPQSLWLRVDELFSELKNWPRVQLKTEHLPTKAANANLGFQKLPDLAIQAQQKAPLDAL  374
             L P SL+     +   L+    + +  E+    +   N+            ++K   D L
Sbjct  305   LSPASLYFTASAITELLEQKNNILISYENSEQASLIGNISSTSF------MEKKTIFDKL  358

Query  375   RKFLE-SFDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEASDRGRYLMIGAAEHG  433
              + ++ +F   ++         E +  ++   K     I +LD+A  +   + IG     
Sbjct  359   FELIKANFHKKIIICSSVLSSFERIKSIIQNYKYTFNEINKLDDA--KASVINIGIIPLN  416

Query  434   FVDTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRNLAELHIGQPVVHLEHGVGRY  493
                  +    I  S+LL E+      + ++  N    + NLAE   G+ VVH +HG+G++
Sbjct  417   QSFYTKEYLFITSSELLEEKTLYTNTN-KKLKNILLELDNLAE---GEFVVHKDHGIGQF  472

Query  494   AGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAEENAPLHKLGGDAWSRA  553
               +   E  G   ++L + Y+ + KLYVPV ++ +I +Y      N  L KLG  AW ++
Sbjct  473   LKLEAFEIQGKLHDFLKILYSGNDKLYVPVENIEVIKKYGSN---NVELDKLGSAAWHKS  529

Query  554   RQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVL  613
             + K  +++++++  L+ I A+R        + D E+Y  FC +FPF  T DQ  AIN + 
Sbjct  530   KAKLKDRIKEISLHLIQIAAKRKLNISTPIEFDLEEYDKFCANFPFIETEDQLTAINDIR  589

Query  614   SDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHK----QVAVLVPTTLLAQQHYDNF  669
              D+   + MDRL+CGDVGFGKTEVAMRA F+   +      QVAV+VPTT+L  QH+  F
Sbjct  590   KDLTNGMLMDRLICGDVGFGKTEVAMRAVFMVAKSLNEYLPQVAVVVPTTILCSQHFSRF  649

Query  670   RDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVD  729
              +RF  + + I+ +S   S++E   I  E+A GKI+I+IGTH LL  ++KF +L LLI+D
Sbjct  650   IERFKGFGLNIKQLSSVVSSQEANIIRLELASGKINIIIGTHTLLHKNIKFFNLKLLIID  709

Query  730   EEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTF  789
             EE  FGV  KE +K+++ +  +L ++ATPIPRTL M+++G+++LSIIATPP  RL V+T 
Sbjct  710   EEQHFGVSQKEFLKSLKYSSHVLAMSATPIPRTLQMSLTGLKELSIIATPPLNRLEVRTS  769

Query  790   VREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEARIAIGHGQMRERE  849
             V  +D++++R+A+LRE  RGG+ +Y+   +++++   ++L ++VPE    I HG+M   +
Sbjct  770   VMPFDTVIIRDALLREHFRGGRSFYVVPRIKDMEDIEKQLKQIVPELSYKIAHGKMTPSK  829

Query  850   LERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQ  909
             ++ VM++F+  +F++L+ TTIIE+GIDI  ANT+II  AD  GL+QL+QLRGR+GR   +
Sbjct  830   IDEVMSEFYAGKFDILISTTIIESGIDITEANTMIIHNADTLGLSQLYQLRGRIGRGKIR  889

Query  910   AYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSGSMET  969
              YA+L     K +   + +RLE I +   LG+GF +A+HD ++RG G L+GEEQSG +  
Sbjct  890   GYAYLTVASNKKLMQHSLRRLEIIQNSCALGSGFTIASHDADLRGFGNLIGEEQSGQIRE  949

Query  970   IGFSLYMELLENAVDALKAGREPSLEDLTSQQT---EVELRMPSLLPDDFIPDVNTRLSF  1026
             +G  LY E+LE  +  LK       E + S+Q+    + L +   +PD ++ D   +++ 
Sbjct  950   VGAELYQEMLEEQIALLKD------ESIVSEQSFIPNINLGLSVFIPDHYVSDSALKIAL  1003

Query  1027  YKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKLEGNEKGGV  1086
             Y+RI +   E E+E+ K E+IDRFGLLP     LLDI +++    KL I  L+  + G V
Sbjct  1004  YRRIGNLSNEIEVEKFKDEMIDRFGLLPIEFNNLLDIVKIKLLCFKLNIENLDSGDDGFV  1063

Query  1087  IEFAEKNHVNPAWLIGLLQKQPQHYRLDGPTRLKFIQDLSERKTRIE  1133
             I F  KN      ++  + +     ++    +L FI+ L ++    E
Sbjct  1064  IRFY-KNADMSDKILKFVSRYSNQTKIKPNNKLVFIKKLVDKNIITE  1109


>Q1RI82.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1120

 Score = 606 bits (1563),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 363/1124 (32%), Positives = 602/1124 (54%), Gaps = 54/1124 (5%)

Query  43    VLIAPDMQNALRLHDEISQFT-DQMVMNLADWETLPYDSFSPHQDIISSRLSTLYQLPTM  101
             VL+  + + AL+L+ +   F   + +     ++T+PYD  SP+ +I+S R  TL +L T 
Sbjct  28    VLVTSNEEEALQLYKQALFFLPSENIYYFPSYDTIPYDHTSPNCNILSKRAETLSKLTTN  87

Query  102   QRGVLIVP-VNTLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHG  160
             +   L++     L+ ++ P  F   + L +    +LS + L   L    +      ++ G
Sbjct  88    KGNKLVITHATNLLNKLPPKDFFAKYYLKLFPKMKLSANELSKFLVENSFTRNASTVDVG  147

Query  161   EYATRGALLDLFPMGSELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTD  220
             E+A RG ++DL    S+  YR++F  D ++S++ FD+D+Q +    + + + PA+E   +
Sbjct  148   EFAVRGEIVDLILPESK-GYRINFSWDYVESIKQFDIDTQISTRSCNELIISPANEIVLN  206

Query  221   KAAIELFRSQWRDTFEVKRDPEHIYQQVSKGTLPAGIEYWQPLFFSEPLPPLFSYFPANT  280
                I  F+  +   F V      +Y+ ++ G   +G E   PLF+ +    L  Y     
Sbjct  207   PETISNFKDNYLRNFGVNHTDNPLYEAITGGRKFSGYEQLLPLFY-DSYSGLTDYLNNPV  265

Query  281   LLVNTG------DLENSAERFQADTLARFENRGV--DPMRPLLPPQSLWLRVDELFSELK  332
             ++ +        + E+S   F     AR +   +  +   P L P  L+    E    L+
Sbjct  266   IIFDNLTKQAILEFEHSYNDFYK---ARLDANKLKFNSFYPTLSPSQLYFTSLEAIELLE  322

Query  333   NWPRVQLKTEHLPTKAANANLGFQKLPDLAIQAQQKAPLDALRKFLESFD-GPVVFSVES  391
                 + +  E+    +   N+        A   ++K   D L + +++     ++     
Sbjct  323   QENNILISYENSEQASIVENIA------AASFVEKKTIFDKLFEVIKANSRKKIIIGSSV  376

Query  392   EGRREALGELLARIKIAPQRIMRLDEASDRGRYLMIGAAEHGFVDTVRNLALICESDLLG  451
                 E +  ++   + +   I  L+EA      + I      F  +      I  S+LL 
Sbjct  377   LSSFERVKSIIENYEYSYNEIEYLEEAKTNTINIAILPLNQSF--STPEYLFIAASELLE  434

Query  452   ERVARRRQDSRRAINPDTLIRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLML  511
             E+V     + +       ++  L  L  G+ +VH +HG+G++  +  LE  G   ++L +
Sbjct  435   EKVTPTNTNKKLK----NILLELDHLAEGELIVHKDHGIGQFLKLEALEIKGKLHDFLKI  490

Query  512   TYANDAKLYVPVSSLHLISRYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDI  571
              YA + KLY+PV ++ +I +Y       A L KLG  +W + + K   +++++A  L+ I
Sbjct  491   LYAGNDKLYIPVENIEVIKKYGSDV---AQLDKLGSVSWQKNKAKLKNRIKEIALHLMQI  547

Query  572   YAQRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVG  631
              A+R      A + D E+Y  FC  FPF  T DQ  AIN +  D+   + MDRL+CGDVG
Sbjct  548   AAKRKLNTTAAIEFDLEEYDKFCAKFPFTETEDQLNAINDIREDLSNGMLMDRLICGDVG  607

Query  632   FGKTEVAMRAAFLAV----DNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFR  687
             FGKTEVAMRAAF+      +N  QVAV+VPTT+L  QH+  F +RF +  + I+ +S   
Sbjct  608   FGKTEVAMRAAFMVAKSLNENSPQVAVVVPTTILCSQHFARFTERFKDSDLNIKQLSSVV  667

Query  688   SAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRA  747
             S+KE   + +E+  GKI+I+IGTH LL    KF +L LLI+DEE  FGV  KE +K++++
Sbjct  668   SSKEAKIVRSELESGKINIIIGTHSLLHKVTKFCNLKLLIIDEEQHFGVGQKEFLKSLKS  727

Query  748   NVDILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFVREYDSLVVREAILREIL  807
             +  +L ++ATPIPRTL M+M+G+++LSIIATPP  RL V+T V  +D +++R+A+L E  
Sbjct  728   STHVLAMSATPIPRTLQMSMTGLKELSIIATPPLNRLEVRTSVMPFDPVIIRDALLHEHF  787

Query  808   RGGQVYYLY---NDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNV  864
             RGG+ +++    ND+E+I+K   +L ++VPE    + HG+M   +++ +M++F+  +F++
Sbjct  788   RGGKSFFVVPRINDIEDIEK---QLKQIVPELSYKVAHGKMSPNKIDEIMSEFYAGKFDI  844

Query  865   LVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTT  924
             L+ TTIIE+GIDI  ANT+II +AD  GL+QL+QLRGR+GR   + YA+L  P  K MT 
Sbjct  845   LISTTIIESGIDIQDANTMIIHKADMLGLSQLYQLRGRIGRGKMRGYAYLTLPSHKKMTP  904

Query  925   DAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSGSMETIGFSLYMELLENAVD  984
              + +RLE I +   LG+GF +A+HD+++RG G L+GEEQSG +  +G  LY E+LE  + 
Sbjct  905   HSLRRLEIIQNSCALGSGFTIASHDMDLRGFGNLIGEEQSGQIREVGTELYQEMLEEQIA  964

Query  985   ALK----AGREPSLEDLTSQQTEVELRMPSLLPDDFIPDVNTRLSFYKRIASAKTENELE  1040
               K    +G +P +         + L +   +PD+++ D   +L  Y+RI +   + E+E
Sbjct  965   IFKDEPISGEQPFI-------PTINLGLSVFIPDNYVSDSVLKLGLYRRIGNLNDDLEVE  1017

Query  1041  EIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKLEGNEKGGVIEFAEKNHVNPAWL  1100
             + K E+IDRFG LP     LLDI +++    KL I  L+  + G VI+F  KN      +
Sbjct  1018  KFKDEMIDRFGSLPTEFNNLLDIVKIKLLCFKLNIENLDSGDNGFVIKFY-KNADMADKI  1076

Query  1101  IGLLQKQPQHYRLDGPTRLKFIQDLSERKTRIEWVRQFMRELEE  1144
             +  +     + ++    +L FI+ L   KT I    Q +  L E
Sbjct  1077  LKFVSTYTANAKIKPDNKLVFIKKLV-GKTIITEANQLLWNLSE  1119


>Q55750.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1199

 Score = 597 bits (1538),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 309/692 (45%), Positives = 447/692 (65%), Gaps = 29/692 (4%)

Query  428   GAAE-HGFVDTVRNLALICESDLLG-------ERVARRRQDSRRAINPDTLIRNLAELHI  479
             G AE  GF+     L L+ + +L G       E V +RR+ + + ++       + +L  
Sbjct  477   GLAELEGFILPTFRLVLVTDRELFGQHALATPEYVRKRRRATSKQVD-------INKLSP  529

Query  480   GQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAEEN  539
             G  VVH  HG+G++  +  L       EYLM+ YA D  L VP  SL  +SR+       
Sbjct  530   GDYVVHKSHGIGKFLKLDALA----NREYLMIQYA-DGILRVPADSLDSLSRFRHTGTRP  584

Query  540   APLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSFPF  599
               LHK+GG  W   + K  + V+ +A +LL++YA+RA + G+A+  D    Q   DSFP+
Sbjct  585   PELHKMGGKVWEATKNKVRKAVKKLAVDLLNLYAKRAKQVGYAYPPDSPWQQELEDSFPY  644

Query  600   ETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDN-HKQVAVLVPT  658
             + TPDQ +A+  V  D+     MDRLVCGDVGFGKTEVA+RA F AV + +KQVA+L PT
Sbjct  645   QPTPDQLKAVQDVKRDLEGDRPMDRLVCGDVGFGKTEVAVRAIFKAVTSGNKQVALLAPT  704

Query  659   TLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDV  718
             T+L QQHY   ++RFA +P+ I +++RFR+A E+ +ILA++  G++DI++GT ++L + V
Sbjct  705   TVLTQQHYHTLKERFAPYPITIGLLNRFRTASEKKEILAKLKSGELDIVVGTQQVLGTSV  764

Query  719   KFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIAT  778
             KFKDLGLL++DEE RFGV  KE+IK ++  VD+LTLTATPIPRTL M++SG+R++S+I T
Sbjct  765   KFKDLGLLVIDEEQRFGVNQKEKIKTLKTEVDVLTLTATPIPRTLYMSLSGIREMSLITT  824

Query  779   PPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEARI  838
             PP  R  +KT +  Y+  V+R AI  E+ RGGQV+Y+   +E I++   +L ++VP ARI
Sbjct  825   PPPSRRPIKTHLSPYNPEVIRTAIRNELDRGGQVFYVVPRIEGIEELGGQLRQMVPSARI  884

Query  839   AIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQ  898
             AIGHGQM E ELE  M  F+    ++LVCTTIIE G+DIP  NTII+E A  FGLAQL+Q
Sbjct  885   AIGHGQMEESELESTMLAFNDGEADILVCTTIIEAGLDIPRVNTIIVEDAQKFGLAQLYQ  944

Query  899   LRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGEL  958
             LRGRVGRS  QA+AWLL P+ K +T  A+ RL A+     LG+G+ LAT D+EIRG G L
Sbjct  945   LRGRVGRSGIQAHAWLLYPNQKQLTEKARLRLRALQEFSQLGSGYQLATRDMEIRGVGNL  1004

Query  959   LGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFIP  1018
             LG EQSG ME IG+  YME+L++A+  ++    P +ED     T+++L + + +P D+IP
Sbjct  1005  LGAEQSGQMEAIGYEFYMEMLQDAIKEIQGQEIPKVED-----TQIDLPLTAFIPSDYIP  1059

Query  1019  DVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKL  1078
             D+  +++ Y+RI S ++ +EL +I ++  DR+G+LP P   L  + +L+  A+ LG  ++
Sbjct  1060  DLEEKMAAYRRITSIESTDELPKIALDWGDRYGMLPSPVEELFKVVKLKHLAKSLGFSRI  1119

Query  1079  EGNEKGGVIEFAEKNHVNPAWLIGLLQKQPQH  1110
             +   K  ++   E     PAW + L +  P H
Sbjct  1120  KVEGKQNLV--LETPMEEPAWKL-LAENLPNH  1148


 Score = 86.3 bits (212),  Expect = 1e-15, Method: Compositional matrix adjust.
 Identities = 68/262 (26%), Positives = 124/262 (47%), Gaps = 22/262 (8%)

Query  30   LVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWETLPYDSFSPHQDIIS  89
            +V+ +A+     +++I   ++ A R   ++     Q V      E  PYD      +++ 
Sbjct  79   IVSSLAQSLEKNLLVITATLEEAGRWTAQLELMGWQTVNFYPTSEASPYDPGRLESEMVW  138

Query  90   SRLSTLYQLPTMQ--RGVLIVPVNTLMQ-RVCPHSFLHGHALVMKKGQRLSRDALRTQLD  146
             ++  L +L      +G  IV     +Q  + P + L  + L +++GQ +   +L   L 
Sbjct  139  GQMQVLAELIQGHQVKGKAIVATEKALQPHLPPVATLREYCLALRRGQEMDSKSLELTLA  198

Query  147  SAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDEIDSLRVFDVDSQRTLEEV  206
              GY     V   G+++ RG ++D+FP+ +ELP RL++F DE++ +R FD  SQR+L+++
Sbjct  199  RLGYERGSTVETEGQWSRRGDIVDIFPVSAELPVRLEWFGDELEKIREFDPASQRSLDDL  258

Query  207  DAINLLPAH-----EFPTDKAAIELFRSQWRDTFEVKRDPEHIYQQVSKGTLPAGIEYWQ  261
              + L P       E   +  AI+L  S W +  E     E ++ +        G++ + 
Sbjct  259  TGLVLTPTSFDQVIEPALNAQAIDL--SAWGEDAET----EQLFGK-------EGLQRFL  305

Query  262  PLFFSEPLPPLFSYFPANTLLV  283
             L F+EP   L  Y P  T+ V
Sbjct  306  GLAFTEP-ACLLDYLPTETVCV  326


>O51568.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1125

 Score = 590 bits (1521),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 342/1110 (31%), Positives = 601/1110 (54%), Gaps = 63/1110 (6%)

Query  15    EQRLLGELTGAAC---ATLVAEIAE-RHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNL  70
             EQ +   LTG      A L+ +I E    G ++LI  D     ++ +++   T+Q +  L
Sbjct  25    EQNIFFSLTGYEGFFKAFLIKKIKEYSKTGKIILIVKDEHTLDKIKNDLQVITNQ-IFEL  83

Query  71    ADWETLPYDSFSPHQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVCPHSFLHGHALVM  130
               +  L Y        I + R+  L+       G+ I  + +L+ ++   + L  +   +
Sbjct  84    NYFSPLVYKGIGSKSTIFNERIKFLFNFYKKNPGIYITVLKSLLSKIPDKNTLLKNIYKI  143

Query  131   KKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYRLDFFDDEID  190
             +K   ++   +   L + GY    +V   GE+  +G ++D++P G + P R+    D+I+
Sbjct  144   EKNTNINTADIEKTLITLGYEKTLRVTIPGEFTVKGEIIDIYPFGEQNPIRIALNFDKIE  203

Query  191   SLRVFDVDSQ-RTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFEVKRDPEHI-YQQV  248
              ++ F+  +Q +   E+    +LP  E   D   I   +++ + + E K+  E + +++ 
Sbjct  204   EIKKFNPLTQLKHDNEILEFQILPKKEIIWDDKTINTLKTKIK-SVEYKKILEELDFKKE  262

Query  249   SKGTLPAGIEYWQPLFFSEPLPPLFSYFPANTLLVN--TGDLENSAERFQADTLARF---  303
             +K       E + PL  +  L         +T +VN    + E   E+   +    +   
Sbjct  263   TKTE-----EMFYPLVANTYLG---DEIEKHTPIVNFEINNFEKEIEKIHQEYEKLYKEA  314

Query  304   ENRG---VDPMRPLLPPQSLWLRVDELFSELKNWPRVQLKTEHLPTKAANANLGFQKLPD  360
             E  G   +DP R LL  ++  L+ D LFS++K+     LK++        +   F    +
Sbjct  315   EEAGKNIIDPKRILLNYKTFNLKSDVLFSKIKS-----LKSKETIEFKIESERNF--FSN  367

Query  361   LAIQAQQKAPLDALRKFLESFDGPVVFSVESEGRREALGELLARIKIAPQRIMRLDEASD  420
             +A+  ++         +L++    ++ + ESE ++E L  +   +      ++++  +  
Sbjct  368   IALTKEE------FENWLKN-GFKIIIAAESESQKEKLKYIFKELPKVSIEVLKISSSLI  420

Query  421   RGRYLMIGAAEHGFVDTVRNLALICESDLLGERVARRRQDSR-RAINPDTLIRNLAELHI  479
               +  +    E    +T             G+++ +  + S+ +AI+      +  E+  
Sbjct  421   IEKEKIAIILESNIFNT-------------GQKINKAFESSKTKAID------SFVEIEK  461

Query  480   GQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYANDAKLYVPVSSLHLISRYAGGAEEN  539
                VVH+ HG+G +  +  ++   +  +Y+ + YA   KL++P+   +LI +Y G   +N
Sbjct  462   NSHVVHINHGIGIFRQIKRIKTSSLEKDYIEIEYAEGEKLFIPIEQTNLIQKYIGSDPKN  521

Query  540   APLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSFPF  599
               L K+    W + +  A +++ ++A +L+++Y++R + +G  +  D E   LF   FP+
Sbjct  522   IKLDKISSKTWIKNKANAKKRIEEIADKLIELYSKRESIKGIKYPEDNELQLLFESEFPY  581

Query  600   ETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVPTT  659
             + TPDQ +AI  +  DM     MDRL+CGDVGFGKTEVAMRAAF AV  +KQV VL PTT
Sbjct  582   DETPDQIRAIKEIKEDMMSFKVMDRLLCGDVGFGKTEVAMRAAFKAVMGNKQVIVLSPTT  641

Query  660   LLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVK  719
             +LA+QH++ F+ RF N+P++IE++SRF     +++IL E+  GKIDI+IGTHK+L     
Sbjct  642   ILAEQHFNTFKKRFKNFPIKIEVLSRFIKNNAESRILKELKSGKIDIIIGTHKILSKKFT  701

Query  720   FKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIATP  779
              K+LGL+I+DEE RFGV+ KE++K +R +VD L L+ATPIPR+L+M++  +RD+S++  P
Sbjct  702   CKNLGLIIIDEEQRFGVKEKEKLKEIRISVDCLALSATPIPRSLHMSLIKLRDISVLKIP  761

Query  780   PARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVPEARIA  839
             P  R+ ++ ++  +  L+++ AI  E+ R GQV+ + +++E +      +  L P ARIA
Sbjct  762   PQNRVKIEAYLESFSELLIKHAIESELSRDGQVFLVNHNIEELYYLKTLIERLTPYARIA  821

Query  840   IGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQL  899
             I HG++   E+E +M++F  + + +L+ TTIIE GIDIP ANTIII  A+ FGLAQL+QL
Sbjct  822   IIHGKLTGEEIENIMHNFIKKAYQILLATTIIENGIDIPNANTIIINNANKFGLAQLYQL  881

Query  900   RGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELL  959
             +GRVGR   +AYA+ L    + +   + +RL AI    +LGAGF +A  D+EIRG G LL
Sbjct  882   KGRVGRGSQKAYAYFLYQDSEKLNERSIERLRAITEFSELGAGFKIAMKDMEIRGVGNLL  941

Query  960   GEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSLLPDDFIPD  1019
             G EQ G +E+IG   Y+ +L  A++  K G+  S E    ++ ++++     +P+++  +
Sbjct  942   GREQHGEIESIGLDYYLTMLNKAIEK-KMGKISSDE----EEVDIKINYSGFIPENYAKN  996

Query  1020  VNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQQAQKLGIRKLE  1079
                ++  YK+I   +TE E ++I+ EL + FG +P+   +LL +A L+  A+ L I KL+
Sbjct  997   EQDKILIYKKIFKIQTEEESKKIRSELHNDFGPIPEEINSLLMLAELKILAKDLNITKLK  1056

Query  1080  GNEKGGVIEFAEKNHVNPAWLIGLLQKQPQ  1109
                +   IE+     +    +I +LQK P 
Sbjct  1057  EKNRALEIEYKNIESIPMEKIIEILQKHPN  1086


>P64327.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
 P9WMQ4.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
 P9WMQ5.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1234

 Score = 575 bits (1481),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 313/667 (47%), Positives = 425/667 (64%), Gaps = 21/667 (3%)

Query  425   LMIGAAEHGFVDTVRNLALICESDLLGERVARRRQDSRRAINPDTLIRNLAELHIGQPVV  484
             ++ G    G +    NL +I E+DL G RV+   +  R A     ++  LA L  G  VV
Sbjct  468   VLQGPLRDGVIIPGANLVVITETDLTGSRVSAA-EGKRLAAKRRNIVDPLA-LTAGDLVV  525

Query  485   HLEHGVGRYAGMTTLEAGGITGEYLMLTYA---------NDAKLYVPVSSLHLISRYAGG  535
             H +HG+GR+  M     GG   EYL+L YA         N  KLYVP+ SL  +SRY GG
Sbjct  526   HDQHGIGRFVEMVERTVGGARREYLVLEYASAKRGGGAKNTDKLYVPMDSLDQLSRYVGG  585

Query  536   AEENAP-LHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLFC  594
                 AP L +LGG  W+  + KA   VR++A EL+ +YA+R A  G AF  D        
Sbjct  586   ---QAPALSRLGGSDWANTKTKARRAVREIAGELVSLYAKRQASPGHAFSPDTPWQAELE  642

Query  595   DSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAV  654
             D+F F  T DQ  AI  V +DM +P+ MDR++CGDVG+GKTE+A+RAAF AV + KQVAV
Sbjct  643   DAFGFTETVDQLTAIEEVKADMEKPIPMDRVICGDVGYGKTEIAVRAAFKAVQDGKQVAV  702

Query  655   LVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLL  714
             LVPTTLLA QH   F +R + +PV I+ +SRF  A E   ++  +A+G +DI+IGTH+LL
Sbjct  703   LVPTTLLADQHLQTFGERMSGFPVTIKGLSRFTDAAESRAVIDGLADGSVDIVIGTHRLL  762

Query  715   QSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLS  774
             Q+ V++KDLGL++VDEE RFGV HKE IK++R +VD+LT++ATPIPRTL M+++G+R++S
Sbjct  763   QTGVRWKDLGLVVVDEEQRFGVEHKEHIKSLRTHVDVLTMSATPIPRTLEMSLAGIREMS  822

Query  775   IIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAELVP  834
              I TPP  R  V T+V  +D   +  A+ RE+LR GQ +Y++N V +I  AA R+ ELVP
Sbjct  823   TILTPPEERYPVLTYVGPHDDKQIAAALRRELLRDGQAFYVHNRVSSIDAAAARVRELVP  882

Query  835   EARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLA  894
             EAR+ + HGQM E  LE  +  F ++  ++LVCTTI+ETG+DI  ANT+I+ERAD FGL+
Sbjct  883   EARVVVAHGQMPEDLLETTVQRFWNREHDILVCTTIVETGLDISNANTLIVERADTFGLS  942

Query  895   QLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRG  954
             QLHQLRGRVGRS  + YA+ L P    +T  A  RL  IA   +LGAG A+A  DLEIRG
Sbjct  943   QLHQLRGRVGRSRERGYAYFLYPPQVPLTETAYDRLATIAQNNELGAGMAVALKDLEIRG  1002

Query  955   AGELLGEEQSGSMETIGFSLYMEL----LENAVDALKAGREPSLEDLTSQQTEVELRMP-  1009
             AG +LG EQSG +  +GF LY+ L    LE   DA +A  +        +  +V + +P 
Sbjct  1003  AGNVLGIEQSGHVAGVGFDLYVRLVGEALETYRDAYRAAADGQTVRTAEEPKDVRIDLPV  1062

Query  1010  -SLLPDDFIPDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPDPARTLLDIARLRQ  1068
              + LP D+I     RL  Y+R+A+A ++ E+  +  EL DR+G LP+PAR L  +ARLR 
Sbjct  1063  DAHLPPDYIASDRLRLEGYRRLAAASSDREVAAVVDELTDRYGALPEPARRLAAVARLRL  1122

Query  1069  QAQKLGI  1075
               +  GI
Sbjct  1123  LCRGSGI  1129


>Q9ZJ57.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=1001

 Score = 468 bits (1203),  Expect = 5e-146, Method: Compositional matrix adjust.
 Identities = 242/623 (39%), Positives = 386/623 (62%), Gaps = 16/623 (3%)

Query  456   RRRQDSRRAINPDTLIRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYAN  515
             ++RQ S+ A+N         EL+ G+ VVH ++GVG ++ +      G   ++L + Y  
Sbjct  349   KKRQKSKLALN---------ELNAGEWVVHDDYGVGVFSQLIQHSVLGSKRDFLEIAYLG  399

Query  516   DAKLYVPVSSLHLISRYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQR  575
             + KL +PV +LHLI+RY   ++      +LG  ++ + + K   K+ ++A +++++ A+R
Sbjct  400   EDKLLLPVENLHLIARYVVQSDSVPVKDRLGKGSFLKLKAKVRAKLLEIAGKIIELAAER  459

Query  576   AAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKT  635
                 G        + ++F     FE T DQ +AI  +  D+     MDRL+ GDVGFGKT
Sbjct  460   NLILGKKMDTHLAELEIFKSHAGFEYTSDQEKAIAEISRDLSSHRVMDRLLSGDVGFGKT  519

Query  636   EVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQI  695
             EVAM A F A  N  Q A++VPTTLLA QH++  + RF N+ V++  + R+    E++++
Sbjct  520   EVAMHAIFCAFLNGFQSALVVPTTLLAHQHFETLKARFENFGVKVARLDRYIKTSEKSKL  579

Query  696   LAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLT  755
             L  V  G +D+LIGTH +L +  KFK+LGL++VDEEH+FGV+ KE +K +  +V  L+++
Sbjct  580   LKAVELGLVDVLIGTHAILGT--KFKNLGLMVVDEEHKFGVKQKEALKELSKSVHFLSMS  637

Query  756   ATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYL  815
             ATPIPRTLNMA+S ++ +S + TPP  R   +TF++E +  +++E I RE+ R GQ++Y+
Sbjct  638   ATPIPRTLNMALSQIKGISSLKTPPTDRKPSRTFLKEKNDELLKEIIYRELRRNGQIFYI  697

Query  816   YNDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGI  875
             +N + +I K   +L +L+P+ +IAI H Q+   E E +M +F    + VL+CT+I+E+GI
Sbjct  698   HNHIASISKVKTKLEDLIPKLKIAILHSQINANESEEIMLEFAKGNYQVLLCTSIVESGI  757

Query  876   DIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIAS  935
              +P ANTIII+ A +FGLA LHQLRGRVGR   + + + L    K++   A KRL A+  
Sbjct  758   HLPNANTIIIDNAQNFGLADLHQLRGRVGRGKKEGFCYFLIEDQKSLNEQALKRLLALEK  817

Query  936   LEDLGAGFALATHDLEIRGAGELLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLE  995
                LG+G ++A HDLEIRG G LLG++QSG ++ IG++LY  +LE+A+  L  G++    
Sbjct  818   NSYLGSGESIAYHDLEIRGGGNLLGQDQSGHIKNIGYALYTRMLEDAIYELSGGKKR---  874

Query  996   DLTSQQTEVELRMPSLLPDDFIPDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPD  1055
                 +  E++L + + L  + I   + RL  Y+R++  +  +E+ +I  E+ DRFG + D
Sbjct  875   --LEKSVEIQLGVSAFLNPELIASDSLRLDLYRRLSLCENVDEVGQIHEEIEDRFGKMDD  932

Query  1056  PARTLLDIARLRQQAQKLGIRKL  1078
              +   L I  L+  A +LGI KL
Sbjct  933   LSAQFLQIITLKILANQLGILKL  955


>O26066.1 RecName: Full=Transcription-repair-coupling factor; Short=TRCF
Length=999

 Score = 466 bits (1199),  Expect = 2e-145, Method: Compositional matrix adjust.
 Identities = 245/637 (38%), Positives = 393/637 (62%), Gaps = 18/637 (3%)

Query  456   RRRQDSRRAINPDTLIRNLAELHIGQPVVHLEHGVGRYAGMTTLEAGGITGEYLMLTYAN  515
             ++RQ S+ A+N         EL+ G+ VVH ++GVG ++ +      G   ++L + Y  
Sbjct  349   KKRQKSKLALN---------ELNPGEWVVHDDYGVGVFSQLVQHSVLGSKRDFLEIAYLG  399

Query  516   DAKLYVPVSSLHLISRYAGGAEENAPLHKLGGDAWSRARQKAAEKVRDVAAELLDIYAQR  575
             + KL +PV +LHLI+RY   ++      +LG  ++ + + K   K+ ++A++++++ A+R
Sbjct  400   EDKLLLPVENLHLIARYVAQSDSVPAKDRLGKGSFLKLKAKVRTKLLEIASKIIELAAER  459

Query  576   AAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKT  635
                 G        + ++F     FE T DQ +AI  +  D+     MDRL+ GDVGFGKT
Sbjct  460   NLILGKKMDVHLAELEVFKSHAGFEYTSDQEKAIAEISKDLSSHRVMDRLLSGDVGFGKT  519

Query  636   EVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQI  695
             EVAM A F A  N  Q A++VPTTLLA QH++  R RF N+ V++  + R+  A E+ ++
Sbjct  520   EVAMHAIFCAFLNGFQSALVVPTTLLAHQHFETLRARFENFGVKVARLDRY--ASEKNKL  577

Query  696   LAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLT  755
             L  V  G++D LIGTH +L +  KFK+LGL++VDEEH+FGV+ KE +K +  +V  L+++
Sbjct  578   LKAVELGQVDALIGTHAILGA--KFKNLGLVVVDEEHKFGVKQKEALKELSKSVHFLSMS  635

Query  756   ATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYL  815
             ATPIPRTLNMA+S ++ +S + TPP  R   +TF++E +  +++E I RE+ R GQ++Y+
Sbjct  636   ATPIPRTLNMALSQIKGISSLKTPPTDRKPSRTFLKEKNDELLKEIIYRELRRNGQIFYI  695

Query  816   YNDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGI  875
             +N + +I K   +L +L+P+ +IAI H Q+   E E +M +F    + VL+CT+I+E+GI
Sbjct  696   HNHIASILKVKTKLEDLIPKLKIAILHSQINANESEEIMLEFAKGNYQVLLCTSIVESGI  755

Query  876   DIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIAS  935
              +P ANTIII+ A +FGLA LHQLRGRVGR   + + + L    K++   A KRL A+  
Sbjct  756   HLPNANTIIIDNAQNFGLADLHQLRGRVGRGKKEGFCYFLIEDQKSLNEQALKRLLALEK  815

Query  936   LEDLGAGFALATHDLEIRGAGELLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLE  995
                LG+G ++A HDLEIRG G LLG++QSG ++ IG++LY  +LE+A+  L  G++    
Sbjct  816   NSYLGSGESVAYHDLEIRGGGNLLGQDQSGHIKNIGYALYTRMLEDAIYELSGGKKR---  872

Query  996   DLTSQQTEVELRMPSLLPDDFIPDVNTRLSFYKRIASAKTENELEEIKVELIDRFGLLPD  1055
                 +  E++L + + L  + I   + RL  Y+R++  +  +E+ +I  E+ DRFG + D
Sbjct  873   --LEKSVEIQLGVSAFLNPELIASDSLRLDLYRRLSLCENTDEVGQIHEEIEDRFGKIDD  930

Query  1056  PARTLLDIARLRQQAQKLGIRKLEGNEKGGVIEFAEK  1092
              +   L I  L+  A +LGI KL    +   I ++++
Sbjct  931   LSAQFLQIITLKILANQLGIIKLSNFNQNITITYSDE  967


>F4JFJ3.1 RecName: Full=ATP-dependent DNA helicase At3g02060, chloroplastic; 
Flags: Precursor
Length=823

 Score = 400 bits (1027),  Expect = 2e-122, Method: Compositional matrix adjust.
 Identities = 222/619 (36%), Positives = 358/619 (58%), Gaps = 15/619 (2%)

Query  480   GQPVVHLEHGVGRYAGMT--TLEAGGITGEYLMLTYAND-AKLYVPVSSLHLISRYAGGA  536
             G  VVH + G+GR+ G+     +      EY+ + YA+  AKL +  +S  L+ RY    
Sbjct  145   GDYVVHKKVGIGRFVGIKFDVPKDSSEPLEYVFIEYADGMAKLPLKQAS-RLLYRYNLPN  203

Query  537   EENAP--LHKLGGDA-WSRARQKAAEKVRDVAAELLDIYAQRAAKEGFAFKHDREQYQLF  593
             E   P  L +L   + W R + K    ++ +  +L+++Y  R  ++ + +  +      F
Sbjct  204   ETKRPRTLSRLSDTSVWERRKTKGKVAIQKMVVDLMELYLHRLRQKRYPYPKNPIMAD-F  262

Query  594   CDSFPFETTPDQAQAINAVLSDMCQ-PLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQV  652
                FP+  TPDQ QA   V  D+ +    MDRL+CGDVGFGKTEVA+RA F  V   KQ 
Sbjct  263   AAQFPYNATPDQKQAFLDVEKDLTERETPMDRLICGDVGFGKTEVALRAIFCVVSTGKQA  322

Query  653   AVLVPTTLLAQQHYDNFRDRFANWP-VRIEMISRFRSAKEQTQILAEVAEGKIDILIGTH  711
              VL PT +LA+QHYD   +RF+ +P +++ ++SRF++  E+ + L  +  G ++I++GTH
Sbjct  323   MVLAPTIVLAKQHYDVISERFSLYPHIKVGLLSRFQTKAEKEEYLEMIKTGHLNIIVGTH  382

Query  712   KLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMR  771
              LL S V + +LGLL+VDEE RFGV+ KE+I + + +VD+LTL+ATPIPRTL +A++G R
Sbjct  383   SLLGSRVVYSNLGLLVVDEEQRFGVKQKEKIASFKTSVDVLTLSATPIPRTLYLALTGFR  442

Query  772   DLSIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVENIQKAAERLAE  831
             D S+I+TPP  R+ +KT +  +    V EAI  E+ RGGQV+Y+   ++ +++  + L E
Sbjct  443   DASLISTPPPERIPIKTHLSSFRKEKVIEAIKNELDRGGQVFYVLPRIKGLEEVMDFLEE  502

Query  832   LVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHF  891
               P+  IA+ HG+   ++LE  M  F   +  +L+CT I+E+G+DI  ANTIII+    F
Sbjct  503   AFPDIDIAMAHGKQYSKQLEETMERFAQGKIKILICTNIVESGLDIQNANTIIIQDVQQF  562

Query  892   GLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLE  951
             GLAQL+QLRGRVGR+  +A+A+L  P    ++  A +RL A+    +LG GF LA  D+ 
Sbjct  563   GLAQLYQLRGRVGRADKEAHAYLFYPDKSLLSDQALERLSALEECRELGQGFQLAEKDMG  622

Query  952   IRGAGELLGEEQSGSMETIGFSLYMELLENAVDALKAGREPSLEDLTSQQTEVELRMPSL  1011
             IRG G + GE+Q+G +  +G  L+ E+L    ++L    E  +  +     ++++ +   
Sbjct  623   IRGFGTIFGEQQTGDVGNVGIDLFFEML---FESLSKVEELRIFSVPYDLVKIDININPR  679

Query  1012  LPDDFIPDVNTRLSFYKRIASAKTEN--ELEEIKVELIDRFGLLPDPARTLLDIARLRQQ  1069
             LP +++  +   +        A  ++   L +    L  ++G  P     +L    +R+ 
Sbjct  680   LPSEYVNYLENPMEIIHEAEKAAEKDMWSLMQFTENLRRQYGKEPYSMEIILKKLYVRRM  739

Query  1070  AQKLGIRKLEGNEKGGVIE  1088
             A  LG+ ++  + K  V++
Sbjct  740   AADLGVNRIYASGKMVVMK  758


>Q54900.2 RecName: Full=ATP-dependent DNA helicase RecG
Length=671

 Score = 265 bits (676),  Expect = 7e-75, Method: Compositional matrix adjust.
 Identities = 153/401 (38%), Positives = 237/401 (59%), Gaps = 18/401 (4%)

Query  575  RAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGK  634
            R    G      +E+      S PF  T  Q +++  +L+DM     M+RL+ GDVG GK
Sbjct  227  RVQGSGLVLNWSQEKVTAVKVSLPFALTQAQEKSLQEILTDMKSDHHMNRLLQGDVGSGK  286

Query  635  TEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQ  694
            T VA  A F AV    Q A++VPT +LA+QH+++ ++ F N  +++ +++    A E+ +
Sbjct  287  TVVAGLAMFAAVTAGYQAALMVPTEILAEQHFESLQNLFPN--LKLALLTGSLKAAEKRE  344

Query  695  ILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTL  754
            +L  +A+G+ D++IGTH L+Q  V++  LGL+I+DE+HRFGV  +  ++    N D+L +
Sbjct  345  VLETIAKGEADLIIGTHALIQDGVEYARLGLIIIDEQHRFGVGQRRILREKGDNPDVLMM  404

Query  755  TATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFVREYDSL-VVREAILREILRGGQVY  813
            TATPIPRTL +   G  D+SII   PA R  + T   +++ L  V   +  EI +G QVY
Sbjct  405  TATPIPRTLAITAFGDMDVSIIDQMPAGRKPIVTRWIKHEQLPQVLTWLEGEIQKGSQVY  464

Query  814  YLYN--------DVENIQKAAERL-AELVPEARIAIGHGQMRERELERVMNDFHHQRFNV  864
             +          D++N    +E L      +A +A+ HG+M+  E +++M DF  ++ ++
Sbjct  465  VISPLIEESEALDLKNAIALSEELTTHFAGKAEVALLHGRMKSDEKDQIMQDFKERKTDI  524

Query  865  LVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTT  924
            LV TT+IE G+++P A  +II  AD FGL+QLHQLRGRVGR   Q+YA +L  +PK  T 
Sbjct  525  LVSTTVIEVGVNVPNATVMIIMDADRFGLSQLHQLRGRVGRGDKQSYA-VLVANPK--TD  581

Query  925  DAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSG  965
              + R+  +    +   GF LA  DL++RG+GE+ G  QSG
Sbjct  582  SGKDRMRIMTETTN---GFVLAEEDLKMRGSGEIFGTRQSG  619


>Q55681.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=831

 Score = 266 bits (681),  Expect = 3e-74, Method: Compositional matrix adjust.
 Identities = 145/404 (36%), Positives = 234/404 (58%), Gaps = 16/404 (4%)

Query  572  YAQRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVG  631
            Y Q+  ++   F    E  + F D  PF  T  Q + +N +L D+ +P  M+RLV GDVG
Sbjct  377  YEQKQQQQSAIFTPHGELLEKFSDLLPFRLTQAQQRVVNEILQDLNKPSPMNRLVQGDVG  436

Query  632  FGKTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKE  691
             GKT V + A   A+    Q A++ PT +LA+QHY      F    + +E+++      +
Sbjct  437  SGKTVVGVFAILAALQGGYQAALMAPTEVLAEQHYQKLVSWFNLLYLPVELLTGSTKTAK  496

Query  692  QTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDI  751
            + +I A+++ G++ +L+GTH L+Q  V F+ LGL+++DE+HRFGV+ + ++ A      +
Sbjct  497  RREIHAQLSTGQLPLLVGTHALIQETVNFQRLGLVVIDEQHRFGVQQRAKLLAKGNAPHV  556

Query  752  LTLTATPIPRTLNMAMSGMRDLSII-ATPPARRLAVKTFVREYDSLVVREAILREILRGG  810
            L++TATPIPRTL + + G  ++S I   PP R+    + +   +   + E I RE+ +G 
Sbjct  557  LSMTATPIPRTLALTLHGDLEVSQIDELPPGRQPIHTSVITAKERPQMYELIRREVAQGR  616

Query  811  QVYYLYNDVENIQKAAERLA---------ELVPEARIAIGHGQMRERELERVMNDFHHQR  861
            QVY ++  +E  +K   + A         ++ P   I + HG+++  E E  +  F  ++
Sbjct  617  QVYIIFPAIEESEKLDIKAAVEEHKYLTEKIFPNFNIGLLHGRLKSAEKEAALTAFREKQ  676

Query  862  FNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKA  921
              ++V TT+IE G+D+P A  ++IE A+ FGL+QLHQLRGRVGR  HQ+Y  L+T    +
Sbjct  677  TEIIVSTTVIEVGVDVPNATVMVIENAERFGLSQLHQLRGRVGRGSHQSYCLLVT---NS  733

Query  922  MTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSG  965
             + DA++RL  +   +D   GF +A  DL +RG GE LG +QSG
Sbjct  734  KSNDARQRLGVMEQSQD---GFFIAEMDLRLRGPGEFLGTKQSG  774


>O34942.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=682

 Score = 263 bits (672),  Expect = 3e-74, Method: Compositional matrix adjust.
 Identities = 147/403 (36%), Positives = 239/403 (59%), Gaps = 16/403 (4%)

Query  573  AQRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGF  632
            A+R   +G   +   E+   F  S PF  T  Q++ +  + +DM  P  M+RL+ GDVG 
Sbjct  229  AEREQTQGIRQRFSNEELMRFIKSLPFPLTNAQSRVLREITADMSSPYRMNRLLQGDVGS  288

Query  633  GKTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQ  692
            GKT VA  A + A+ +  Q A++VPT +LA+QH D+    F  W V + +++     K +
Sbjct  289  GKTAVAAIALYAAILSGYQGALMVPTEILAEQHADSLVSLFEKWDVSVALLTSSVKGKRR  348

Query  693  TQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDIL  752
             ++L  +A G+IDIL+GTH L+Q +V+FK L L+I DE+HRFGV  +++++    + D+L
Sbjct  349  KELLERLAAGEIDILVGTHALIQDEVEFKALSLVITDEQHRFGVEQRKKLRNKGQDPDVL  408

Query  753  TLTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFVREYDSL-VVREAILREILRGGQ  811
             +TATPIPRTL + + G  D+S+I   PA R  ++T+  ++D L  +   + +E+ +G Q
Sbjct  409  FMTATPIPRTLAITVFGEMDVSVIDEMPAGRKRIETYWVKHDMLDRILAFVEKELKQGRQ  468

Query  812  VYYLYN--------DVENIQKAAERLAELV-PEARIAIGHGQMRERELERVMNDFHHQRF  862
             Y +          DV+N       L+++   +  + + HG++   E ++VM +F     
Sbjct  469  AYIICPLIEESDKLDVQNAIDVYNMLSDIFRGKWNVGLMHGKLHSDEKDQVMREFSANHC  528

Query  863  NVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAM  922
             +LV TT++E G+++P A  ++I  AD FGL+QLHQLRGRVGR  HQ++  +L   PK+ 
Sbjct  529  QILVSTTVVEVGVNVPNATIMVIYDADRFGLSQLHQLRGRVGRGEHQSFC-ILMADPKSE  587

Query  923  TTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSG  965
            T   ++R+  ++   D   GF L+  DLE+RG G+  G++QSG
Sbjct  588  T--GKERMRIMSETND---GFELSEKDLELRGPGDFFGKKQSG  625


>O67837.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=792

 Score = 264 bits (675),  Expect = 1e-73, Method: Compositional matrix adjust.
 Identities = 149/386 (39%), Positives = 229/386 (59%), Gaps = 20/386 (5%)

Query  594  CDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVA  653
             +  PF+ T  Q +AI  +L D+ + + M+RL+ GDVG GKT VA+  +   V +  QVA
Sbjct  354  IEKLPFKLTRAQERAIKEILEDLSRDVPMNRLLQGDVGSGKTIVAILTSLAVVKSGYQVA  413

Query  654  VLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKL  713
            V+VPT +LA QHY  F +   ++ V + +++   +  ++  +   V EG I +L+GTH L
Sbjct  414  VMVPTEILAHQHYKKFSEMLKDYGVNVALLTGSLTPSQKKSVYKHVKEGNIHVLVGTHAL  473

Query  714  LQSDVKFKDLGLLIVDEEHRFGVRHK----ERIKAMRANVDILTLTATPIPRTLNMAMSG  769
            +Q  V+FK+LG +I+DE+HRFGV  +    E+ K +  +   L ++ATPIPRTL +++ G
Sbjct  474  IQDKVEFKNLGYVIIDEQHRFGVMQRKLLLEKGKGLYPHC--LVMSATPIPRTLALSIYG  531

Query  770  MRDLSII-ATPPARRLAVKTFVREYDSLVVREAILREILRGGQVYYLYNDVE-----NIQ  823
              D+SII   PP R+  +     E     V + +  E+ +G +VY +Y  +E     N++
Sbjct  532  DLDISIIDELPPGRKEVITKLYFESQKEEVYKKVEEELKKGNKVYVIYPLIEESEKLNLK  591

Query  824  KAA---ERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTA  880
             A    ER  +L P+ ++ + HG+M ++E   VM +F  +  ++LV TT+IE GID+P A
Sbjct  592  AATEEYERWKKLFPDRKVLLLHGKMPDKEKLAVMEEFKREG-DILVSTTVIEVGIDVPEA  650

Query  881  NTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHP-KAMTTDAQKRLEAIASLEDL  939
              ++IE A  FGL+QLHQLRGRVGRS  +AY  L+ P   K    ++ KRL       D 
Sbjct  651  TVMVIEDAHRFGLSQLHQLRGRVGRSDKEAYCLLVVPDEIKNEKNESLKRLRVFVKTTD-  709

Query  940  GAGFALATHDLEIRGAGELLGEEQSG  965
              GF +A  DL++RG GE++G  QSG
Sbjct  710  --GFKIAEEDLKLRGPGEIIGVSQSG  733


>O51528.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=686

 Score = 258 bits (659),  Expect = 2e-72, Method: Compositional matrix adjust.
 Identities = 142/413 (34%), Positives = 240/413 (58%), Gaps = 17/413 (4%)

Query  568  LLDIYAQ-RAAKEGFAFKHD--REQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDR  624
            LL  +++ R++K  F  K D  ++  +    S PFE T DQ  +I+ +  D+     M+R
Sbjct  227  LLQFFSRYRSSKILFREKKDLSKDLLEKVVSSLPFELTEDQKISIDEIFFDLNSSKPMNR  286

Query  625  LVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMIS  684
            L+ GDVG GKT VA+ +    ++   QVA + PT LLA+QHYDN  +  A + + + +++
Sbjct  287  LLQGDVGSGKTLVALLSGLPLIEAGYQVAFMAPTDLLARQHYDNLSNILAPFNISMTLLT  346

Query  685  RFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKA  744
                 K++ Q L  +  G   +++GTH +     +FK L  +I+DE+H+FGV  +E +K 
Sbjct  347  GSLRKKDKEQALESIRNGTSGLIVGTHAIFYESTEFKRLAYVIIDEQHKFGVVQREELKN  406

Query  745  MRANVDILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFV-REYDSLVVREAIL  803
                VD+L ++ATPIPR+  + + G  ++S I T P  RL + T++ R  +   V E + 
Sbjct  407  KGEGVDMLLMSATPIPRSFALTLFGDLEVSFIKTLPKGRLPITTYLARHGNEDKVYEFLR  466

Query  804  REILRGGQVYYLY--------NDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMN  855
            +E+L+G QVY++Y         +++++     +L E+  E  + + H ++     E +M 
Sbjct  467  KELLKGHQVYFVYPLISSSEKFELKDVNNMCLKLKEVFGEYVVDMLHSKLPSDLKEEIMK  526

Query  856  DFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLL  915
            +F+ ++ ++LV T++IE GID P A  +++E A+ FGL+ LHQ+RGRVGRS+ Q++ +LL
Sbjct  527  NFYSKKVDILVATSVIEVGIDCPNATCMVVEHAERFGLSTLHQIRGRVGRSNLQSFFFLL  586

Query  916  TPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSGSME  968
               P  +T+  + RL+ I    D   GF +A  DL +RG G L G EQ+G ++
Sbjct  587  YKEP--LTSAGKFRLKTIKENLD---GFKIAEEDLRLRGPGNLFGLEQAGYLK  634


>O50581.1 RecName: Full=ATP-dependent DNA helicase RecG
 Q5HGK6.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=686

 Score = 255 bits (651),  Expect = 3e-71, Method: Compositional matrix adjust.
 Identities = 143/404 (35%), Positives = 230/404 (57%), Gaps = 21/404 (5%)

Query  574  QRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFG  633
            ++++ E     +D +Q + F D  PFE T  Q  ++N +  D+  P+ M RL+ GDVG G
Sbjct  238  EKSSDEAIEIDYDIDQVKSFIDRLPFELTEAQKSSVNEIFRDLKAPIRMHRLLQGDVGSG  297

Query  634  KTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQT  693
            KT VA    +       Q A++VPT +LA+QH ++    F +  + + +++     K++ 
Sbjct  298  KTVVAAICMYALKTAGYQSALMVPTEILAEQHAESLMALFGD-SMNVALLTGSVKGKKRK  356

Query  694  QILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILT  753
             +L ++  G ID LIGTH L+Q DV F ++GL+I DE+HRFGV  ++ ++   A  ++L 
Sbjct  357  ILLEQLENGTIDCLIGTHALIQDDVIFHNVGLVITDEQHRFGVNQRQLLREKGAMTNVLF  416

Query  754  LTATPIPRTLNMAMSGMRDLSIIAT-PPARRLAVKTFVR--EYDSLVVREAILREILRGG  810
            +TATPIPRTL +++ G  D+S I   P  R+  + T+ +  +YD ++++  +  E+ +G 
Sbjct  417  MTATPIPRTLAISVFGEMDVSSIKQLPKGRKPIITTWAKHEQYDKVLMQ--MTSELKKGR  474

Query  811  QVYYL---------YNDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQR  861
            Q Y +           DV+N+    E L +    +R+ + HG++   E + VM  F +  
Sbjct  475  QAYVICPLIESSEHLEDVQNVVALYESLQQYYGVSRVGLLHGKLSADEKDEVMQKFSNHE  534

Query  862  FNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKA  921
             NVLV TT++E G+++P A  ++I  AD FGL+ LHQLRGRVGRS  Q+Y  L+   PK 
Sbjct  535  INVLVSTTVVEVGVNVPNATFMMIYDADRFGLSTLHQLRGRVGRSDQQSYCVLIAS-PKT  593

Query  922  MTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSG  965
             T      +E +  +     GF L+  DLE+RG G+  G +QSG
Sbjct  594  ETG-----IERMTIMTQTTDGFELSERDLEMRGPGDFFGVKQSG  632


>Q5HPW4.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=682

 Score = 254 bits (649),  Expect = 4e-71, Method: Compositional matrix adjust.
 Identities = 143/404 (35%), Positives = 226/404 (56%), Gaps = 21/404 (5%)

Query  574  QRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFG  633
            ++ + E     +D  + + F DS PFE T  Q  ++N +  D+  P+ M RL+ GDVG G
Sbjct  234  EKTSDEAIEINYDINKVKQFIDSLPFELTDAQKVSVNEIFRDLKAPIRMHRLLQGDVGSG  293

Query  634  KTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQT  693
            KT VA    +       Q A++VPT +LA+QH ++    F N  + + +++     K++ 
Sbjct  294  KTIVAAICMYALKTAGYQSALMVPTEILAEQHAESLMQLFGN-TMNVALLTGSVKGKKRR  352

Query  694  QILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILT  753
             +L ++  G ID LIGTH L+Q DV F ++GL+I DE+HRFGV  ++ ++   A  ++L 
Sbjct  353  LLLEQLENGTIDCLIGTHALIQDDVVFNNVGLVITDEQHRFGVNQRQILREKGAMTNVLF  412

Query  754  LTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFV---REYDSLVVREAILREILRGG  810
            +TATPIPRTL +++ G  D+S I   P  R  +KT      +YD ++ + +   E+ +G 
Sbjct  413  MTATPIPRTLAISVFGEMDVSSIKQLPKGRKPIKTSWAKHEQYDQVLAQMS--NELKKGR  470

Query  811  QVYYL---------YNDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQR  861
            Q Y +           DV+N+ +  E L       ++ + HG+M   + ++VM  F    
Sbjct  471  QAYVICPLIESSEHLEDVQNVVELYESLQSDYGNEKVGLLHGKMTAEDKDQVMQKFSEHE  530

Query  862  FNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKA  921
             ++LV TT++E G+++P A  ++I  AD FGL+ LHQLRGRVGRS HQ+Y  L+   PK 
Sbjct  531  IDILVSTTVVEVGVNVPNATFMMIYDADRFGLSTLHQLRGRVGRSEHQSYCVLIAS-PKT  589

Query  922  MTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSG  965
             T      +E +  +     GF L+  DLE+RG G+  G +QSG
Sbjct  590  ETG-----IERMTIMTQTTDGFELSERDLEMRGPGDFFGVKQSG  628


>Q8CSV3.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=682

 Score = 254 bits (648),  Expect = 6e-71, Method: Compositional matrix adjust.
 Identities = 143/404 (35%), Positives = 225/404 (56%), Gaps = 21/404 (5%)

Query  574  QRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFG  633
            ++ + E     +D  + + F DS PFE T  Q  ++N +  D+  P+ M RL+ GDVG G
Sbjct  234  EKTSDEAIEINYDINKVKQFIDSLPFELTDAQKVSVNEIFRDLKAPIRMHRLLQGDVGSG  293

Query  634  KTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQT  693
            KT VA    +       Q A++VPT +LA+QH ++    F N  + + +++     K++ 
Sbjct  294  KTVVAAICMYALKTAGYQSALMVPTEILAEQHAESLIQLFGN-TMNVALLTGSVKGKKRR  352

Query  694  QILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILT  753
             +L ++  G ID LIGTH L+Q DV F ++GL+I DE+HRFGV  ++ ++   A  ++L 
Sbjct  353  LLLEQLENGTIDCLIGTHALIQDDVVFNNVGLVITDEQHRFGVNQRQILREKGAMTNVLF  412

Query  754  LTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFV---REYDSLVVREAILREILRGG  810
            +TATPIPRTL +++ G  D+S I   P  R  +KT      +YD ++ + +   E+ +G 
Sbjct  413  MTATPIPRTLAISVFGEMDVSSIKQLPKGRKPIKTSWAKHEQYDQVLAQMS--NELKKGR  470

Query  811  QVYYL---------YNDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQR  861
            Q Y +           DV+N+    E L       ++ + HG+M   + ++VM  F    
Sbjct  471  QAYVICPLIESSEHLEDVQNVVALYESLQSDYGNEKVGLLHGKMSAEDKDQVMQKFSKHE  530

Query  862  FNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKA  921
             ++LV TT++E G+++P A  ++I  AD FGL+ LHQLRGRVGRS HQ+Y  L+   PK 
Sbjct  531  IDILVSTTVVEVGVNVPNATFMMIYDADRFGLSTLHQLRGRVGRSEHQSYCVLIAS-PKT  589

Query  922  MTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSG  965
             T      +E +  +     GF L+  DLE+RG G+  G +QSG
Sbjct  590  ETG-----IERMTIMTQTTDGFELSERDLEMRGPGDFFGVKQSG  628


>P64325.1 RecName: Full=ATP-dependent DNA helicase RecG
 P64324.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=686

 Score = 253 bits (647),  Expect = 1e-70, Method: Compositional matrix adjust.
 Identities = 142/404 (35%), Positives = 230/404 (57%), Gaps = 21/404 (5%)

Query  574  QRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFG  633
            ++++ E     +D +Q + F D  PFE T  Q  ++N +  D+  P+ M RL+ GDVG G
Sbjct  238  EKSSDEAIEIDYDLDQVKSFIDRLPFELTEAQKSSVNEIFRDLKAPIRMHRLLQGDVGSG  297

Query  634  KTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQT  693
            KT VA    +       Q A++VPT +LA+QH ++    F +  + + +++     K++ 
Sbjct  298  KTVVAAICMYALKTAGYQSALMVPTEILAEQHAESLMALFGD-SMNVALLTGSVKGKKRK  356

Query  694  QILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILT  753
             +L ++  G ID LIGTH L+Q DV F ++GL+I DE+HRFGV  ++ ++   A  ++L 
Sbjct  357  ILLEQLENGTIDCLIGTHALIQDDVIFHNVGLVITDEQHRFGVNQRQLLREKGAMTNVLF  416

Query  754  LTATPIPRTLNMAMSGMRDLSIIAT-PPARRLAVKTFVR--EYDSLVVREAILREILRGG  810
            +TATPIPRTL +++ G  D+S I   P  R+  + T+ +  +YD ++++  +  E+ +G 
Sbjct  417  MTATPIPRTLAISVFGEMDVSSIKQLPKGRKPIITTWAKHEQYDKVLMQ--MTSELKKGR  474

Query  811  QVYYL---------YNDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQR  861
            Q Y +           DV+N+    E L +    +R+ + HG++   E + VM  F +  
Sbjct  475  QAYVICPLIESSEHLEDVQNVVALYESLQQYYGVSRVGLLHGKLSADEKDEVMQKFSNHE  534

Query  862  FNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKA  921
             +VLV TT++E G+++P A  ++I  AD FGL+ LHQLRGRVGRS  Q+Y  L+   PK 
Sbjct  535  IDVLVSTTVVEVGVNVPNATFMMIYDADRFGLSTLHQLRGRVGRSDQQSYCVLIAS-PKT  593

Query  922  MTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSG  965
             T      +E +  +     GF L+  DLE+RG G+  G +QSG
Sbjct  594  ETG-----IERMTIMTQTTDGFELSERDLEMRGPGDFFGVKQSG  632


>Q8NX11.1 RecName: Full=ATP-dependent DNA helicase RecG
 Q6G9Y6.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=686

 Score = 250 bits (639),  Expect = 1e-69, Method: Compositional matrix adjust.
 Identities = 141/404 (35%), Positives = 229/404 (57%), Gaps = 21/404 (5%)

Query  574  QRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFG  633
            ++++ E     +  +Q + F D  PFE T  Q  ++N +  D+  P+ M RL+ GDVG G
Sbjct  238  EKSSDEAIEIDYGLDQVKSFIDRLPFELTEAQKSSVNEIFRDLKAPIRMHRLLQGDVGSG  297

Query  634  KTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQT  693
            KT VA    +       Q A++VPT +LA+QH ++    F +  + + +++     K++ 
Sbjct  298  KTVVAAICMYALKTAGYQSALMVPTEILAEQHAESLMALFGD-SMNVALLTGSVKGKKRK  356

Query  694  QILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILT  753
             +L ++  G ID LIGTH L+Q DV F ++GL+I DE+HRFGV  ++ ++   A  ++L 
Sbjct  357  ILLEQLENGTIDCLIGTHALIQDDVIFHNVGLVITDEQHRFGVNQRQLLREKGAMTNVLF  416

Query  754  LTATPIPRTLNMAMSGMRDLSIIAT-PPARRLAVKTFVR--EYDSLVVREAILREILRGG  810
            +TATPIPRTL +++ G  D+S I   P  R+  + T+ +  +YD ++++  +  E+ +G 
Sbjct  417  MTATPIPRTLAISVFGEMDVSSIKQLPKGRKPIITTWAKHEQYDKVLMQ--MTSELKKGR  474

Query  811  QVYYL---------YNDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQR  861
            Q Y +           DV+N+    E L +    +R+ + HG++   E + VM  F +  
Sbjct  475  QAYVICPLIESSEHLEDVQNVVALYESLQQYYGVSRVGLLHGKLSADEKDEVMQKFSNHE  534

Query  862  FNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKA  921
             +VLV TT++E G+++P A  ++I  AD FGL+ LHQLRGRVGRS  Q+Y  L+   PK 
Sbjct  535  IDVLVSTTVVEVGVNVPNATFMMIYDADRFGLSTLHQLRGRVGRSDQQSYCVLIAS-PKT  593

Query  922  MTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSG  965
             T      +E +  +     GF L+  DLE+RG G+  G +QSG
Sbjct  594  ETG-----IERMTIMTQTTDGFELSERDLEMRGPGDFFGVKQSG  632


>Q6GHK8.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=686

 Score = 249 bits (636),  Expect = 3e-69, Method: Compositional matrix adjust.
 Identities = 141/404 (35%), Positives = 229/404 (57%), Gaps = 21/404 (5%)

Query  574  QRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFG  633
            ++++ E     +D +Q + F D  PFE T  Q  ++N +  D+  P+ M RL+ GDVG G
Sbjct  238  EKSSDEAIEIDYDLDQVKSFIDRLPFELTEAQKSSVNEIFRDLKAPIRMHRLLQGDVGSG  297

Query  634  KTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQT  693
            KT VA    +       Q A++VPT +LA+QH ++    F +  + + +++     K++ 
Sbjct  298  KTVVAAICMYALKTAGYQSALMVPTEILAEQHAESLIALFGD-SMNVALLTGSVKGKKRK  356

Query  694  QILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILT  753
             +L ++    ID LIGTH L+Q DV F ++GL+I DE+HRFGV  ++ ++   A  ++L 
Sbjct  357  ILLEQLENRTIDCLIGTHALIQDDVIFHNVGLVITDEQHRFGVNQRQLLREKGAMTNVLF  416

Query  754  LTATPIPRTLNMAMSGMRDLSIIAT-PPARRLAVKTFVR--EYDSLVVREAILREILRGG  810
            +TATPIPRTL +++ G  D+S I   P  R+  + T+ +  +YD ++++  +  E+ +G 
Sbjct  417  MTATPIPRTLAISVFGEMDVSSIKQLPKGRKPIITTWAKHEQYDKVLMQ--MTSELKKGR  474

Query  811  QVYYL---------YNDVENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQR  861
            Q Y +           DV+N+    E L +    +R+ + HG++   E + VM  F +  
Sbjct  475  QAYVICPLIESSEHLEDVQNVVALYESLQQYYGVSRVGLLHGKLSADEKDEVMQKFSNHE  534

Query  862  FNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKA  921
             +VLV TT++E G+++P A  ++I  AD FGL+ LHQLRGRVGRS  Q+Y  L+   PK 
Sbjct  535  IDVLVSTTVVEVGVNVPNATFMMIYDADRFGLSTLHQLRGRVGRSDQQSYCVLIAS-PKT  593

Query  922  MTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSG  965
             T      +E +  +     GF L+  DLE+RG G+  G +QSG
Sbjct  594  ETG-----IERMTIMTQTTDGFELSERDLEMRGPGDFFGVKQSG  632


>P96130.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=686

 Score = 241 bits (615),  Expect = 2e-66, Method: Compositional matrix adjust.
 Identities = 152/432 (35%), Positives = 239/432 (55%), Gaps = 31/432 (7%)

Query  596   SFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVL  655
               PFE T DQ + I  +  D+ +   M RL+ GDVG GKT VA  +    ++   QVA+L
Sbjct  266   CLPFELTVDQKRVITEITQDLEREEPMARLIQGDVGSGKTLVAFFSCLKIIEQGGQVALL  325

Query  656   VPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQ  715
              PT LLA+QH D      A   +R+  ++    ++ +  +L  +  G+I++++GTH L  
Sbjct  326   APTELLARQHADTAARLLAPIGIRLAFLTGNVKSEGRAYLLEALVAGEINLVVGTHALFS  385

Query  716   SDVKFKDLGLLIVDEEHRFGVRHKERI--KAMRANVD-----ILTLTATPIPRTLNMAMS  768
               V++ DL L+I+DE+HRFGV  +  +  K    N       I+ ++ATPIPRTL +++ 
Sbjct  386   KSVRYHDLRLVIIDEQHRFGVLQRSALIQKGREGNPQGKTPHIIMMSATPIPRTLALSVF  445

Query  769   GMRDLSIIATPPARRLAVKTFV-REYDSLVVREAILREILRGGQVYYLY--------NDV  819
             G  D+SII + P  R  V T++ R+  +  V E +  EI +G Q Y++Y         D+
Sbjct  446   GDLDISIIKSMPGGRKPVITYIARKTKAEKVYEFVGNEIEKGRQAYFIYPRIHDIGLTDL  505

Query  820   ENIQKAAERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPT  879
             +++Q     L        +A+ H +M E E +R+M  F     ++LV T+++E G+D+P 
Sbjct  506   KSVQCMYMYLKNYFARYAVAMIHSKMTEEEQQRIMKYFSEGTVHILVATSVVEVGVDVPN  565

Query  880   ANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDL  939
             AN I+IE A+ FGL+ LHQLRGRVGR   Q+Y +L+  H   MT  A++RL+ + S  D 
Sbjct  566   ANCIVIEHAERFGLSALHQLRGRVGRGDVQSYCFLM--HGDEMTECAKRRLKIMGSTAD-  622

Query  940   GAGFALATHDLEIRGAGELLGE----EQSGSMETIGFSLYMELLENAVDALKAGREPSLE  995
               GF +A  DL++RG G+ +G+    EQSG     GF +   + +  +  L+  RE + E
Sbjct  623   --GFVIAEEDLKLRGPGD-VGDTKNFEQSGYS---GFRVADPVRDYPI--LQVAREAAFE  674

Query  996   DLTSQQTEVELR  1007
              L  ++   E R
Sbjct  675   LLRKEKGSSEAR  686


>Q9CMB4.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=693

 Score = 239 bits (610),  Expect = 1e-65, Method: Compositional matrix adjust.
 Identities = 153/420 (36%), Positives = 232/420 (55%), Gaps = 21/420 (5%)

Query  563  DVAAELLDIYAQRAAKEGFAFKHDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAM  622
            ++A + + I  Q+ +    +++ D +Q   F    PF  T  Q +    +  D+  P  M
Sbjct  233  NLAMQKVRIGTQQFSAYPLSYQTDLKQR--FLAQLPFTPTDAQVRVTQEIEQDLTHPFPM  290

Query  623  DRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEM  682
             RLV GDVG GKT VA  AA LA+DN KQVA++ PT +LA+QH  NFR  F +  + +  
Sbjct  291  MRLVQGDVGSGKTLVAALAALLAIDNGKQVALMAPTEILAEQHATNFRRWFESLGIEVGW  350

Query  683  ISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERI  742
            ++     K +   L ++  G++ +++GTH L Q +V+F DL L+IVDE+HRFGV  +  +
Sbjct  351  LAGKVKGKARQTELEKIRTGQVQMVVGTHALFQDEVEFSDLALVIVDEQHRFGVHQRLML  410

Query  743  KAMRANVD----ILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFV----REYD  794
            +      D     L +TATPIPRTL M +    D SII   P  R  + T      R  +
Sbjct  411  REKGKQADHYPHQLIMTATPIPRTLAMTVYADLDTSIIDELPPGRTPITTVAISEERRAE  470

Query  795  SLV-VREAILREILRGGQVYYLYNDVENIQKAAER-----LAELVPEARIAIGHGQMRER  848
             +  V  A + E  +   V  L ++ E ++  A       L +++P  RI + HG+M+  
Sbjct  471  VIARVNHACVNEKRQAYWVCTLIDESEVLEAQAAEAIAEDLRKILPHLRIGLVHGRMKPA  530

Query  849  ELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHH  908
            E + +M  F     ++LV TT+IE G+D+P A+ +IIE A+  GL+QLHQLRGRVGR   
Sbjct  531  EKQDIMQAFKQAEIDLLVATTVIEVGVDVPNASLMIIENAERLGLSQLHQLRGRVGRGTT  590

Query  909  QAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSGSME  968
             ++  L+   P  +   +QKRL+ +   +D   GF ++  DLEIRG GE+LG +Q+G  E
Sbjct  591  ASFCVLMYKPP--LGKISQKRLQVLRDTQD---GFVISEKDLEIRGPGEVLGTKQTGVAE  645


>P43809.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=693

 Score = 238 bits (607),  Expect = 2e-65, Method: Compositional matrix adjust.
 Identities = 150/392 (38%), Positives = 224/392 (57%), Gaps = 19/392 (5%)

Query  591  QLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHK  650
            Q F  + PF+ T  Q + ++ +  D+ +   M RLV GDVG GKT VA  AA  A+DN K
Sbjct  259  QRFLATLPFQPTNAQKRVVSDIEQDLIKDYPMMRLVQGDVGSGKTLVAALAALTAIDNGK  318

Query  651  QVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIGT  710
            QVA++ PT +LA+QH +NFR  F  + + +  ++     K +   L ++  G + +++GT
Sbjct  319  QVALMAPTEILAEQHANNFRRWFKPFGIEVGWLAGKVKGKSRQAELEKIKTGAVQMVVGT  378

Query  711  HKLLQSDVKFKDLGLLIVDEEHRFGVRHK--ERIKAMRANV--DILTLTATPIPRTLNMA  766
            H L Q +V+F DL L+I+DE+HRFGV  +   R K  +A      L +TATPIPRTL M 
Sbjct  379  HALFQEEVEFSDLALVIIDEQHRFGVHQRLMLREKGEKAGFYPHQLIMTATPIPRTLAMT  438

Query  767  MSGMRDLSIIATPPARRLAVKTFV-----REYDSLVVREAILREILRGGQVYYLYNDVEN  821
            +    D SII   P  R  + T V     R    + V+ A + E  +   V  L ++ E 
Sbjct  439  VYADLDTSIIDELPPGRTPITTVVVSEERRAEIVMRVKNACVNEKRQAYWVCTLIDESEV  498

Query  822  IQKAA-----ERLAELVPEARIAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGID  876
            ++  A     E L + +P   I + HG+M+ +E + VM  F +   ++LV TT+IE G+D
Sbjct  499  LEAQAAEAIWEDLTKALPMLNIGLVHGRMKPQEKQDVMMRFKNAELDLLVATTVIEVGVD  558

Query  877  IPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASL  936
            +P A+ +IIE A+  GL+QLHQLRGRVGR    ++  L+   P  +   +QKRL+ +   
Sbjct  559  VPNASLMIIENAERLGLSQLHQLRGRVGRGCTASFCVLMYKPP--LGKVSQKRLQVLRDS  616

Query  937  EDLGAGFALATHDLEIRGAGELLGEEQSGSME  968
            +D   GF ++  DLEIRG GE+LG +Q+G  E
Sbjct  617  QD---GFVISEKDLEIRGPGEVLGTKQTGIAE  645


>Q8XD86.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=693

 Score = 232 bits (591),  Expect = 3e-63, Method: Compositional matrix adjust.
 Identities = 160/429 (37%), Positives = 234/429 (55%), Gaps = 30/429 (7%)

Query  561  VRDVAAELLDIYAQRAAKEGFAFK----HDREQYQLFCDSFPFETTPDQAQAINAVLSDM  616
            + ++ A  L + A RA  + F  +    +D  + +L   + PF+ T  QA+ +  +  DM
Sbjct  226  LEELLAHNLSMLALRAGAQRFHAQPLSANDALKNKLLA-ALPFKPTGAQARVVAEIERDM  284

Query  617  CQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANW  676
               + M RLV GDVG GKT VA  AA  A+ + KQVA++ PT LLA+QH +NFR+ F   
Sbjct  285  ALDVPMMRLVQGDVGSGKTLVAALAALRAIAHGKQVALMAPTELLAEQHANNFRNWFEPL  344

Query  677  PVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGV  736
             + +  ++  +  K +      +A G++ +++GTH + Q  V+F  L L+I+DE+HRFGV
Sbjct  345  GIEVGWLAGKQKGKARLSQQEAIASGQVQMIVGTHAIFQEQVQFNGLALVIIDEQHRFGV  404

Query  737  RHK----ERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTF---  789
              +    E+ +    +   L +TATPIPRTL M      D S+I   P  R  V T    
Sbjct  405  HQRLALWEKGQQQGFHPHQLIMTATPIPRTLAMTAYADLDTSVIDELPPGRTPVTTVAIP  464

Query  790  -VREYDSL-VVREAILREILRGGQVYYLYNDVENIQ----KAAERLAE----LVPEARIA  839
              R  D +  VR A + E   G Q Y++   +E  +    +AAE   E     +PE  + 
Sbjct  465  DTRRTDIIDRVRHACITE---GRQAYWVCTLIEESELLEAQAAEATWEELKLALPELNVG  521

Query  840  IGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQL  899
            + HG+M+  E + VM  F     ++LV TT+IE G+D+P A+ +IIE  +  GLAQLHQL
Sbjct  522  LVHGRMKPAEKQAVMASFKQGELHLLVATTVIEVGVDVPNASLMIIENPERLGLAQLHQL  581

Query  900  RGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELL  959
            RGRVGR    ++  LL   P  ++  AQ RL+    L D   GF +A  DLEIRG GELL
Sbjct  582  RGRVGRGAVASHCVLLYKTP--LSKTAQIRLQV---LRDSNDGFVIAQKDLEIRGPGELL  636

Query  960  GEEQSGSME  968
            G  Q+G+ E
Sbjct  637  GTRQTGNAE  645


>P24230.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=693

 Score = 231 bits (589),  Expect = 5e-63, Method: Compositional matrix adjust.
 Identities = 160/429 (37%), Positives = 234/429 (55%), Gaps = 30/429 (7%)

Query  561  VRDVAAELLDIYAQRAAKEGFAFK----HDREQYQLFCDSFPFETTPDQAQAINAVLSDM  616
            + ++ A  L + A RA  + F  +    +D  + +L   + PF+ T  QA+ +  +  DM
Sbjct  226  LEELLAHNLSMLALRAGAQRFHAQPLSANDTLKNKLLA-ALPFKPTGAQARVVAEIERDM  284

Query  617  CQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANW  676
               + M RLV GDVG GKT VA  AA  A+ + KQVA++ PT LLA+QH +NFR+ FA  
Sbjct  285  ALDVPMMRLVQGDVGSGKTLVAALAALRAIAHGKQVALMAPTELLAEQHANNFRNWFAPL  344

Query  677  PVRIEMISRFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEHRFGV  736
             + +  ++  +  K +      +A G++ +++GTH + Q  V+F  L L+I+DE+HRFGV
Sbjct  345  GIEVGWLAGKQKGKARLAQQEAIASGQVQMIVGTHAIFQEQVQFNGLALVIIDEQHRFGV  404

Query  737  RHK----ERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTF---  789
              +    E+ +    +   L +TATPIPRTL M      D S+I   P  R  V T    
Sbjct  405  HQRLALWEKGQQQGFHPHQLIMTATPIPRTLAMTAYADLDTSVIDELPPGRTPVTTVAIP  464

Query  790  -VREYDSL-VVREAILREILRGGQVYYLYNDVENIQ----KAAERLAE----LVPEARIA  839
              R  D +  V  A + E   G Q Y++   +E  +    +AAE   E     +PE  + 
Sbjct  465  DTRRTDIIDRVHHACITE---GRQAYWVCTLIEESELLEAQAAEATWEELKLALPELNVG  521

Query  840  IGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQL  899
            + HG+M+  E + VM  F     ++LV TT+IE G+D+P A+ +IIE  +  GLAQLHQL
Sbjct  522  LVHGRMKPAEKQAVMASFKQGELHLLVATTVIEVGVDVPNASLMIIENPERLGLAQLHQL  581

Query  900  RGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELL  959
            RGRVGR    ++  LL   P  ++  AQ RL+    L D   GF +A  DLEIRG GELL
Sbjct  582  RGRVGRGAVASHCVLLYKTP--LSKTAQIRLQV---LRDSNDGFVIAQKDLEIRGPGELL  636

Query  960  GEEQSGSME  968
            G  Q+G+ E
Sbjct  637  GTRQTGNAE  645


>P64323.1 RecName: Full=ATP-dependent DNA helicase RecG
 P9WMQ6.1 RecName: Full=ATP-dependent DNA helicase RecG
 P9WMQ7.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=737

 Score = 218 bits (554),  Expect = 4e-58, Method: Compositional matrix adjust.
 Identities = 146/411 (36%), Positives = 222/411 (54%), Gaps = 44/411 (11%)

Query  597  FPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLV  656
             PFE T  Q + ++ +   +     ++RL+ G+VG GKT VA+ A    VD   Q A+L 
Sbjct  284  LPFELTAGQREVLDVLSDGLAANRPLNRLLQGEVGSGKTIVAVLAMLQMVDAGYQCALLA  343

Query  657  PTTLLAQQHYDNFRDRF-----------ANWPVRIEMISRFRSAKEQTQILAEVAEGKID  705
            PT +LA QH  + RD             A    R+ +++   +A ++ Q+ AE+A G++ 
Sbjct  344  PTEVLAAQHLRSIRDVLGPLAMGGQLGGAENATRVALLTGSMTAGQKKQVRAEIASGQVG  403

Query  706  ILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDI----LTLTATPIPR  761
            I+IGTH LLQ  V F +LG+++VDE+HRFGV  +++++A +A   I    L +TATPIPR
Sbjct  404  IVIGTHALLQEAVDFHNLGMVVVDEQHRFGVEQRDQLRA-KAPAGITPHLLVMTATPIPR  462

Query  762  TLNMAMSGMRDLSIIATPPARRLAVKT---FVREYDSLVVR--EAILREILRGGQVYYLY  816
            T+ + + G  + S +   P  R  + T   FV++  + + R    I+ E   G Q Y + 
Sbjct  463  TVALTVYGDLETSTLRELPLGRQPIATNVIFVKDKPAWLDRAWRRIIEEAAAGRQAYVVA  522

Query  817  -----NDVENIQKAAE------------RLAELVPEARIAIGHGQMRERELERVMNDFHH  859
                 +D  ++Q                R AEL  E R+A+ HG++   + +  M  F  
Sbjct  523  PRIDESDDTDVQGGVRPSATAEGLFSRLRSAELA-ELRLALMHGRLSADDKDAAMAAFRA  581

Query  860  QRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHP  919
               +VLVCTT+IE G+D+P A  +++  AD FG++QLHQLRGR+GR  H +   L +  P
Sbjct  582  GEVDVLVCTTVIEVGVDVPNATVMLVMDADRFGISQLHQLRGRIGRGEHPSVCLLASWVP  641

Query  920  KAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSGSMETI  970
                T A +RL A+A   D   GFALA  DL+ R  G++LG  QSG   T+
Sbjct  642  P--DTPAGQRLRAVAGTMD---GFALADLDLKERKEGDVLGRNQSGKAITL  687


>F4INA9.1 RecName: Full=ATP-dependent DNA helicase homolog RECG, chloroplastic; 
Flags: Precursor
Length=973

 Score = 219 bits (557),  Expect = 2e-57, Method: Compositional matrix adjust.
 Identities = 144/468 (31%), Positives = 237/468 (51%), Gaps = 53/468 (11%)

Query  593   FCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQV  652
             F  + P+  TP Q  A++ ++ D+ +P+ M+RL+ GDVG GKT VA  A    + +  Q 
Sbjct  514   FLKALPYSLTPSQLSAVSEIIWDLKRPVPMNRLLQGDVGCGKTVVAFLACMEVIGSGYQA  573

Query  653   AVLVPTTLLAQQHYDNFRDRFANW-----PVRIEMISRFRSAKEQTQILAEVAEGKIDIL  707
             A + PT LLA QHY+  RD   N         I +++    AK+   I  ++  G I  +
Sbjct  574   AFMAPTELLAIQHYEQCRDLLENMEGVSSKPTIGLLTGSTPAKQSRMIRQDLQSGAISFI  633

Query  708   IGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVD-----------------  750
             IGTH L+   +++  L + +VDE+ RFGV  + +  +                       
Sbjct  634   IGTHSLIAEKIEYSALRIAVVDEQQRFGVIQRGKFNSKLYGTSMISKSGSSDSDDTSKAD  693

Query  751   ------ILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFVREYDSLVVREA---  801
                   +L ++ATPIPR+L +A+ G   L+ I   P  R+ V+T + E +   ++E    
Sbjct  694   LSMAPHVLAMSATPIPRSLALALYGDISLTQITGMPLGRIPVETHIFEGNETGIKEVYSM  753

Query  802   ILREILRGGQVYYLYNDVENIQ-----KAAERLAELV----PEARIAIGHGQMRERELER  852
             +L ++  GG+VY +Y  ++  +     +AA    E+V    P+    + HG+M+  + E 
Sbjct  754   MLEDLKSGGRVYVVYPVIDQSEQLPQLRAASAELEIVTKKFPKYNCGLLHGRMKSDDKEE  813

Query  853   VMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYA  912
              +N F      +L+ T +IE G+D+P A+ +++  A+ FG+AQLHQLRGRVGR   ++  
Sbjct  814   ALNKFRSGETQILLSTQVIEIGVDVPDASMMVVMNAERFGIAQLHQLRGRVGRGTRKSKC  873

Query  913   WLLTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSGSMETIGF  972
              L+       +T++ KRL  +    D   GF LA  DL +RG G+LLG++QSG +     
Sbjct  874   LLV-----GSSTNSLKRLNMLGKSSD---GFYLANIDLLLRGPGDLLGKKQSGHLPEFPV  925

Query  973   S---LYMELLENA-VDALKA-GREPSLEDLTSQQTEVELRMPSLLPDD  1015
             +   +   +L+ A + AL   G    LE   + + E+ +R P  L  D
Sbjct  926   ARLEIDGNMLQEAHIAALNVLGDSHDLEKFPALKAELSMRQPLCLLGD  973


>O69460.2 RecName: Full=ATP-dependent DNA helicase RecG
Length=743

 Score = 202 bits (515),  Expect = 5e-53, Method: Compositional matrix adjust.
 Identities = 138/416 (33%), Positives = 221/416 (53%), Gaps = 53/416 (13%)

Query  597  FPFETTPDQAQAINAVLSD-MCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNHKQVAVL  655
             PFE T  Q + +  VLSD +     ++RL+ G+VG GKT VA+ A    +D   Q  +L
Sbjct  284  LPFELTEGQRE-VRDVLSDGLAATRPLNRLLQGEVGSGKTIVAVLAMLQMIDAGYQCVLL  342

Query  656  VPTTLLAQQHYDNFRDRF-----------ANWPVRIEMISRFRSAKEQTQILAEVAEGKI  704
             PT +LA QH  + RD             A    ++ +++   +  ++ ++ A++  G+ 
Sbjct  343  APTEVLAAQHLLSIRDVLGPLGMGCQLGGAENATQVALLTGSMTMAQKKKVRADIFSGQT  402

Query  705  DILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKA-MRANV--DILTLTATPIPR  761
             I+IGTH LLQ  ++F +LG+++VDE+HRFGV  +++++   R  +   +L +TATPIPR
Sbjct  403  GIVIGTHALLQDAIEFHNLGMVVVDEQHRFGVEQRDQLRTKARTGIMPHLLVMTATPIPR  462

Query  762  TLNMAMSGMRDLSIIATPPARRLAVKT---FVREYDSLVVR--EAILREILRGGQVYYL-  815
            T+ + + G  ++S +   P  R  + +   FV++    + R  + IL E+  G Q Y + 
Sbjct  463  TVALTVYGDLEMSTLRELPRGRQPITSNVIFVKDKPGWLDRAWQRILEEVAAGRQAYVVA  522

Query  816  --YNDVENIQKAAE---------------RLAELVPEARIAIGHGQMRERELERVMNDFH  858
               ++ E+ QK  +               R  EL    R+A+ HG++   E +  M  F 
Sbjct  523  PRIDETEDPQKGGQNSRPSETADGLYARLRSGELA-NVRLALMHGRLSADEKDAAMMAFR  581

Query  859  HQRFNVLVCTTIIETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAY----AWL  914
                +VLVCT +IE G+D+P A  +++  AD FG++QLHQLRGR+GR  H +     +W+
Sbjct  582  AGEIDVLVCTNVIEVGVDVPNATIMLVMDADRFGISQLHQLRGRIGRGTHPSLCLLASWV  641

Query  915  LTPHPKAMTTDAQKRLEAIASLEDLGAGFALATHDLEIRGAGELLGEEQSGSMETI  970
                P      A +RL A+A   D   GFALA  DL+ R  G++LG  QSG   T+
Sbjct  642  SPGSP------AGRRLCAVAETMD---GFALADLDLKERREGDVLGRNQSGKAITL  688


>Q9ZJA1.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=623

 Score = 166 bits (421),  Expect = 9e-42, Method: Compositional matrix adjust.
 Identities = 129/396 (33%), Positives = 201/396 (51%), Gaps = 36/396 (9%)

Query  585  HDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFL  644
            ++ E+ + F  S PF+ T DQ  AI  + SD+  P+A  RL+ GDVG GKT V + +  L
Sbjct  216  NNSERLKAFIASLPFKLTRDQQNAIKEIQSDLTSPIACKRLIIGDVGCGKTMVILASMVL  275

Query  645  AVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKI  704
            A  N  +  ++ PT++LA+Q Y     +F      +E++      K    +  ++     
Sbjct  276  AYPN--KTLLMAPTSILAKQLYHE-ALKFLPPYFEVELLLGGSHKKRSNHLFEKITH---  329

Query  705  DILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVD----ILTLTATPIP  760
             ++IGT  LL       +  L+I DE+HRFG + + +++ M ++       L  +ATPIP
Sbjct  330  -VVIGTQALLFDKRDLNEFALVITDEQHRFGTKQRYQLEKMASSKGNKPHSLQFSATPIP  388

Query  761  RTLNMAMSGMRDLSIIATPPARRLAVKTFV---REYDSLVVREAILREILRGGQV---YY  814
            RTL +A S     ++I   P  +  ++T V   RE+   +V E I  EI +  QV   Y 
Sbjct  389  RTLALAKSAFVKTTMIREIPYPK-EIETLVLHKREFK--IVMEKISEEIAKNHQVIVVYP  445

Query  815  LYNDVENIQKAAERLAELVPEAR---IAIGHGQMRERELERVMNDFHHQRFNVLVCTTII  871
            L N  E I   +        + R   I    GQ + +E   V+ +F  +  ++L+ TT+I
Sbjct  446  LVNKSEKIPYLSLSEGASFWQKRFKNIYTTSGQDKNKE--EVIEEFR-ELGSILLATTLI  502

Query  872  ETGIDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLE  931
            E GI +P  + I+I   +  GLA LHQLRGRV R+  + Y +L T        +  +RLE
Sbjct  503  EVGISLPRLSVIVILAPERLGLATLHQLRGRVSRNGLKGYCFLCT------IQEENERLE  556

Query  932  AIASLEDLGAGFALATHDLEIRGAGELL-GEEQSGS  966
              A   D   GF +A  DL+ R +G+LL G +QSG+
Sbjct  557  KFADELD---GFKIAELDLQYRKSGDLLQGGKQSGN  589


>O26051.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=623

 Score = 164 bits (415),  Expect = 6e-41, Method: Compositional matrix adjust.
 Identities = 124/393 (32%), Positives = 195/393 (50%), Gaps = 30/393 (8%)

Query  585  HDREQYQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFL  644
            ++ E+ + F  S PF+ T DQ  AI  + +D+   +A  RL+ GDVG GKT V + +  L
Sbjct  216  NNNERLKAFIASLPFKLTRDQQNAIKEIQNDLTSSIACKRLIIGDVGCGKTMVILASMVL  275

Query  645  AVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKI  704
               N  +  ++ PT++LA+Q Y N   +F      +E++      K    +   +     
Sbjct  276  TYPN--KTLLMAPTSILAKQLY-NEALKFLPPYFEVELLLGGSYKKRSNHLFETITH---  329

Query  705  DILIGTHKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVD----ILTLTATPIP  760
             ++IGT  LL       +  L+I DE+HRFG + + +++ M ++       L  +ATPIP
Sbjct  330  -VVIGTQALLFDKRDLNEFALVITDEQHRFGTKQRYQLEKMASSKGNKPHSLQFSATPIP  388

Query  761  RTLNMAMSGMRDLSIIATPPARRLAVKTFVREYDSLVVREAILREILRGGQV---YYLYN  817
            RTL +A S     ++I   P  +      + + D  +V E I  EI +  QV   Y L N
Sbjct  389  RTLALAKSAFVKTTMIREIPYPKEIETLVLHKRDFKIVMEKISEEIAKNHQVIVVYPLVN  448

Query  818  DVENIQKAAERLAELVPEAR---IAIGHGQMRERELERVMNDFHHQRFNVLVCTTIIETG  874
            + E I   +        + R   +    GQ + +E   V+ +F     ++L+ TT+IE G
Sbjct  449  ESEKIPYLSLSEGASFWQKRFKKVYTTSGQDKNKE--EVIEEFRESG-SILLATTLIEVG  505

Query  875  IDIPTANTIIIERADHFGLAQLHQLRGRVGRSHHQAYAWLLTPHPKAMTTDAQKRLEAIA  934
            I +P  + ++I   +  GLA LHQLRGRV R+  + Y +L T        +  +RLE  A
Sbjct  506  ISLPRLSVMVILAPERLGLATLHQLRGRVSRNGLKGYCFLCT------IQEENERLEKFA  559

Query  935  SLEDLGAGFALATHDLEIRGAGELL-GEEQSGS  966
               D   GF +A  DLE R +G+LL G EQSG+
Sbjct  560  DELD---GFKIAELDLEYRKSGDLLQGGEQSGN  589


>O50224.1 RecName: Full=ATP-dependent DNA helicase RecG
Length=652

 Score = 95.1 bits (235),  Expect = 1e-18, Method: Compositional matrix adjust.
 Identities = 61/181 (34%), Positives = 97/181 (54%), Gaps = 0/181 (0%)

Query  590  YQLFCDSFPFETTPDQAQAINAVLSDMCQPLAMDRLVCGDVGFGKTEVAMRAAFLAVDNH  649
            +  F    PF  T  Q + I  + +D+ +   M RL+ GDVG GKT VA  A   A++  
Sbjct  275  WHRFLAHLPFSPTMAQERVIAEINADLVRHRPMRRLLQGDVGSGKTLVAAAATLTALEAG  334

Query  650  KQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMISRFRSAKEQTQILAEVAEGKIDILIG  709
             QVA++ PT +LA+Q +  F+       + +  +   RS + + +    +A G + ++IG
Sbjct  335  YQVAMMAPTEILAEQLHARFQQWLEPLGLEVGYLVGSRSPRARRETAETLAGGSLRLVIG  394

Query  710  THKLLQSDVKFKDLGLLIVDEEHRFGVRHKERIKAMRANVDILTLTATPIPRTLNMAMSG  769
            T  L Q  V F  LGL+I+DE+HRFGV  + ++    A   +L +TATPI     + +SG
Sbjct  395  TQSLFQEGVVFACLGLVIIDEQHRFGVEQRRQLLEKGAMPHLLVMTATPIMVEDGITVSG  454

Query  770  M  770
            +
Sbjct  455  I  455


>A9IR19.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=675

 Score = 83.6 bits (205),  Expect = 5e-15, Method: Compositional matrix adjust.
 Identities = 80/306 (26%), Positives = 131/306 (43%), Gaps = 44/306 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A I  R   P +++AP+   A +L+ E+ +F  +   N  ++  
Sbjct  44   QTLLG-VTGSGKTYTMANIIARLGRPALVLAPNKTLAAQLYAEMREFFPK---NAVEYFV  99

Query  76   LPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P                 ++ I   RLS    L   +  V++  V+ +     
Sbjct  100  SYYDYYQPEAYVPTRDLFIEKDSSINEHIEQMRLSATKSLLERRDTVIVGTVSCIYGIGN  159

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGS-E  177
            P  + H   L+++ G R+SR  +  +L +  Y   D     G +  RG  LD+FP  S E
Sbjct  160  PGDY-HAMVLILRAGDRISRREVLARLVAMQYTRNDADFARGTFRVRGETLDIFPAESPE  218

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDK----AAIELFRSQWRD  233
            L  RL  FDDEI+SL +FD  + R  ++V    + P   + T +     AIE  + + RD
Sbjct  219  LALRLTLFDDEIESLELFDPLTGRVRQKVPRFTVYPGSHYVTPRDTVLRAIETIKEELRD  278

Query  234  TFE-VKRDPEHIYQQVSKGTLPAGIEYWQPLFFS----------------EPLPPLFSYF  276
              + +  + + +  Q  +      +E  Q L F                 EP P L  Y 
Sbjct  279  RLKLLTAEGKLVEAQRLEQRTRFDLEMLQELGFCKGIENYSRHLSGAAPGEPPPTLIDYL  338

Query  277  PANTLL  282
            PA+ L+
Sbjct  339  PADALM  344


>Q7WK66.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=675

 Score = 79.0 bits (193),  Expect = 1e-13, Method: Compositional matrix adjust.
 Identities = 77/306 (25%), Positives = 131/306 (43%), Gaps = 44/306 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  R   P +++AP+   A +L+ E+ +F  +   N  ++  
Sbjct  44   QTLLG-VTGSGKTYTMANMIARLGRPALVLAPNKTLAAQLYAEMREFFPR---NAVEYFV  99

Query  76   LPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P                 ++ I   RLS    L   +  V++  V+ +     
Sbjct  100  SYYDYYQPEAYVPTRDLFIEKDSSINEHIEQMRLSATKSLLERRDTVIVGTVSCIYGIGN  159

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGS-E  177
            P  + H   L+++ G R+SR  +  +L +  Y   D     G +  RG  +D+FP  S E
Sbjct  160  PGDY-HAMVLILRTGDRISRREVLARLVAMQYTRNDADFTRGVFRVRGETIDIFPAESPE  218

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQWRD  233
            L  RL  FDDEI+SL +FD  + R  +++    + P   + T +     AIE  + + R+
Sbjct  219  LALRLTLFDDEIESLELFDPLTGRVRQKLPRFTVYPGSHYVTPRETVLRAIETIKEELRE  278

Query  234  TF-EVKRDPEHIYQQVSKGTLPAGIEYWQPLFFS----------------EPLPPLFSYF  276
               ++  D + +  Q  +      +E  Q L F                 EP P L  Y 
Sbjct  279  RLAQLIADGKLVEAQRLEQRTRFDLEMLQELGFCKGIENYSRHLSGAAPGEPPPTLIDYL  338

Query  277  PANTLL  282
            PA+ L+
Sbjct  339  PADALM  344


>Q7W8V6.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=675

 Score = 79.0 bits (193),  Expect = 1e-13, Method: Compositional matrix adjust.
 Identities = 77/306 (25%), Positives = 131/306 (43%), Gaps = 44/306 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  R   P +++AP+   A +L+ E+ +F  +   N  ++  
Sbjct  44   QTLLG-VTGSGKTYTMANMIARLGRPALVLAPNKTLAAQLYAEMREFFPR---NAVEYFV  99

Query  76   LPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P                 ++ I   RLS    L   +  V++  V+ +     
Sbjct  100  SYYDYYQPEAYVPTRDLFIEKDSSINEHIEQMRLSATKSLLERRDTVIVGTVSCIYGIGN  159

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGS-E  177
            P  + H   L+++ G R+SR  +  +L +  Y   D     G +  RG  +D+FP  S E
Sbjct  160  PGDY-HAMVLILRTGDRISRREVLARLVAMQYTRNDADFTRGVFRVRGETIDIFPAESPE  218

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQWRD  233
            L  RL  FDDEI+SL +FD  + R  +++    + P   + T +     AIE  + + R+
Sbjct  219  LALRLTLFDDEIESLELFDPLTGRVRQKLPRFTVYPGSHYVTPRETVLRAIETIKEELRE  278

Query  234  TF-EVKRDPEHIYQQVSKGTLPAGIEYWQPLFFS----------------EPLPPLFSYF  276
               ++  D + +  Q  +      +E  Q L F                 EP P L  Y 
Sbjct  279  RLAQLIADGKLVEAQRLEQRTRFDLEMLQELGFCKGIENYSRHLSGAAPGEPPPTLIDYL  338

Query  277  PANTLL  282
            PA+ L+
Sbjct  339  PADALM  344


>Q473K3.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=695

 Score = 76.3 bits (186),  Expect = 8e-13, Method: Compositional matrix adjust.
 Identities = 72/309 (23%), Positives = 136/309 (44%), Gaps = 50/309 (16%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  R   P ++ AP+   A +L+ E  +F  +   N  ++  
Sbjct  54   QTLLG-VTGSGKTYTMANVIARMGRPAIVFAPNKTLAAQLYSEFREFFPR---NAVEYFV  109

Query  76   LPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P                 ++ I   RLS    L   +  +++  V+ +     
Sbjct  110  SYYDYYQPEAYVPQRDLFIEKDSSINEHIEQMRLSATKSLLERRDTIIVATVSAIYGIGN  169

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPM-GSE  177
            P+ + H   L ++ G ++S+  +  +L +  Y   +   + G +  RG  +D+FP   +E
Sbjct  170  PNEY-HQMILTLRTGDKISQRDVIARLIAMQYTRNETDFQRGTFRVRGDTIDIFPAEHAE  228

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQWRD  233
            +  RL+ FDDE++SL+ FD  + R  +++    + P+  + T +     AIE  +++ RD
Sbjct  229  MAVRLEMFDDEVESLQFFDPLTGRVRQKIPRFTVYPSSHYVTPRETVLRAIEDIKAELRD  288

Query  234  TF----------EVKRDPEHI---YQQVSKGTLPAGIEYW-------QPLFFSEPLPPLF  273
                        EV+R  +      + +S+     GIE +       +P    EP P L 
Sbjct  289  RLEFFHKENRLVEVQRLEQRTRFDLEMLSELGFCKGIENYSRHLSGAKP---GEPPPTLV  345

Query  274  SYFPANTLL  282
             Y P++ L+
Sbjct  346  DYLPSDALM  354


>Q2L244.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=676

 Score = 76.3 bits (186),  Expect = 9e-13, Method: Compositional matrix adjust.
 Identities = 74/307 (24%), Positives = 130/307 (42%), Gaps = 46/307 (15%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  R   P +++AP+   A +L+ E+  F  +   N  ++  
Sbjct  44   QTLLG-VTGSGKTFTMANVIARLGRPALVLAPNKTLAAQLYAEMRDFFPK---NAVEYFV  99

Query  76   LPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P                 ++ I   RLS    L   +  +++  V+ +     
Sbjct  100  SYYDYYQPEAYVPTRDLFIEKDSSVNEHIEQMRLSATKSLLERRDTIIVGTVSCIYGIGN  159

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGS-E  177
            P  + H   L+++ G R+SR  +  +L +  Y   D     G +  RG  +D+FP  S E
Sbjct  160  PGDY-HAMVLILRAGDRISRREVLARLVAMQYTRNDADFTRGAFRVRGETIDIFPAESPE  218

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQWRD  233
            L  RL  FDDE+++L +FD  + +  +++    + P   + T +     AIE  R + R+
Sbjct  219  LALRLTLFDDEVETLELFDPLTGKVRQKLPRFTVYPGSHYVTPRETVLRAIETIREELRE  278

Query  234  TFEVKRDPEHIY--QQVSKGTLPAGIEYWQPLFFS----------------EPLPPLFSY  275
                  +   +   Q++ + T    +E  Q L F                 EP P L  Y
Sbjct  279  RLSTFTNEGKLLEAQRIEQRTR-FDLEMLQELGFCKGIENYSRHLSGAAPGEPPPTLIDY  337

Query  276  FPANTLL  282
             PA+ L+
Sbjct  338  LPADALM  344


>Q7VXH4.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=678

 Score = 75.9 bits (185),  Expect = 1e-12, Method: Compositional matrix adjust.
 Identities = 76/306 (25%), Positives = 130/306 (42%), Gaps = 44/306 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  R   P +++AP+   A +L+ E+ +F  +   N  ++  
Sbjct  44   QTLLG-VTGSGKTYTMANMIARLGRPALVLAPNKTLAAQLYAEMREFFPR---NAVEYFV  99

Query  76   LPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P                 ++ I   RLS    L   +  V++  V+ +     
Sbjct  100  SYYDYYQPEAYVPTRDLFIEKDSSINEHIEQMRLSATKSLLERRDTVIVGTVSCIYGIGN  159

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGS-E  177
            P  + H   L+++ G R+SR  +  +L +  Y   D     G +  R   +D+FP  S E
Sbjct  160  PGDY-HAMVLILRTGDRISRREVLARLVAMQYTRNDADFTRGVFRVRCETIDIFPAESPE  218

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQWRD  233
            L  RL  FDDEI+SL +FD  + R  +++    + P   + T +     AIE  + + R+
Sbjct  219  LALRLTLFDDEIESLELFDPLTGRVRQKLPRFTVYPGSHYVTPRETVLRAIETIKEELRE  278

Query  234  TF-EVKRDPEHIYQQVSKGTLPAGIEYWQPLFFS----------------EPLPPLFSYF  276
               ++  D + +  Q  +      +E  Q L F                 EP P L  Y 
Sbjct  279  RLAQLIADGKLVEAQRLEQRTRFDLEMLQELGFCKGIENYSRHLSGAAPGEPPPTLIDYL  338

Query  277  PANTLL  282
            PA+ L+
Sbjct  339  PADALM  344


>Q62CK6.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
 Q63NE3.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=696

 Score = 75.5 bits (184),  Expect = 1e-12, Method: Compositional matrix adjust.
 Identities = 72/307 (23%), Positives = 131/307 (43%), Gaps = 44/307 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A    R   P ++ AP+   A +L+ E  +F  +   N  ++  
Sbjct  55   QTLLG-VTGSGKTYTMANTIARLGRPAIVFAPNKTLAAQLYAEFREFFPR---NAVEYFV  110

Query  76   LPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P                 ++ I   RLS    L   +R V+IV   + +  + 
Sbjct  111  SYYDYYQPEAYVPQRDLFIEKDSSINEHIEQMRLSATKSL-MERRDVVIVATVSAIYGIG  169

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPM-GSE  177
              S  H   L ++ G ++ +  +  +L +  Y   +Q  + G +  RG  +D+FP   +E
Sbjct  170  NPSEYHQMILTLRTGDKIGQREVIARLIAMQYTRNEQDFQRGTFRVRGDTIDIFPAEHAE  229

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQWRD  233
            +  R++ FDDE+D+L +FD  + R  +++    + P+  + T +     A+E  + + R+
Sbjct  230  MAVRVELFDDEVDTLHLFDPLTGRVRQKIPRFTVYPSSHYVTPRETVMRAVETIKDELRE  289

Query  234  TFE-VKRDPEHIYQQVSKGTLPAGIEYWQPLFFS----------------EPLPPLFSYF  276
              E   RD + +  Q  +      +E  Q L F                 EP P L  Y 
Sbjct  290  RLEFFHRDGKLVEAQRLEQRTRFDLEMLQELGFCKGIENYSRHFSGAAPGEPPPTLVDYL  349

Query  277  PANTLLV  283
            P + L++
Sbjct  350  PPDALML  356


>C5CFR8.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=667

 Score = 75.1 bits (183),  Expect = 2e-12, Method: Compositional matrix adjust.
 Identities = 60/224 (27%), Positives = 113/224 (50%), Gaps = 16/224 (7%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQF--TDQMVMNLADW  73
            Q LLG +TG+     +A I ER   P ++I+P+     +L+ E   F   +++ + ++ +
Sbjct  33   QTLLG-VTGSGKTFTMASIIERVQQPALVISPNKALVAQLYREFRSFFPENRVELFISYY  91

Query  74   ETLPYDSFSPHQDIISS------------RLSTLYQLPTMQRGVLIVPVNTLMQRVCPHS  121
            +    +++ P +D+               R+S L  + T +  V++  V+ +     P  
Sbjct  92   DYYQPEAYIPTKDLYIEKDADINDLLARMRISALKSVLTRKDVVVVASVSAIYASGDPRD  151

Query  122  FLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSELPYR  181
            F   + + ++ GQR+ R+ L  +L S  Y   + +   G +  RG ++++FP   +   R
Sbjct  152  FQELN-ISLEIGQRIPRNELALKLASIQYSRSEDISSGGVFHLRGDVVEIFPPYEDYGIR  210

Query  182  LDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            + FFDDEI+ +  FD  +++TLEE D I + PA EF T +  I+
Sbjct  211  IYFFDDEIERIISFDPMNRKTLEEFDRIIIYPAKEFVTTEEKIK  254


>Q73MY7.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=662

 Score = 74.7 bits (182),  Expect = 2e-12, Method: Compositional matrix adjust.
 Identities = 75/309 (24%), Positives = 137/309 (44%), Gaps = 43/309 (14%)

Query  13   AGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLA  71
            AG++ + L  +TG+     +A I +    P ++I+ +   A +L+ E   F  +   N  
Sbjct  29   AGDKFQTLKGVTGSGKTFTMANIIQAVQKPTLIISHNKTLAAQLYREFKTFFPE---NAV  85

Query  72   DWETLPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLM  114
            ++    YD + P                 + +I   RLS  + L   +  +++  V+ + 
Sbjct  86   EYFVSYYDYYQPEAYVPARDLYIEKDASINDEIDRLRLSATFSLMERRDVIVVSTVSCIY  145

Query  115  QRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPM  174
                P S+     + ++KG+ +  + L+ QL S  Y   D V+E G +  +G ++++FP 
Sbjct  146  GLGLPESW-RDLRITIEKGENIEIEKLKKQLISLQYERNDAVLERGRFRVKGDVMEIFPA  204

Query  175  GSELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEF--PTDKA--AIELFRSQ  230
              E  YRL+F  +EI  +R F+  S   ++E + +++ PA  F  P D    A+E  + +
Sbjct  205  YMEDAYRLEFDWEEIVRIRKFNPISGEVIQEYEELSIYPAKHFVMPEDAIPNALERIKKE  264

Query  231  WRDTFEV-------------KRDPEHIYQQVSKGTLPAGIE-YWQPLFFSEPLPP---LF  273
              +   V             K   E+  + +S+     GIE Y  P+   +P  P   LF
Sbjct  265  LEERLNVLNKEGKLLEAERLKTRTEYDIEMLSEMGYCPGIENYSAPIANRKPGEPPATLF  324

Query  274  SYFPANTLL  282
             YFP + LL
Sbjct  325  HYFPDDFLL  333


>P72174.2 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=670

 Score = 73.2 bits (178),  Expect = 8e-12, Method: Compositional matrix adjust.
 Identities = 72/307 (23%), Positives = 130/307 (42%), Gaps = 44/307 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  +   P +++AP+   A +L+ E   F      N  ++  
Sbjct  34   QTLLG-VTGSGKTFSIANVIAQVQRPTLVLAPNKTLAAQLYGEFKTF---FPHNSVEYFV  89

Query  76   LPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P   + SS                 RLS    L      +++  V+++     
Sbjct  90   SYYDYYQPEAYVPSSDTYIEKDSSINDHIEQMRLSATKALLERPDAIIVATVSSIYGLGD  149

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSEL  178
            P S+L    L + +G R+ +  L  +L S  Y   D       +  RG ++D+FP  S+L
Sbjct  150  PASYLK-MVLHLDRGDRIDQRELLRRLTSLQYTRNDMDFARATFRVRGDVIDIFPAESDL  208

Query  179  -PYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQWRD  233
               R++ FDDE++SL  FD  +   + ++      P   + T +     A++  +++ ++
Sbjct  209  EAIRVELFDDEVESLSAFDPLTGEVIRKLPRFTFYPKSHYVTPRETLLEAVDQIKAELKE  268

Query  234  TFEVKRDPEHIY--QQVSKGT-----------LPAGIEYWQPLFFS----EPLPPLFSYF  276
              +  R+   +   Q++ + T              GIE +          EP P L+ Y 
Sbjct  269  RLDYLRNNNKLVEAQRLEQRTRFDLEMILELGYCNGIENYSRYLSGRAPGEPPPTLYDYL  328

Query  277  PANTLLV  283
            PAN+LLV
Sbjct  329  PANSLLV  335


>Q5P0E7.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=685

 Score = 71.6 bits (174),  Expect = 2e-11, Method: Compositional matrix adjust.
 Identities = 75/306 (25%), Positives = 132/306 (43%), Gaps = 44/306 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  R   P +++AP+   A +L+ E  +F  +   N  ++  
Sbjct  48   QTLLG-VTGSGKTYTMANVIARCGRPALVLAPNKTLAAQLYAEFREFFPE---NAVEYFV  103

Query  76   LPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P                 ++ I   RLS    L   +R V+IV   + +  + 
Sbjct  104  SYYDYYQPEAYVPSRDLFIEKDSSINEHIEQMRLSATKSL-MERRDVVIVATVSCIYGIG  162

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPM-GSE  177
                 H   L +++G+R++   L  +L +  Y   D     G +  RG ++D+FP   +E
Sbjct  163  DPVDYHAMILHLREGERIAHRDLVQRLVAMQYTRSDIDFRRGTFRVRGDVIDVFPAENAE  222

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELF------  227
            L  R++ FDDE++ L +FD  +    +++    + P+  + T +A    AIE        
Sbjct  223  LAVRIEMFDDEVEHLTLFDPLTGHLKQKLVRFTVYPSSHYVTPRATVLKAIEAIKDELRD  282

Query  228  RSQWRDTFEVKRDPEHIYQQ-------VSKGTLPAGIEYWQPLFF----SEPLPPLFSYF  276
            RS W  T     + + I Q+       +++     GIE +          EP P L  Y 
Sbjct  283  RSAWFQTSGKLVEAQRIEQRTRFDLEMLNEMGFCKGIENYSRHLSGRGQGEPPPTLIDYL  342

Query  277  PANTLL  282
            P++ LL
Sbjct  343  PSDALL  348


>Q6F9D2.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=675

 Score = 71.2 bits (173),  Expect = 3e-11, Method: Compositional matrix adjust.
 Identities = 76/307 (25%), Positives = 132/307 (43%), Gaps = 44/307 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  +   P +++A +   A +L+ E   F      N  ++  
Sbjct  39   QLLLG-VTGSGKTYTMANVIAQTQRPTIVMAHNKTLAAQLYGEFKAFFPN---NAVEYFV  94

Query  76   LPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P   + SS                 RLS    L   +  +++  V+ +     
Sbjct  95   SYYDYYQPEAYVPSSDTFIEKDAAINDHIDQMRLSATRALLERRDAIIVASVSAIYGLGD  154

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGS-E  177
            P +++    L + +G R++RD L  +L    Y   +     G Y  RG +LD+FP  S +
Sbjct  155  PEAYMK-MLLHVVEGDRINRDDLIRRLVEMQYTRNELEFLRGTYRIRGEILDVFPAESDQ  213

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDK----AAIELFRSQWRD  233
               R++ FDDE+DS+R FD  + +   +V  + + P   + T K     AIE  + + +D
Sbjct  214  FAIRIELFDDEVDSIRWFDPLTGKMQRKVPRVTIYPKSHYVTPKDNLSRAIETIKDELQD  273

Query  234  TFEVKRDPEHIY--QQVSKGT-----------LPAGIE-YWQPLFFSEP---LPPLFSYF  276
              +  R+ + +   Q++ + T              GIE Y + L    P    P LF Y 
Sbjct  274  QLKFFREHDKLLEAQRIEQRTRYDLEMMQQLGYTNGIENYSRHLSGRSPGAAPPTLFDYI  333

Query  277  PANTLLV  283
            P + LL+
Sbjct  334  PEDALLI  340


>Q6LT47.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=674

 Score = 70.9 bits (172),  Expect = 4e-11, Method: Compositional matrix adjust.
 Identities = 78/309 (25%), Positives = 133/309 (43%), Gaps = 47/309 (15%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +      P  ++AP+   A +L+ E+ +F      N  ++  
Sbjct  35   QTLLG-VTGSGKTFTIANVIAESNRPTFIMAPNKTLAAQLYGEMKEFFPD---NAVEYFV  90

Query  76   LPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P   + ++                 RLS    L   +  ++I  V+ +     
Sbjct  91   SYYDYYQPEAYVPTTDTFIEKDASVNAHIEQMRLSATKALLERRDVIIIASVSAIYGLGD  150

Query  119  PHSFLHGHALVMKKGQRLS-RDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSE  177
            P S+L    L +++G  L+ RD LR +L    Y   D   E G +  RG ++D+FP  SE
Sbjct  151  PDSYLK-MMLHVRRGDMLNQRDILR-RLAELQYTRNDVSFERGHFRVRGEVIDVFPAESE  208

Query  178  L-PYRLDFFDDEIDSLRVFDVDSQRTLE-EVDAINLLPAHEFPTDKAAIELFRSQWRDTF  235
                R++ FDDE++ + VFD  +   L+ ++    + P   + T +  I     + +D  
Sbjct  209  HDAIRIELFDDEVECINVFDPLTGAVLQKDLPRCTIYPKTHYVTPREKILEAIEKIKDEL  268

Query  236  EVKR----DPEHIY--QQVSKGT-----------LPAGIEYWQPLFFS----EPLPPLFS  274
             V+R    D   +   Q++S+ T             +GIE +          EP P LF 
Sbjct  269  VVRRKQLMDSNKLVEEQRISQRTQFDIEMMNELGFCSGIENYSRYLSGREEGEPPPTLFD  328

Query  275  YFPANTLLV  283
            Y PA+ LL+
Sbjct  329  YLPADGLLI  337


>Q6D3C4.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=670

 Score = 70.5 bits (171),  Expect = 5e-11, Method: Compositional matrix adjust.
 Identities = 74/307 (24%), Positives = 133/307 (43%), Gaps = 44/307 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +      P +++AP+   A +L+ E+ +F  +   N  ++  
Sbjct  35   QTLLG-VTGSGKTFTIANVIADLNRPTMMLAPNKTLAAQLYGEMKEFFPE---NAVEYFV  90

Query  76   LPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P   + SS                 RLS    L   +  +++  V+ +     
Sbjct  91   SYYDYYQPEAYVPSSDTFIEKDASVNEHIEQMRLSATKALLERRDVIVVASVSAIYGLGD  150

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGS-E  177
            P  +L    L + +G  + + A+  +L    Y   DQ  + G +  RG ++D+FP  S E
Sbjct  151  PDLYLK-MMLHLTQGMLIDQRAILRRLAELQYARNDQAFQRGTFRVRGEVIDIFPAESDE  209

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDK----AAIELFRSQWRD  233
            +  R++ FD+E++ L +FD  +   L+ V    + P   + T +     A+E  + +  D
Sbjct  210  IALRVELFDEEVERLSLFDPLTGHVLQTVPRYTIYPKTHYVTPRERILQAMEDIKVELAD  269

Query  234  TFEVKRDPEHIY--QQVSKGT-----------LPAGIEYWQPLFFS----EPLPPLFSYF  276
              +V    + +   Q++S+ T             +GIE +          EP P LF Y 
Sbjct  270  RKKVLLANDKLVEEQRLSQRTQFDLEMMNELGYCSGIENYSRYLSGRGPGEPPPTLFDYL  329

Query  277  PANTLLV  283
            PA+ LLV
Sbjct  330  PADGLLV  336


>Q3KF38.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=671

 Score = 70.5 bits (171),  Expect = 5e-11, Method: Compositional matrix adjust.
 Identities = 75/324 (23%), Positives = 135/324 (42%), Gaps = 47/324 (15%)

Query  2    PEQYRYTLP-VKAG--EQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDE  58
            PE  R  +  ++AG   Q LLG +TG+     +A +  +   P +++AP+   A +L+ E
Sbjct  17   PEAIRLMVEGIEAGLSHQTLLG-VTGSGKTFSIANVIAQVQRPTLVLAPNKTLAAQLYGE  75

Query  59   ISQFTDQMVMNLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTM  101
               F      N  ++    YD + P   + SS                 RLS    L   
Sbjct  76   FKSFFPN---NAVEYFVSYYDYYQPEAYVPSSDTFIEKDASINDHIEQMRLSATKALLER  132

Query  102  QRGVLIVPVNTLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGE  161
            +  +++  V+ +     P ++L    L + +G +L + AL  +L    Y   D       
Sbjct  133  KDAIIVTTVSCIYGLGSPETYLK-MVLHVDRGDKLDQRALVRRLADLQYTRNDMDFARAT  191

Query  162  YATRGALLDLFPMGSEL-PYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTD  220
            +  RG ++D++P  S+L   R++ FDDE++S+  FD  +   + ++      P   + T 
Sbjct  192  FRVRGDVIDIYPAESDLEAIRIELFDDEVESISAFDPLTGEVIRKLPRFTFYPKSHYVTP  251

Query  221  KA----AIELFRSQWRDTFEVKRDPEHIY--QQVSKGT-----------LPAGIEYWQPL  263
            +     AIE  + + ++  E  R+   +   Q++ + T              GIE +   
Sbjct  252  RETLLDAIEGIKVELQERLEYLRNNNKLVEAQRLEQRTRFDLEMILELGYCNGIENYSRY  311

Query  264  FFSEPL----PPLFSYFPANTLLV  283
                P     P L+ Y PA+ LLV
Sbjct  312  LSGRPAGAAPPTLYDYLPADALLV  335


>C6DDU0.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=670

 Score = 70.1 bits (170),  Expect = 8e-11, Method: Compositional matrix adjust.
 Identities = 74/307 (24%), Positives = 132/307 (43%), Gaps = 44/307 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +      P +++AP+   A +L+ E+ +F      N  ++  
Sbjct  35   QTLLG-VTGSGKTFTIANVIADLNRPTMMLAPNKTLAAQLYGEMKEFFPD---NAVEYFV  90

Query  76   LPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P   + SS                 RLS    L   +  +++  V+ +     
Sbjct  91   SYYDYYQPEAYVPSSDTFIEKDASVNEHIEQMRLSATKALLERRDVIVVASVSAIYGLGD  150

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGS-E  177
            P  +L    L + +G  + + A+  +L    Y   DQ  + G +  RG ++D+FP  S E
Sbjct  151  PDLYLK-MMLHLTQGMLIDQRAILRRLAELQYSRNDQAFQRGTFRVRGEVIDIFPAESDE  209

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDK----AAIELFRSQWRD  233
            +  R++ FD+E++ L +FD  +   L+ V    + P   + T +     A+E  + +  D
Sbjct  210  IALRVELFDEEVERLSLFDPLTGHVLQTVPRYTIYPKTHYVTPRERILQAMEDIKVELAD  269

Query  234  TFEVKRDPEHIY--QQVSKGT-----------LPAGIEYWQPLFFS----EPLPPLFSYF  276
              +V    + +   Q++S+ T             +GIE +          EP P LF Y 
Sbjct  270  RRKVLLANDKLVEEQRLSQRTQFDLEMMNELGYCSGIENYSRYLSGRGPGEPPPTLFDYL  329

Query  277  PANTLLV  283
            PA+ LLV
Sbjct  330  PADGLLV  336


>Q884C9.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=671

 Score = 70.1 bits (170),  Expect = 8e-11, Method: Compositional matrix adjust.
 Identities = 71/307 (23%), Positives = 126/307 (41%), Gaps = 44/307 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  +   P +++AP+   A +L+ E   F      N  ++  
Sbjct  34   QTLLG-VTGSGKTFSIANVISQIKRPTLVLAPNKTLAAQLYGEFKAFFPN---NAVEYFV  89

Query  76   LPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P   + SS                 RLS    L   +  +++  V+ +     
Sbjct  90   SYYDYYQPEAYVPSSDTFIEKDASINDHIEQMRLSATKALLERKDAIIVTTVSCIYGLGS  149

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSEL  178
            P ++L    L + +G +L + AL  +L    Y   D       +  RG ++D++P  S+L
Sbjct  150  PETYLR-MVLHVDRGDKLDQRALLRRLADLQYTRNDMDFARATFRVRGDVIDIYPAESDL  208

Query  179  -PYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQWRD  233
               R++ FDDE++SL  FD  +   + ++      P   + T +     A+E  + + ++
Sbjct  209  EAIRIELFDDEVESLSAFDPLTGEVIRKLPRFTFYPKSHYVTPRETLVEAMEGIKVELQE  268

Query  234  TFEVKRDPEHIY--QQVSKGT-----------LPAGIEYWQPLFFSEPL----PPLFSYF  276
              E  R    +   Q++ + T              GIE +       P     P LF Y 
Sbjct  269  RLEYLRSQNKLVEAQRLEQRTRFDLEMMLELGYCNGIENYSRYLSGRPSGAPPPTLFDYL  328

Query  277  PANTLLV  283
            PA+ LLV
Sbjct  329  PADALLV  335


>Q8Y0N2.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=696

 Score = 70.1 bits (170),  Expect = 8e-11, Method: Compositional matrix adjust.
 Identities = 71/309 (23%), Positives = 134/309 (43%), Gaps = 50/309 (16%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  +   P ++ AP+   A +L+ E  +F  +   N  ++  
Sbjct  54   QTLLG-VTGSGKTYTMANVIAQAGRPAIVFAPNKTLAAQLYSEFREFFPR---NAVEYFV  109

Query  76   LPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P                 ++ I   RLS    L   +R V+IV   + +  + 
Sbjct  110  SYYDYYQPEAYVPQRDLFIEKDSSVNEHIEQMRLSATKSL-LERRDVVIVATVSAIYGIG  168

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPM-GSE  177
              +  H   L ++ G ++S+  +  +L +  Y   +   + G +  RG  +D+FP   +E
Sbjct  169  NPTEYHQMILTLRTGDKISQRDVIARLIAMQYTRNETDFQRGTFRVRGDTVDIFPAEHAE  228

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQWRD  233
            +  RL+ FDDE+DSL++FD  + R  +++    + P+  + T +     AI   +++ R+
Sbjct  229  MAVRLELFDDEVDSLQLFDPLTGRVRQKILRFTVYPSSHYVTPRETVLRAIGTIKAELRE  288

Query  234  TFEVKRDPEHIY--QQVSKGT-----------LPAGIEYW-------QPLFFSEPLPPLF  273
              +       +   Q++ + T              GIE +       QP    EP P L 
Sbjct  289  RLDFFYQENKLVEAQRLEQRTRFDLEMLQELGFCKGIENYSRHLSGAQP---GEPPPTLV  345

Query  274  SYFPANTLL  282
             Y P++ L+
Sbjct  346  DYLPSDALM  354


>Q4KF19.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=671

 Score = 69.3 bits (168),  Expect = 1e-10, Method: Compositional matrix adjust.
 Identities = 75/324 (23%), Positives = 134/324 (41%), Gaps = 47/324 (15%)

Query  2    PEQYRYTLP-VKAG--EQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDE  58
            PE  R  +  ++AG   Q LLG +TG+     +A +  +   P +++AP+   A +L+ E
Sbjct  17   PEAIRLMVEGIEAGLAHQTLLG-VTGSGKTFSIANVIAQVQRPTLVLAPNKTLAAQLYGE  75

Query  59   ISQFTDQMVMNLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTM  101
               F      N  ++    YD + P   + SS                 RLS    L   
Sbjct  76   FKAFFPN---NAVEYFVSYYDYYQPEAYVPSSDTFIEKDASINDHIEQMRLSATKALLER  132

Query  102  QRGVLIVPVNTLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGE  161
            +  +++  V+ +     P ++L    L + +G +L + AL  +L    Y   D       
Sbjct  133  KDAIIVTTVSCIYGLGSPETYLK-MVLHVDRGDKLDQRALLRRLADLQYTRNDMDFARAT  191

Query  162  YATRGALLDLFPMGSEL-PYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTD  220
            +  RG ++D++P  S+L   R++ FDDE++S+  FD  +   + ++      P   + T 
Sbjct  192  FRVRGDVIDIYPAESDLEAIRIELFDDEVESISAFDPLTGEVIRKLPRFTFYPKSHYVTP  251

Query  221  KA----AIELFRSQWRDTFEVKRDPEHIY--QQVSKGT-----------LPAGIEYWQPL  263
            +     AIE  + + ++  E  R    +   Q++ + T              GIE +   
Sbjct  252  RETLLDAIEGIKVELQERLEYLRSNNKLVEAQRLEQRTRFDLEMILELGYCNGIENYSRY  311

Query  264  FFSEPL----PPLFSYFPANTLLV  283
                P     P L+ Y PA+ LLV
Sbjct  312  LSGRPAGAAPPTLYDYLPADALLV  335


>Q48KA6.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=671

 Score = 68.6 bits (166),  Expect = 2e-10, Method: Compositional matrix adjust.
 Identities = 70/307 (23%), Positives = 126/307 (41%), Gaps = 44/307 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  +   P +++AP+   A +L+ E   F      N  ++  
Sbjct  34   QTLLG-VTGSGKTFSIANVISQVKRPTLVLAPNKTLAAQLYGEFKAFFPN---NAVEYFV  89

Query  76   LPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P   + SS                 RLS    L   +  +++  V+ +     
Sbjct  90   SYYDYYQPEAYVPSSDTFIEKDASINDHIEQMRLSATKALLERKDAIIVTTVSCIYGLGS  149

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSEL  178
            P ++L    + + +G +L + AL  +L    Y   D       +  RG ++D++P  S+L
Sbjct  150  PETYLR-MVMHIDRGDKLDQRALLRRLADLQYTRNDMDFARATFRVRGDVIDIYPAESDL  208

Query  179  -PYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQWRD  233
               R++ FDDE++SL  FD  +   + ++      P   + T +     A+E  + + ++
Sbjct  209  EAIRVELFDDEVESLSAFDPLTGEVIRKLPRFTFYPKSHYVTPRETLIEAMEGIKVELQE  268

Query  234  TFEVKRDPEHIY--QQVSKGT-----------LPAGIEYWQPLFFSEPL----PPLFSYF  276
              E  R    +   Q++ + T              GIE +       P     P LF Y 
Sbjct  269  RLEYLRTQNKLVEAQRLEQRTRFDLEMMLELGYCNGIENYSRYLSGRPSGAPPPTLFDYL  328

Query  277  PANTLLV  283
            PA+ LLV
Sbjct  329  PADALLV  335


>Q03JK4.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=668

 Score = 67.8 bits (164),  Expect = 4e-10, Method: Compositional matrix adjust.
 Identities = 57/234 (24%), Positives = 105/234 (45%), Gaps = 23/234 (10%)

Query  11   VKAGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN  69
            +K GE+ ++L   TG      ++++ +R   P ++IA +   A +L+ E  +F      N
Sbjct  38   IKGGEKAQILKGATGTGKTYTMSQVIQRVNKPTLVIAHNKTLAGQLYGEFKEFFPD---N  94

Query  70   LADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNT  112
              ++    YD + P   + SS                 R S    L      +++  V+ 
Sbjct  95   AVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSALLERNDVIVVASVSC  154

Query  113  LMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLF  172
            +     P  +    A+ ++ GQ +SRD L   L    +   D   + G++  RG ++++F
Sbjct  155  IYGLGSPKEYADS-AVSLRPGQEISRDKLLNDLVDIQFERNDIDFQRGKFRVRGDVVEIF  213

Query  173  PMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            P    E  +R++FF DEID +   +  + R L EV+ + L PA  F T++  +E
Sbjct  214  PASRDENAFRVEFFGDEIDRICEIESLTGRNLGEVEHLVLFPATHFMTNEEHME  267


>Q5LYS1.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
 Q5M3D5.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=668

 Score = 67.8 bits (164),  Expect = 4e-10, Method: Compositional matrix adjust.
 Identities = 57/234 (24%), Positives = 105/234 (45%), Gaps = 23/234 (10%)

Query  11   VKAGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN  69
            +K GE+ ++L   TG      ++++ +R   P ++IA +   A +L+ E  +F      N
Sbjct  38   IKGGEKAQILKGATGTGKTYTMSQVIQRVNKPTLVIAHNKTLAGQLYGEFKEFFPD---N  94

Query  70   LADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNT  112
              ++    YD + P   + SS                 R S    L      +++  V+ 
Sbjct  95   AVEYFVSYYDYYQPEAYVPSSDTYIEKDSSINDEIDKLRHSATSALLERNDVIVVASVSC  154

Query  113  LMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLF  172
            +     P  +    A+ ++ GQ +SRD L   L    +   D   + G++  RG ++++F
Sbjct  155  IYGLGSPKEYADS-AVSLRPGQEISRDKLLNDLVDIQFERNDIDFQRGKFRVRGDVVEIF  213

Query  173  PMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            P    E  +R++FF DEID +   +  + R L EV+ + L PA  F T++  +E
Sbjct  214  PASRDENAFRVEFFGDEIDRICEIESLTGRNLGEVEHLVLFPATHFMTNEEHME  267


>A3N031.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=673

 Score = 67.8 bits (164),  Expect = 4e-10, Method: Compositional matrix adjust.
 Identities = 72/307 (23%), Positives = 132/307 (43%), Gaps = 44/307 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  +   P +L+AP+   A +L+ E+  F  +   N  ++  
Sbjct  38   QTLLG-VTGSGKTFTIANVIAQLNRPAMLLAPNKTLAAQLYAEMKAFFPE---NAVEYFV  93

Query  76   LPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P   + SS                 RLS        +  +++  V+ +     
Sbjct  94   SYYDYYQPEAYVPSSDTFIEKDASINEQIEQMRLSATKSFLERRDTIVVASVSAIYGLGD  153

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGS-E  177
              +++    L ++ G  + +  +  +L    Y   DQ  +   +  RG ++D+FP  S E
Sbjct  154  VDAYMQ-MMLHLQLGAIIDQREILARLAELQYTRNDQAFQRSTFRVRGEVIDIFPAESDE  212

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQW--  231
            +  R++ FDDEI+SL +FD  +  +L +V    + P   + T +     AIE  + +   
Sbjct  213  IALRVELFDDEIESLSLFDPLTGHSLGKVPRYTIYPKTHYVTPRERILNAIEEIKQELVE  272

Query  232  RDTFEVKRDPEHIYQQVSKGT-----------LPAGIEYWQPLFFS----EPLPPLFSYF  276
            R  + +K +     Q++++ T             +GIE +          EP P LF Y 
Sbjct  273  RREYFIKENKLLEEQRITQRTQFDIEMMNELGYCSGIENYSRYLSGRKEGEPPPTLFDYM  332

Query  277  PANTLLV  283
            PA+ LL+
Sbjct  333  PADGLLI  339


>Q7VLL3.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=675

 Score = 67.0 bits (162),  Expect = 7e-10, Method: Compositional matrix adjust.
 Identities = 69/307 (22%), Positives = 132/307 (43%), Gaps = 44/307 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +  +   P +L+AP+   A +L+ E+  F  +   N  ++  
Sbjct  38   QTLLG-VTGSGKTFTIANVIAQLNRPAMLLAPNKTLAAQLYAEMKAFFPE---NAVEYFV  93

Query  76   LPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P                 ++ I   RLS        +  +++  V+ +     
Sbjct  94   SYYDYYQPEAYVPASDTFIEKDASINEQIEQMRLSATKSFLERRDTIVVASVSAIYGLGD  153

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGS-E  177
             ++++    L ++ G  +++  +  +L    Y   DQ  +   +  RG ++D+FP  S E
Sbjct  154  VNAYMQ-MMLHLQVGAIINQRDILARLAELQYTRNDQAFQRSTFRVRGEVIDIFPAESDE  212

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIELFRSQWRDTFEV  237
            +  R++ FDDEID+L +FD  +  +  ++    + P   + T +  I     Q ++    
Sbjct  213  IALRIELFDDEIDNLSLFDPLTGHSFGKIPRYTIYPKTHYVTPRERILTAIDQIKNELTG  272

Query  238  KRD---PEHIY---QQVSKGT-----------LPAGIEYWQPLFFS----EPLPPLFSYF  276
            ++D    EH     Q++++ T             +GIE +          EP P LF Y 
Sbjct  273  RQDYFIKEHKLLEEQRITQRTQFDIEMINELGYCSGIENYSRYLSGRQEGEPPPTLFDYM  332

Query  277  PANTLLV  283
            PA+ LL+
Sbjct  333  PADGLLI  339


>Q3ZZK7.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=664

 Score = 66.2 bits (160),  Expect = 1e-09, Method: Compositional matrix adjust.
 Identities = 58/221 (26%), Positives = 99/221 (45%), Gaps = 20/221 (9%)

Query  15   EQRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWE  74
            +Q LLG +TG+     +A +  R   P ++I+ +   A +L+ E+ +F  +   N  ++ 
Sbjct  33   DQTLLG-VTGSGKTFTMANVIARVNRPTLIISHNKTLAAQLYSEMKEFLPE---NSVEYF  88

Query  75   TLPYD-----SFSPHQDI-------ISSRLSTLYQLPTM----QRGVLIVPVNTLMQRVC  118
               YD     ++ P +D+       I+  +  L    T     +R V+IV   + +  + 
Sbjct  89   VSYYDYYQPEAYVPQKDMYIEKDSDINEEIDKLRHAATRALFERRDVVIVASVSCIYGLG  148

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSEL  178
                     L +KKGQ   RD +  +L    Y   D     G++  RG  L++ P   EL
Sbjct  149  EPEEYRSFVLPLKKGQSFRRDLILRRLVDMQYERNDLDFSRGKFRLRGDTLEIQPAYEEL  208

Query  179  PYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPT  219
              R++FF DEI+ +   D  S   L  ++ IN+ PA  F T
Sbjct  209  ALRVEFFGDEIERIVSLDPVSGELLAGIEEINIYPAKHFVT  249


>B4ESU7.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=669

 Score = 66.2 bits (160),  Expect = 1e-09, Method: Compositional matrix adjust.
 Identities = 72/307 (23%), Positives = 131/307 (43%), Gaps = 44/307 (14%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG +TG+     +A +      P +++AP+   A +L+ E+ +F  +   N  ++  
Sbjct  35   QTLLG-VTGSGKTFTIANVIANLNRPTMVLAPNKTLAAQLYSEMKEFFPE---NAVEYFV  90

Query  76   LPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P   + SS                 RLS    L   +  +++  V+ +     
Sbjct  91   SYYDYYQPEAYVPSSDTFIEKDASVNEHIEQMRLSATKALLERKDVIVVSSVSAIYGLGD  150

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSE-  177
            P S+L    L +  G  + + A+  +L    Y   DQ  + G +  RG ++D+FP  S+ 
Sbjct  151  PDSYLK-MMLHLSNGMIIDQRAILRRLADLQYTRNDQAFQRGTFRVRGEVIDIFPAESDD  209

Query  178  LPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKA----AIELFRSQWRD  233
               R++ FD+E++ L +FD  + +    V    + P   + T +     A+E  + +  +
Sbjct  210  YALRVELFDEEVERLSLFDPLTGQIHYNVPRFTVYPKTHYVTPRERILDAMEKIKQELAE  269

Query  234  TFEVKRDPEHIY--QQVSKGT-----------LPAGIEYWQPLFFS----EPLPPLFSYF  276
              +V    + +   Q+V++ T             +GIE +          EP P LF Y 
Sbjct  270  RRKVLLANDKLVEEQRVTQRTQFDLEMMNELGYCSGIENYSRYLSGRGPGEPPPTLFDYL  329

Query  277  PANTLLV  283
            PA+ LLV
Sbjct  330  PADGLLV  336


>Q8P0J7.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 65.9 bits (159),  Expect = 1e-09, Method: Compositional matrix adjust.
 Identities = 59/235 (25%), Positives = 104/235 (44%), Gaps = 25/235 (11%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            ++ GE  Q LLG  TG      ++++  +   P ++IA +   A +L+ E  +F      
Sbjct  33   IEGGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVIAHNKTLAGQLYGEFKEFFPD---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L  QL    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDTLLNQLVDIQFERNDIDFQRGCFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            FP    E  +R++FF DEID +   +  + +T+ EVD + L PA  F T+   +E
Sbjct  208  FPASRDEHAFRVEFFGDEIDRICEIESLTGKTIGEVDHLVLFPATHFVTNDEHME  262


>B9DSH1.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 65.9 bits (159),  Expect = 1e-09, Method: Compositional matrix adjust.
 Identities = 72/314 (23%), Positives = 134/314 (43%), Gaps = 46/314 (15%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            ++ GE  Q LLG  TG      ++++  +   P ++IA +   A +L+ E  +F  +   
Sbjct  33   IEGGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVIAHNKTLAGQLYGEFKEFFPE---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L  QL    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDQLLNQLVDIQFERNDFDFQRGRFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE-----  225
            FP    E  +R++FF DEID +R  +  + + L E + + L PA  F T+   +E     
Sbjct  208  FPASRDEHAFRIEFFGDEIDRIREIESLTGKILGEAEHLVLFPATHFVTNDEHMEASIAK  267

Query  226  ----------LFRSQWR--DTFEVKRDPEHIYQQVSKGTLPAGIEYWQPLF--FSEPLPP  271
                      +F S+ +  +   +K+  E+  + + +     G+E +       SE  PP
Sbjct  268  IQAELASQLKVFESEGKLLEAQRLKQRTEYDIEMLREMGYTNGVENYSRHMDGRSEGEPP  327

Query  272  --LFSYFPANTLLV  283
              L  +FP + L++
Sbjct  328  YTLLDFFPEDFLIM  341


>Q48SZ1.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 65.9 bits (159),  Expect = 1e-09, Method: Compositional matrix adjust.
 Identities = 59/235 (25%), Positives = 104/235 (44%), Gaps = 25/235 (11%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            ++ GE  Q LLG  TG      ++++  +   P ++IA +   A +L+ E  +F      
Sbjct  33   IEGGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVIAHNKTLAGQLYGEFKEFFPD---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L  QL    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDTLLNQLVDIQFERNDIDFQRGCFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            FP    E  +R++FF DEID +   +  + +T+ EVD + L PA  F T+   +E
Sbjct  208  FPASRDEHAFRVEFFGDEIDRICEIESLTGKTIGEVDHLVLFPATHFVTNDEHME  262


>Q1JBD1.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
 Q1JLB5.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
 P0DH38.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
 P0DH39.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 65.9 bits (159),  Expect = 1e-09, Method: Compositional matrix adjust.
 Identities = 59/235 (25%), Positives = 104/235 (44%), Gaps = 25/235 (11%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            ++ GE  Q LLG  TG      ++++  +   P ++IA +   A +L+ E  +F      
Sbjct  33   IEGGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVIAHNKTLAGQLYGEFKEFFPD---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L  QL    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDTLLNQLVDIQFERNDIDFQRGCFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            FP    E  +R++FF DEID +   +  + +T+ EVD + L PA  F T+   +E
Sbjct  208  FPASRDEHAFRVEFFGDEIDRICEIESLTGKTIGEVDHLVLFPATHFVTNDEHME  262


>A2RE43.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 65.9 bits (159),  Expect = 1e-09, Method: Compositional matrix adjust.
 Identities = 59/235 (25%), Positives = 104/235 (44%), Gaps = 25/235 (11%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            ++ GE  Q LLG  TG      ++++  +   P ++IA +   A +L+ E  +F      
Sbjct  33   IEGGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVIAHNKTLAGQLYGEFKEFFPD---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L  QL    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDTLLNQLVDIQFERNDIDFQRGCFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            FP    E  +R++FF DEID +   +  + +T+ EVD + L PA  F T+   +E
Sbjct  208  FPASRDEHAFRVEFFGDEIDRICEIESLTGKTIGEVDHLVLFPATHFVTNDEHME  262


>Q5XBN4.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 65.5 bits (158),  Expect = 2e-09, Method: Compositional matrix adjust.
 Identities = 71/314 (23%), Positives = 133/314 (42%), Gaps = 46/314 (15%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            ++ GE  Q LLG  TG      ++++  +   P ++IA +   A +L+ E  +F      
Sbjct  33   IEGGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVIAHNKTLAGQLYGEFKEFFPD---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L  QL    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDTLLNQLVDIQFERNDIDFQRGCFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE-----  225
            FP    E  +R++FF DEID +   +  + +T+ EVD + L PA  F T+   +E     
Sbjct  208  FPASRDEHAFRVEFFGDEIDRICEIESLTGKTIGEVDHLVLFPATHFVTNDEHMEQSIAK  267

Query  226  ----------LFRSQWR--DTFEVKRDPEHIYQQVSKGTLPAGIEYWQ----PLFFSEPL  269
                      LF S+ +  +   +++  E+  + + +    +G+E +          EP 
Sbjct  268  IQAELAEQLQLFESEGKLLEAQRLRQRTEYDIEMLREMGYTSGVENYSRHMDGRLPGEPP  327

Query  270  PPLFSYFPANTLLV  283
              L  +FP + L++
Sbjct  328  YTLLDFFPEDFLIM  341


>Q8CWX7.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 65.5 bits (158),  Expect = 2e-09, Method: Compositional matrix adjust.
 Identities = 67/313 (21%), Positives = 133/313 (42%), Gaps = 44/313 (14%)

Query  11   VKAGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN  69
            ++ GE+ ++L   TG      ++++ ++   P ++IA +   A +L+ E  +F      N
Sbjct  33   IEGGEKAQILKGATGTGKTYTMSQVIQKVNKPTLVIAHNKTLAGQLYGEFKEFFPD---N  89

Query  70   LADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNT  112
              ++    YD + P   + SS                 R S    L      +++  V+ 
Sbjct  90   AVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSALLERNDVIVVASVSC  149

Query  113  LMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLF  172
            +     P  +     + ++  Q +SRD L   L    +   D   + G +  RG ++++F
Sbjct  150  IYGLGSPKEYADS-VVSLRPSQEISRDQLLNDLVDIQFERNDIDFQRGRFRVRGDVVEIF  208

Query  173  PMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTD-----------  220
            P    E  +R++FF DEID +R  +  + R L EVD + + PA  F T+           
Sbjct  209  PASRDEHAFRVEFFGDEIDRIREIESLTGRVLGEVDHLAIFPATHFMTNDEHMEVAIAKI  268

Query  221  ----KAAIELFRSQWR--DTFEVKRDPEHIYQQVSKGTLPAGIEYWQPLF--FSEPLPP-  271
                K  + LF ++ +  +   +++  E+  + + +    +G+E +       SE  PP 
Sbjct  269  QKEMKEQVRLFEAEGKLIEAQRIRQRTEYDVEMLREMGYTSGVENYSRHMDGRSEGEPPY  328

Query  272  -LFSYFPANTLLV  283
             L  +FP + L++
Sbjct  329  TLLDFFPEDFLIM  341


>Q99ZA5.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
 B5XLX7.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 65.5 bits (158),  Expect = 2e-09, Method: Compositional matrix adjust.
 Identities = 59/235 (25%), Positives = 104/235 (44%), Gaps = 25/235 (11%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            ++ GE  Q LLG  TG      ++++  +   P ++IA +   A +L+ E  +F      
Sbjct  33   IEGGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVIAHNKTLAGQLYGEFKEFFPD---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L  QL    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDTLLNQLVDIQFERNDIDFQRGCFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            FP    E  +R++FF DEID +   +  + +T+ EVD + L PA  F T+   +E
Sbjct  208  FPASRDEHAFRVEFFGDEIDRICEIESLTGKTIGEVDHLVLFPATHFVTNDEHME  262


>Q1J665.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 65.5 bits (158),  Expect = 2e-09, Method: Compositional matrix adjust.
 Identities = 59/235 (25%), Positives = 104/235 (44%), Gaps = 25/235 (11%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            ++ GE  Q LLG  TG      ++++  +   P ++IA +   A +L+ E  +F      
Sbjct  33   IEGGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVIAHNKTLAGQLYGEFKEFFPD---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L  QL    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDTLLNQLVDIQFERNDIDFQRGCFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            FP    E  +R++FF DEID +   +  + +T+ EVD + L PA  F T+   +E
Sbjct  208  FPASRDEHAFRVEFFGDEIDRICEIESLTGKTIGEVDHLVLFPATHFVTNDEHME  262


>Q9CI06.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=692

 Score = 65.5 bits (158),  Expect = 2e-09, Method: Compositional matrix adjust.
 Identities = 55/234 (24%), Positives = 103/234 (44%), Gaps = 23/234 (10%)

Query  11   VKAGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN  69
            ++ GE+ ++L   TG      ++++  R   P +++A +   A +L+ E  +F      N
Sbjct  34   IENGEKAQILRGATGTGKTYTMSQVIARTGKPTLVMAHNKTLAGQLYSEFKEFFPN---N  90

Query  70   LADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNT  112
              ++    YD + P   + SS                 R S    L      +++  V+ 
Sbjct  91   AVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVSC  150

Query  113  LMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLF  172
            +     P  +     + ++ GQ +SRD L   L    +   D   + G +  RG ++++F
Sbjct  151  IYGLGSPKEY-QDSVVSLRPGQEISRDQLLNDLVGIQFERNDIDFQRGCFRVRGDVVEVF  209

Query  173  PMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            P    E  +R++FF DEID +R  +V + + L EVD + + PA  F T+   +E
Sbjct  210  PASRDEHAFRVEFFGDEIDRIREIEVLTGQVLGEVDHLAIFPATHFMTNDDRME  263


>Q1JGE8.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 65.5 bits (158),  Expect = 2e-09, Method: Compositional matrix adjust.
 Identities = 59/235 (25%), Positives = 104/235 (44%), Gaps = 25/235 (11%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            ++ GE  Q LLG  TG      ++++  +   P ++IA +   A +L+ E  +F      
Sbjct  33   IEGGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVIAHNKTLAGQLYGEFKEFFPD---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATASLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L  QL    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDTLLNQLVDIQFERNDIDFQRGCFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            FP    E  +R++FF DEID +   +  + +T+ EVD + L PA  F T+   +E
Sbjct  208  FPASRDEHAFRVEFFGDEIDRICEIESLTGKTIGEVDHLVLFPATHFVTNDEHME  262


>Q8DYL6.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
 Q8E471.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 64.7 bits (156),  Expect = 3e-09, Method: Compositional matrix adjust.
 Identities = 67/313 (21%), Positives = 133/313 (42%), Gaps = 44/313 (14%)

Query  11   VKAGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN  69
            ++ GE+ ++L   TG      ++++  +   P ++IA +   A +L+ E  +F      N
Sbjct  33   IEGGEKAQILKGATGTGKTYTMSQVIAQVNKPTLVIAHNKTLAGQLYGEFKEFFPD---N  89

Query  70   LADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNT  112
              ++    YD + P   + SS                 R S    L      +++  V+ 
Sbjct  90   AVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVSC  149

Query  113  LMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLF  172
            +     P  +     + ++ GQ +SRD L   L    +   D   + G++  RG ++++F
Sbjct  150  IYGLGSPKEYADS-VVSLRPGQEISRDQLLNNLVDIQFERNDIDFQRGKFRVRGDVVEVF  208

Query  173  PMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTD-----------  220
            P    E  +R++FF DEID +R  +  + R L EV+ + + PA  F T+           
Sbjct  209  PASRDEHAFRIEFFGDEIDRIREIESLTGRVLGEVEHLAIFPATHFMTNDEHMEEAISKI  268

Query  221  ----KAAIELFRSQWR--DTFEVKRDPEHIYQQVSKGTLPAGIEYWQPLF--FSEPLPP-  271
                +  +ELF  + +  +   +++  E+  + + +     G+E +       SE  PP 
Sbjct  269  QAEMENQVELFEKEGKLIEAQRIRQRTEYDIEMLREMGYTNGVENYSRHMDGRSEGEPPF  328

Query  272  -LFSYFPANTLLV  283
             L  +FP + L++
Sbjct  329  TLLDFFPEDFLIM  341


>Q3K051.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 64.7 bits (156),  Expect = 3e-09, Method: Compositional matrix adjust.
 Identities = 67/313 (21%), Positives = 133/313 (42%), Gaps = 44/313 (14%)

Query  11   VKAGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN  69
            ++ GE+ ++L   TG      ++++  +   P ++IA +   A +L+ E  +F      N
Sbjct  33   IEGGEKAQILKGATGTGKTYTMSQVIAQVNKPTLVIAHNKTLAGQLYGEFKEFFPD---N  89

Query  70   LADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNT  112
              ++    YD + P   + SS                 R S    L      +++  V+ 
Sbjct  90   AVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVSC  149

Query  113  LMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLF  172
            +     P  +     + ++ GQ +SRD L   L    +   D   + G++  RG ++++F
Sbjct  150  IYGLGSPKEYADS-VVSLRPGQEISRDQLLNNLVDIQFERNDIDFQRGKFRVRGDVVEVF  208

Query  173  PMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTD-----------  220
            P    E  +R++FF DEID +R  +  + R L EV+ + + PA  F T+           
Sbjct  209  PASRDEHAFRIEFFGDEIDRIREIESLTGRVLGEVEHLAIFPATHFMTNDEHMEEAISKI  268

Query  221  ----KAAIELFRSQWR--DTFEVKRDPEHIYQQVSKGTLPAGIEYWQPLF--FSEPLPP-  271
                +  +ELF  + +  +   +++  E+  + + +     G+E +       SE  PP 
Sbjct  269  QAEMENQVELFEKEGKLIEAQRIRQRTEYDIEMLREMGYTNGVENYSRHMDGRSEGEPPF  328

Query  272  -LFSYFPANTLLV  283
             L  +FP + L++
Sbjct  329  TLLDFFPEDFLIM  341


>B7KC96.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=665

 Score = 64.7 bits (156),  Expect = 4e-09, Method: Compositional matrix adjust.
 Identities = 55/227 (24%), Positives = 101/227 (44%), Gaps = 22/227 (10%)

Query  16   QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLADWET  75
            Q LLG  TG      +A   E+   P +++A +   A +L +E+ QF  +   N  ++  
Sbjct  34   QTLLGA-TGTGKTFTIAATIEKIGKPTLVLAHNKTLAAQLCNELRQFFPE---NAVEYFI  89

Query  76   LPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNTLMQRVC  118
              YD + P   I  S                 R S    L   +  V++  ++ +     
Sbjct  90   SYYDYYQPEAYIPVSDTYIEKSASINDEIDMLRHSATRSLFERRDVVVVASISCIYGLGM  149

Query  119  PHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMGSEL  178
            P  +L   ++ ++ G+ +++  L   L S  Y   D  ++ G +  RG +L+L P   + 
Sbjct  150  PSEYLKA-SIGLEVGKEINQRQLLRDLVSVQYSRNDLDLQRGRFRLRGDVLELVPAYEDR  208

Query  179  PYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
              R++FF DEID++R  D  +  +L+ ++ +N+ PA  F T    +E
Sbjct  209  VIRVEFFGDEIDAIRYLDPVTGNSLQSLERVNIYPARHFVTPDDQLE  255


>B4U3P4.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 64.3 bits (155),  Expect = 4e-09, Method: Compositional matrix adjust.
 Identities = 57/235 (24%), Positives = 104/235 (44%), Gaps = 25/235 (11%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            +++GE  Q LLG  TG      ++++  +   P ++IA +   A +L+ E  +F  +   
Sbjct  33   IESGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVIAHNKTLAGQLYGEFKEFFPE---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L   L    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDQLLNALVDIQFERNDIDFQRGRFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            FP    E  +R++FF DEID +R  +  + + L + D + L PA  F T+   +E
Sbjct  208  FPASRDEHAFRIEFFGDEIDRIREIESLTGKVLGDADHLVLFPATHFVTNDEHME  262


>A4W1F7.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=661

 Score = 64.3 bits (155),  Expect = 5e-09, Method: Compositional matrix adjust.
 Identities = 54/234 (23%), Positives = 103/234 (44%), Gaps = 23/234 (10%)

Query  11   VKAGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN  69
            ++ GE+ ++L   TG      ++++  R   P ++IA +   A +L+ E  +F  +   N
Sbjct  33   IEGGEKAQILMGATGTGKTYTMSQVIARVNKPTLVIAHNKTLAGQLYSEFKEFFPE---N  89

Query  70   LADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNT  112
              ++    YD + P   + SS                 R S    L      +++  V+ 
Sbjct  90   AVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSALLERNDVIVVASVSC  149

Query  113  LMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLF  172
            +     P  +     + ++ GQ +SRD L   L    +   D   + G +  RG ++++F
Sbjct  150  IYGLGSPKEY-SDSVVSLRPGQEISRDQLLNALVDIQFERNDIDFQRGRFRVRGDVVEIF  208

Query  173  PMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            P    E  +R++FF DEID +R  +  + + L +VD + + PA  F T+   +E
Sbjct  209  PASRDEHAFRVEFFGDEIDRIREIESLTGKVLGDVDHLAIFPATHFVTNDDHME  262


>C0MDC6.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 63.9 bits (154),  Expect = 6e-09, Method: Compositional matrix adjust.
 Identities = 57/235 (24%), Positives = 103/235 (44%), Gaps = 25/235 (11%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            ++ GE  Q LLG  TG      ++++  +   P ++IA +   A +L+ E  +F  +   
Sbjct  33   IEGGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVIAHNKTLAGQLYGEFKEFFPE---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L   L    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDQLLNALVDIQFERNDIDFQRGRFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            FP    E  +R++FF DEID +R  +  + + L + D + L PA  F T+   +E
Sbjct  208  FPASRDEHAFRIEFFGDEIDRIREIESLTGKVLGDADHLVLFPATHFVTNDEHME  262


>Q031G7.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=692

 Score = 63.5 bits (153),  Expect = 7e-09, Method: Compositional matrix adjust.
 Identities = 54/234 (23%), Positives = 103/234 (44%), Gaps = 23/234 (10%)

Query  11   VKAGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN  69
            ++ GE+ ++L   TG      ++++  +   P +++A +   A +L+ E  +F      N
Sbjct  34   IENGEKAQILRGATGTGKTYTMSQVIAQTGKPTLVMAHNKTLAGQLYSEFKEFFPN---N  90

Query  70   LADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNT  112
              ++    YD + P   + SS                 R S    L      +++  V+ 
Sbjct  91   AVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVSC  150

Query  113  LMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLF  172
            +     P  +     + ++ GQ +SRD L   L    +   D   + G +  RG ++++F
Sbjct  151  IYGLGSPKEY-QDSVVSLRPGQEISRDQLLNDLVGIQFERNDIDFQRGCFRVRGDVVEVF  209

Query  173  PMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            P    E  +R++FF DEID +R  +V + + L EVD + + PA  F T+   +E
Sbjct  210  PASRDEHAFRVEFFGDEIDRIREIEVLTGQVLGEVDHLAIFPATHFMTNDDRME  263


>A2RIP3.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=692

 Score = 63.5 bits (153),  Expect = 7e-09, Method: Compositional matrix adjust.
 Identities = 54/234 (23%), Positives = 103/234 (44%), Gaps = 23/234 (10%)

Query  11   VKAGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN  69
            ++ GE+ ++L   TG      ++++  +   P +++A +   A +L+ E  +F      N
Sbjct  34   IENGEKAQILRGATGTGKTYTMSQVIAQTGKPTLVMAHNKTLAGQLYSEFKEFFPN---N  90

Query  70   LADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNT  112
              ++    YD + P   + SS                 R S    L      +++  V+ 
Sbjct  91   AVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVSC  150

Query  113  LMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLF  172
            +     P  +     + ++ GQ +SRD L   L    +   D   + G +  RG ++++F
Sbjct  151  IYGLGSPKEY-QDSVVSLRPGQEISRDQLLNDLVGIQFERNDIDFQRGCFRVRGDVVEVF  209

Query  173  PMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            P    E  +R++FF DEID +R  +V + + L EVD + + PA  F T+   +E
Sbjct  210  PASRDEHAFRVEFFGDEIDRIREIEVLTGQVLGEVDHLAIFPATHFMTNDDRME  263


>P44647.1 RecName: Full=Primosomal protein N'; AltName: Full=ATP-dependent 
helicase PriA
Length=730

 Score = 63.2 bits (152),  Expect = 1e-08, Method: Compositional matrix adjust.
 Identities = 53/211 (25%), Positives = 96/211 (45%), Gaps = 23/211 (11%)

Query  625  LVCGDVGFGKTEVAMRAAFLAVDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIEMIS  684
            L+ G  G GKTE+ ++     + + KQV VLVP   L  Q    F+ RF    V I+++ 
Sbjct  222  LLDGVTGSGKTEIYLQYIEEILKSGKQVLVLVPEIGLTPQTVQRFKVRFN---VEIDVLH  278

Query  685  RFRSAKEQTQILAEVAEGKIDILIGTHKLLQSDVKFKDLGLLIVDEEH----------RF  734
               +  ++  +      G+  I+IGT   L +  +F +LG +I+DEEH          R+
Sbjct  279  SNLTDTQRLYVWDRARSGQSAIVIGTRSALFT--QFSNLGAIILDEEHDSSYKQQDSWRY  336

Query  735  GVRHKERIKAMRANVDILTLTATPIPRTLNMAMSGMRDLSIIATPPARRLAVKTFVREYD  794
              R    + A + N+ +L  +ATP   ++N   +G     +++       A++ FV +  
Sbjct  337  HARDLAIVLAQKLNISVLMGSATPSLESINNVQNGKYQHLVLSKRAGNSTALRHFVIDLK  396

Query  795  SLVVREAILREIL--------RGGQVYYLYN  817
            +  ++  + + +L        +G QV    N
Sbjct  397  NQNIQNGLSKPLLERMKAHLEKGNQVLLFLN  427


>C0MBD7.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=663

 Score = 63.2 bits (152),  Expect = 1e-08, Method: Compositional matrix adjust.
 Identities = 56/235 (24%), Positives = 103/235 (44%), Gaps = 25/235 (11%)

Query  11   VKAGE--QRLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVM  68
            ++ GE  Q LLG  TG      ++++  +   P +++A +   A +L+ E  +F  +   
Sbjct  33   IEGGEKAQILLG-ATGTGKTYTMSQVISKVNKPTLVVAHNKTLAGQLYGEFKEFFPE---  88

Query  69   NLADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVN  111
            N  ++    YD + P   + SS                 R S    L      +++  V+
Sbjct  89   NAVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSSLLERNDVIVVASVS  148

Query  112  TLMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDL  171
             +     P  +    A+ ++ GQ +SRD L   L    +   D   + G +  RG ++++
Sbjct  149  CIYGLGSPKEYADS-AVSLRPGQEISRDQLLNALVDIQFERNDIDFQRGRFRVRGDVVEV  207

Query  172  FPMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIE  225
            FP    E  +R++FF DEID +R  +  + + L + D + L PA  F T+   +E
Sbjct  208  FPASRDEHAFRIEFFGDEIDRIREIESLTGKVLGDADHLVLFPATHFVTNDEHME  262


>A8AX17.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=662

 Score = 63.2 bits (152),  Expect = 1e-08, Method: Compositional matrix adjust.
 Identities = 54/235 (23%), Positives = 104/235 (44%), Gaps = 23/235 (10%)

Query  11   VKAGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN  69
            ++ GE+ ++L   TG      ++++  +   P ++IA +   A +L+ E  +F      N
Sbjct  33   IEGGEKAQILMGATGTGKTYTMSQVIAQVNKPTLVIAHNKTLAGQLYGEFKEFFPN---N  89

Query  70   LADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNT  112
              ++    YD + P   + SS                 R S    L      +++  V+ 
Sbjct  90   AVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSALLERNDVIVVASVSC  149

Query  113  LMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLF  172
            +     P  +     + ++ G  +SRD L   L    +   D   + G++  RG ++++F
Sbjct  150  IYGLGSPKEY-SDSVVSLRPGLEISRDKLLNDLVDIQFERNDIDFQRGKFRVRGDVVEIF  208

Query  173  PMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIEL  226
            P    E  +R++FF DEID +R  +  + R L EVD + + PA  F T++  +E+
Sbjct  209  PASRDEHAFRVEFFGDEIDRIREVEALTGRVLGEVDHLAIFPATHFVTNEDHMEV  263


>A3CNJ9.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=662

 Score = 62.8 bits (151),  Expect = 1e-08, Method: Compositional matrix adjust.
 Identities = 54/235 (23%), Positives = 104/235 (44%), Gaps = 23/235 (10%)

Query  11   VKAGEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMN  69
            ++ GE+ ++L   TG      ++++  +   P ++IA +   A +L+ E  +F      N
Sbjct  33   IEGGEKAQILMGATGTGKTYTMSQVIAQVNKPTLVIAHNKTLAGQLYGEFKEFFPN---N  89

Query  70   LADWETLPYDSFSPHQDIISS-----------------RLSTLYQLPTMQRGVLIVPVNT  112
              ++    YD + P   + SS                 R S    L      +++  V+ 
Sbjct  90   AVEYFVSYYDYYQPEAYVPSSDTYIEKDSSVNDEIDKLRHSATSALLERNDVIVVASVSC  149

Query  113  LMQRVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLF  172
            +     P  +     + ++ G  +SRD L   L    +   D   + G++  RG ++++F
Sbjct  150  IYGLGSPKEY-SDSVVSLRPGLEISRDKLLNDLVDIQFERNDIDFQRGKFRVRGDVVEIF  208

Query  173  PMG-SELPYRLDFFDDEIDSLRVFDVDSQRTLEEVDAINLLPAHEFPTDKAAIEL  226
            P    E  +R++FF DEID +R  +  + R L EVD + + PA  F T++  +E+
Sbjct  209  PASRDEHAFRVEFFGDEIDRIREVEALTGRVLGEVDHLAIFPATHFVTNEDHMEV  263


>Q58796.1 RecName: Full=Probable ATP-dependent helicase MJ1401
Length=808

 Score = 62.4 bits (150),  Expect = 2e-08, Method: Compositional matrix adjust.
 Identities = 82/328 (25%), Positives = 141/328 (43%), Gaps = 49/328 (15%)

Query  623  DRLVCGDVGFGKTEVAMRAAFLA-VDNHKQVAVLVPTTLLAQQHYDNFRDRFANWPVRIE  681
            D L+      GKT +   A     +   K+   LVP   LA Q Y  F++R+     ++ 
Sbjct  229  DLLIISATSSGKTLIGELAGIKNLIKTGKKFLFLVPLVALANQKYLEFKERYEKLGFKVS  288

Query  682  M-ISRFRSAKE---QTQILAEVAEGK---IDILIGTHKLLQSDVKFKDLGLLIVDEEHRF  734
            + +   R  K+   +T + A++  G    ID LI T +L       KD+G +++DE H  
Sbjct  289  LRVGLGRIGKKVDVETSLDADIIVGTYEGIDYLIRTKRL-------KDIGTVVIDEIHSL  341

Query  735  GVRHKE--------RIKAMRANVDILTLTAT-PIPRTLNMAMSGMRDLSIIATPPARRLA  785
             +  +         R++ +      + L+AT   P+ L   ++    L      P  R  
Sbjct  342  NLEERGARLDGLIGRLRFLFKEAQKIYLSATIGNPKELAKQLNAKLVLYNGRPVPLERHI  401

Query  786  VKTFVR-EYDSL-VVREAILREI-------LRGGQVYYLYNDVENIQKAAERLAELVPEA  836
            +  F + ++  L +++E + RE         RG  + + Y+     +K AE LA+ +   
Sbjct  402  I--FCKNDFAKLNIIKEIVKREWQNISKFGYRGQCLIFTYS-----RKRAEYLAKALKSK  454

Query  837  RIA--IGHGQMRERELERVMNDFHHQRFNVLVCTTIIETGIDIPTANTIIIER----ADH  890
             I     HG M   +  +V +DF +Q+   +V T  +  G+D P + T+I+E     AD 
Sbjct  455  GIKAEFYHGGMEYIKRRKVEDDFANQKIQCVVTTAALSAGVDFPAS-TVILESLAMGADW  513

Query  891  FGLAQLHQLRGRVGRS--HHQAYAWLLT  916
               A+  Q+ GR GR   H     +LL 
Sbjct  514  LNPAEFQQMCGRAGRKGMHEIGKVYLLV  541


>Q74K90.1 RecName: Full=UvrABC system protein B; Short=Protein UvrB; AltName: 
Full=Excinuclease ABC subunit B
Length=671

 Score = 62.4 bits (150),  Expect = 2e-08, Method: Compositional matrix adjust.
 Identities = 56/246 (23%), Positives = 110/246 (45%), Gaps = 27/246 (11%)

Query  14   GEQ-RLLGELTGAACATLVAEIAERHAGPVVLIAPDMQNALRLHDEISQFTDQMVMNLAD  72
            GE+ ++L   TG      +A +  +   P ++I+ +     +L+ E  +F  +   N  D
Sbjct  36   GEKAQILEGATGTGKTFTMANVIAKLNKPTLVISHNKTLVGQLYGEFKEFFPK---NAVD  92

Query  73   WETLPYDSFSP-----------------HQDIISSRLSTLYQLPTMQRGVLIVPVNTLMQ  115
            +    YD + P                 + +I   R  T   L +    +++  V+ +  
Sbjct  93   YFVSYYDYYQPEAYVPQSDTYIEKDSSINDEIDQLRHKTTSDLMSRNDVIVVASVSCIYG  152

Query  116  RVCPHSFLHGHALVMKKGQRLSRDALRTQLDSAGYRHVDQVMEHGEYATRGALLDLFPMG  175
               P  +     + + +GQ +SRD L   L +  Y   D   + G +  RG ++++FP G
Sbjct  153  LGDPREYA-ASVVSLSEGQEISRDVLLRDLVNIQYDRNDIDFQRGRFRVRGDVVEIFPAG  211

Query  176  -SELPYRLDFFDDEIDSLRVFDVDS--QRTLEEVDAINLLPAHEFPTDKAAIELFRSQWR  232
             S+  +R++FF DEID  R+ +VDS     + E + +++ PA  F T++  +E   +  +
Sbjct  212  YSDHAFRVEFFGDEID--RIVEVDSLTGEVIGEREQVSIFPATHFVTNEQIMERALASIK  269

Query  233  DTFEVK  238
            D   ++
Sbjct  270  DEMNIQ  275


 Score = 35.4 bits (80),  Expect = 3.3, Method: Compositional matrix adjust.
 Identities = 25/92 (27%), Positives = 45/92 (49%), Gaps = 6/92 (7%)

Query  823  QKAAERLAELVPEARIAIGHGQMRERELER--VMNDFHHQRFNVLVCTTIIETGIDIPTA  880
            +K AE L + + +  I + +     + LER  ++ D    +F+VL+   ++  GID+P  
Sbjct  460  KKMAEDLTDYLKDLGIKVRYLHSDIKTLERLEIIRDLRLGKFDVLIGINLLREGIDVPEV  519

Query  881  NTIIIERADHFGLAQ----LHQLRGRVGRSHH  908
            + + I  AD  G  +    L Q  GR  R+ +
Sbjct  520  SLVAILDADKEGFLRSTRPLVQTIGRAARNSN  551


Query= lcl|FM180568.1_prot_CAS08694.1_1146 [gene=yceI] [protein=predicted
protein] [protein_id=CAS08694.1]

Length=121


                                                                   Score     E
Sequences producing significant alignments:                       (Bits)  Value

P0A8X2.1  RecName: Full=Protein YceI; Flags: Precursor             245     1e-83
B7NAT2.1  RecName: Full=Protein YceI; Flags: Precursor             243     5e-83
Q83LI9.1  RecName: Full=Protein YceI; Flags: Precursor             243     6e-83
Q8CW58.1  RecName: Full=Protein YceI; Flags: Precursor             243     6e-83
B4T2Y8.1  RecName: Full=Protein YceI; Flags: Precursor             231     4e-78
B5F951.1  RecName: Full=Protein YceI; Flags: Precursor             231     5e-78
P61351.1  RecName: Full=Protein YceI; Flags: Precursor             231     5e-78
A4W969.1  RecName: Full=UPF0312 protein Ent638_1570; Flags: Pr...  224     3e-75
Q32E67.1  RecName: Full=Protein YceI; Flags: Precursor             223     8e-75
Q6D6A3.1  RecName: Full=UPF0312 protein ECA1782; Flags: Precursor  209     1e-69
C6DKU8.1  RecName: Full=UPF0312 protein PC1_2518; Flags: Precu...  209     2e-69
Q8ZE68.1  RecName: Full=UPF0312 protein YPO2315/YP_2102; Flags...  197     1e-64
A1JLK0.1  RecName: Full=UPF0312 protein YE1254; Flags: Precursor   195     4e-64
A8GD00.1  RecName: Full=UPF0312 protein Spro_1887; Flags: Prec...  191     4e-62
Q9I690.1  RecName: Full=UPF0312 protein PA0423; Flags: Precursor   190     5e-62
Q7N562.1  RecName: Full=UPF0312 protein plu2095; Flags: Precursor  190     8e-62
A6UYN3.1  RecName: Full=UPF0312 protein PSPA7_0523; Flags: Pre...  187     8e-61
C1DI88.1  RecName: Full=UPF0312 protein Avin_03250; Flags: Pre...  177     1e-56
A4VRG3.1  RecName: Full=UPF0312 protein PST_3941; Flags: Precu...  176     1e-56
A4XPC6.1  RecName: Full=UPF0312 protein Pmen_0419; Flags: Prec...  171     2e-54
A6WQU7.1  RecName: Full=UPF0312 protein Shew185_3055; Flags: P...  159     7e-50
A9KXQ8.1  RecName: Full=UPF0312 protein Sbal195_3198; Flags: P...  159     7e-50
A3D710.1  RecName: Full=UPF0312 protein Sbal_3041; Flags: Prec...  157     5e-49
Q12MB6.1  RecName: Full=UPF0312 protein Sden_2128; Flags: Prec...  157     6e-49
Q0HXA7.1  RecName: Full=UPF0312 protein Shewmr7_1249; Flags: P...  154     1e-47
A0KUE5.1  RecName: Full=UPF0312 protein Shewana3_1179; Flags: ...  154     1e-47
Q0HL09.1  RecName: Full=UPF0312 protein Shewmr4_1178; Flags: P...  153     2e-47
A1RHK7.1  RecName: Full=UPF0312 protein Sputw3181_1309; Flags:...  153     3e-47
A4Y8Y8.1  RecName: Full=UPF0312 protein Sputcn32_2702; Flags: ...  153     3e-47
Q4ZZ95.1  RecName: Full=UPF0312 protein Psyr_0457; Flags: Prec...  140     3e-42
Q88D47.2  RecName: Full=UPF0312 protein PP_4981; Flags: Precursor  139     8e-42
Q87V70.1  RecName: Full=UPF0312 protein PSPTO_5071; Flags: Pre...  139     1e-41
Q87HV6.1  RecName: Full=UPF0312 protein VPA0850; Flags: Precursor  138     1e-41
B1J2Y3.1  RecName: Full=UPF0312 protein PputW619_0484; Flags: ...  138     2e-41
Q1I3W0.1  RecName: Full=UPF0312 protein PSEEN5043; Flags: Prec...  138     2e-41
B0KM05.1  RecName: Full=UPF0312 protein PputGB1_5030; Flags: P...  137     3e-41
A7N8H5.1  RecName: Full=UPF0312 protein VIBHAR_05924; Flags: P...  137     6e-41
Q8EBX5.1  RecName: Full=UPF0312 protein SO_3370; Flags: Precursor  136     1e-40
Q4K4H3.1  RecName: Full=UPF0312 protein PFL_5802; Flags: Precu...  136     1e-40
C3K3H1.1  RecName: Full=UPF0312 protein PFLU_5725; Flags: Prec...  135     2e-40
Q7MED4.1  RecName: Full=UPF0312 protein VVA0736; Flags: Precursor  135     4e-40
A5F0B6.1  RecName: Full=UPF0312 protein VC0395_0473/VC395_A078...  131     8e-39
Q9KM50.1  RecName: Full=UPF0312 protein VC_A0539; Flags: Precu...  130     2e-38
Q6G5Y8.1  RecName: Full=UPF0312 protein SAS2572                    52.4    3e-08
Q5HCL0.1  RecName: Full=UPF0312 protein SACOL2711                  51.6    5e-08
Q7A339.1  RecName: Full=UPF0312 protein SA2479                     51.2    8e-08
Q6GDB7.1  RecName: Full=UPF0312 protein SAR2769                    50.8    1e-07
Q2YZA5.1  RecName: Full=UPF0312 protein SAB2563                    50.1    2e-07
P45494.1  RecName: Full=Beta-Ala-Xaa dipeptidase; AltName: Ful...  32.3    0.72 
Q476S9.1  RecName: Full=Multifunctional CCA protein; Includes:...  30.0    4.0  
P50448.1  RecName: Full=Factor XIIa inhibitor; Short=XIIaINH; ...  29.6    5.1  

ALIGNMENTS
>P0A8X2.1 RecName: Full=Protein YceI; Flags: Precursor
 P0A8X3.1 RecName: Full=Protein YceI; Flags: Precursor
 Q31ZB2.1 RecName: Full=Protein YceI; Flags: Precursor
 Q3Z360.1 RecName: Full=Protein YceI; Flags: Precursor
Length=191

 Score = 245 bits (625),  Expect = 1e-83, Method: Compositional matrix adjust.
 Identities = 121/121 (100%), Positives = 121/121 (100%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV
Sbjct  71   VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  130

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ
Sbjct  131  TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  190

Query  121  K  121
            K
Sbjct  191  K  191


>B7NAT2.1 RecName: Full=Protein YceI; Flags: Precursor
Length=191

 Score = 243 bits (621),  Expect = 5e-83, Method: Compositional matrix adjust.
 Identities = 120/121 (99%), Positives = 121/121 (100%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD+LDITGDLTLNGV
Sbjct  71   VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDDLDITGDLTLNGV  130

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ
Sbjct  131  TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  190

Query  121  K  121
            K
Sbjct  191  K  191


>Q83LI9.1 RecName: Full=Protein YceI; Flags: Precursor
Length=191

 Score = 243 bits (620),  Expect = 6e-83, Method: Compositional matrix adjust.
 Identities = 120/121 (99%), Positives = 120/121 (99%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINTTSVDTNHAERDKHLRSADFLNT KYPQATFTSTSVKKDGDELDITGDLTLNGV
Sbjct  71   VNVTINTTSVDTNHAERDKHLRSADFLNTTKYPQATFTSTSVKKDGDELDITGDLTLNGV  130

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ
Sbjct  131  TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  190

Query  121  K  121
            K
Sbjct  191  K  191


>Q8CW58.1 RecName: Full=Protein YceI; Flags: Precursor
Length=191

 Score = 243 bits (620),  Expect = 6e-83, Method: Compositional matrix adjust.
 Identities = 120/121 (99%), Positives = 120/121 (99%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINTTSVDTNH ERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV
Sbjct  71   VNVTINTTSVDTNHTERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  130

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ
Sbjct  131  TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  190

Query  121  K  121
            K
Sbjct  191  K  191


>B4T2Y8.1 RecName: Full=Protein YceI; Flags: Precursor
Length=191

 Score = 231 bits (589),  Expect = 4e-78, Method: Compositional matrix adjust.
 Identities = 112/121 (93%), Positives = 118/121 (98%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINT SVDTNHAERDKHLRSA+FLN AK+PQATFTSTSVKK+GDELDITG+LTLNGV
Sbjct  71   VNVTINTNSVDTNHAERDKHLRSAEFLNVAKFPQATFTSTSVKKEGDELDITGNLTLNGV  130

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVTLEAKL+GQGDDPWGGKRAGFEAEGKIKLKDFNI TDLGPASQEV+LIISVEGVQQ
Sbjct  131  TKPVTLEAKLMGQGDDPWGGKRAGFEAEGKIKLKDFNITTDLGPASQEVELIISVEGVQQ  190

Query  121  K  121
            K
Sbjct  191  K  191


>B5F951.1 RecName: Full=Protein YceI; Flags: Precursor
Length=191

 Score = 231 bits (588),  Expect = 5e-78, Method: Compositional matrix adjust.
 Identities = 112/121 (93%), Positives = 118/121 (98%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINT SVDTNHAERDKHLRSA+FLN AK+PQATFTSTSVKK+GDELDITG+LTLNGV
Sbjct  71   VNVTINTNSVDTNHAERDKHLRSAEFLNVAKFPQATFTSTSVKKEGDELDITGNLTLNGV  130

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVTLEAKL+GQGDDPWGGKRAGFEAEGKIKLKDFNI TDLGPASQEV+LIISVEGVQQ
Sbjct  131  TKPVTLEAKLMGQGDDPWGGKRAGFEAEGKIKLKDFNITTDLGPASQEVELIISVEGVQQ  190

Query  121  K  121
            K
Sbjct  191  K  191


>P61351.1 RecName: Full=Protein YceI; Flags: Precursor
 P61352.1 RecName: Full=Protein YceI; Flags: Precursor
 Q57QK1.1 RecName: Full=Protein YceI; Flags: Precursor
 Q5PGX1.1 RecName: Full=Protein YceI; Flags: Precursor
 A9MH07.1 RecName: Full=Protein YceI; Flags: Precursor
 A9N5Q6.1 RecName: Full=Protein YceI; Flags: Precursor
 B5FL08.1 RecName: Full=Protein YceI; Flags: Precursor
 B5QY08.1 RecName: Full=Protein YceI; Flags: Precursor
 B5RBE3.1 RecName: Full=Protein YceI; Flags: Precursor
 B4TES8.1 RecName: Full=Protein YceI; Flags: Precursor
 B5BBD2.1 RecName: Full=Protein YceI; Flags: Precursor
 B4TSR8.1 RecName: Full=Protein YceI; Flags: Precursor
 C0Q852.1 RecName: Full=Protein YceI; Flags: Precursor
Length=191

 Score = 231 bits (588),  Expect = 5e-78, Method: Compositional matrix adjust.
 Identities = 112/121 (93%), Positives = 118/121 (98%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINT SVDTNHAERDKHLRSA+FLN AK+PQATFTSTSVKK+GDELDITG+LTLNGV
Sbjct  71   VNVTINTNSVDTNHAERDKHLRSAEFLNVAKFPQATFTSTSVKKEGDELDITGNLTLNGV  130

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVTLEAKL+GQGDDPWGGKRAGFEAEGKIKLKDFNI TDLGPASQEV+LIISVEGVQQ
Sbjct  131  TKPVTLEAKLMGQGDDPWGGKRAGFEAEGKIKLKDFNITTDLGPASQEVELIISVEGVQQ  190

Query  121  K  121
            K
Sbjct  191  K  191


>A4W969.1 RecName: Full=UPF0312 protein Ent638_1570; Flags: Precursor
Length=192

 Score = 224 bits (570),  Expect = 3e-75, Method: Compositional matrix adjust.
 Identities = 108/121 (89%), Positives = 115/121 (95%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINT S+DTNHAERDKHLRSA+FLN AK+PQATF ST VKKDG++LDITG+LTLNGV
Sbjct  71   VNVTINTNSLDTNHAERDKHLRSAEFLNVAKFPQATFASTEVKKDGEDLDITGNLTLNGV  130

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVTLEAKLIGQGDDPWGGKRAGFEA GKI+LKDFNI TDLGPASQEVDLIISVEGVQQ
Sbjct  131  TKPVTLEAKLIGQGDDPWGGKRAGFEASGKIRLKDFNITTDLGPASQEVDLIISVEGVQQ  190

Query  121  K  121
            K
Sbjct  191  K  191


>Q32E67.1 RecName: Full=Protein YceI; Flags: Precursor
Length=195

 Score = 223 bits (567),  Expect = 8e-75, Method: Compositional matrix adjust.
 Identities = 109/111 (98%), Positives = 110/111 (99%), Gaps = 0/111 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINTTSVDTNHAERDKHLRSADFLN AKYPQATFTSTSVKKDGDEL+ITGDLTLNGV
Sbjct  71   VNVTINTTSVDTNHAERDKHLRSADFLNAAKYPQATFTSTSVKKDGDELNITGDLTLNGV  130

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDL  111
            TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDL
Sbjct  131  TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDL  181


>Q6D6A3.1 RecName: Full=UPF0312 protein ECA1782; Flags: Precursor
Length=192

 Score = 209 bits (533),  Expect = 1e-69, Method: Compositional matrix adjust.
 Identities = 101/121 (83%), Positives = 112/121 (93%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINT SVDTNHAERDKHLRSA+FLN +K+PQATFTST VKKDGD+ DITG+LTLNGV
Sbjct  72   VNVTINTNSVDTNHAERDKHLRSAEFLNVSKHPQATFTSTEVKKDGDDYDITGNLTLNGV  131

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPV L+AKLIGQGDDPWG  RAGF+AEG IKLKDFNI TDLGPASQ+V+LII+VEGV+Q
Sbjct  132  TKPVKLDAKLIGQGDDPWGNYRAGFQAEGTIKLKDFNITTDLGPASQDVELIIAVEGVRQ  191

Query  121  K  121
            K
Sbjct  192  K  192


>C6DKU8.1 RecName: Full=UPF0312 protein PC1_2518; Flags: Precursor
Length=192

 Score = 209 bits (532),  Expect = 2e-69, Method: Compositional matrix adjust.
 Identities = 101/121 (83%), Positives = 111/121 (92%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINT SVDTNHAERDKHLRSA+FLN  K+PQATFTST VKKDG++ DITG+LTLNGV
Sbjct  72   VNVTINTNSVDTNHAERDKHLRSAEFLNVTKHPQATFTSTEVKKDGEDYDITGNLTLNGV  131

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPV L+AKLIGQGDDPWG  RAGF+AEG IKLKDFNI TDLGPASQEV+LII+VEGV+Q
Sbjct  132  TKPVKLDAKLIGQGDDPWGNYRAGFQAEGTIKLKDFNITTDLGPASQEVELIIAVEGVRQ  191

Query  121  K  121
            K
Sbjct  192  K  192


>Q8ZE68.1 RecName: Full=UPF0312 protein YPO2315/YP_2102; Flags: Precursor
 Q66A98.1 RecName: Full=UPF0312 protein YPTB2234; Flags: Precursor
 A4TIX3.1 RecName: Full=UPF0312 protein YPDSF_0829; Flags: Precursor
 A7FHR8.1 RecName: Full=UPF0312 protein YpsIP31758_1821; Flags: Precursor
 B1JJW1.1 RecName: Full=UPF0312 protein YPK_1931; Flags: Precursor
 A9R8S1.1 RecName: Full=UPF0312 protein YpAngola_A2224; Flags: Precursor
 B2K4S6.1 RecName: Full=UPF0312 protein YPTS_2311; Flags: Precursor
Length=192

 Score = 197 bits (500),  Expect = 1e-64, Method: Compositional matrix adjust.
 Identities = 95/121 (79%), Positives = 103/121 (85%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNV INT SVDTNHAERDKHLR   FLN AK+PQATF ST VKK+GD   + G+LTLNGV
Sbjct  72   VNVVINTNSVDTNHAERDKHLRGKSFLNVAKFPQATFESTEVKKNGDGYSVIGNLTLNGV  131

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVTLE+KL GQG+DPWGG RAGFEA G IKLKDFNI TDLGPASQEV+LI+SVEGVQ 
Sbjct  132  TKPVTLESKLTGQGNDPWGGYRAGFEANGNIKLKDFNITTDLGPASQEVELILSVEGVQV  191

Query  121  K  121
            K
Sbjct  192  K  192


>A1JLK0.1 RecName: Full=UPF0312 protein YE1254; Flags: Precursor
Length=192

 Score = 195 bits (496),  Expect = 4e-64, Method: Compositional matrix adjust.
 Identities = 93/121 (77%), Positives = 104/121 (86%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNV INT SVDTNHAERDKHLRS +FLN  K+PQATFTST VKK+ +   + G+LTLNGV
Sbjct  72   VNVVINTNSVDTNHAERDKHLRSKEFLNVGKFPQATFTSTEVKKNAEGYTVVGNLTLNGV  131

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVTLE+KL GQG+DPWGG RAGFEA G IKLKDFNI TDLGPASQEV+LI+SVEGV+ 
Sbjct  132  TKPVTLESKLTGQGNDPWGGYRAGFEANGNIKLKDFNITTDLGPASQEVELILSVEGVRA  191

Query  121  K  121
            K
Sbjct  192  K  192


>A8GD00.1 RecName: Full=UPF0312 protein Spro_1887; Flags: Precursor
Length=192

 Score = 191 bits (484),  Expect = 4e-62, Method: Compositional matrix adjust.
 Identities = 94/121 (78%), Positives = 104/121 (86%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTINT SVDTNHAERDKHLRSA+FLN  K  QA F ST VKK+G+   + G+LTLNGV
Sbjct  72   VNVTINTASVDTNHAERDKHLRSAEFLNVEKNKQAKFESTEVKKNGEGYAVVGNLTLNGV  131

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVTL+AKLIGQG+DPWGG RAGFEA GKIKLKDF I TDLGPASQ+V+LIISVEGV+ 
Sbjct  132  TKPVTLDAKLIGQGNDPWGGYRAGFEANGKIKLKDFGITTDLGPASQDVELIISVEGVRA  191

Query  121  K  121
            K
Sbjct  192  K  192


>Q9I690.1 RecName: Full=UPF0312 protein PA0423; Flags: Precursor
 Q02TY9.1 RecName: Full=UPF0312 protein PA14_05510; Flags: Precursor
 B7V411.1 RecName: Full=UPF0312 protein PLES_04211; Flags: Precursor
Length=191

 Score = 190 bits (483),  Expect = 5e-62, Method: Compositional matrix adjust.
 Identities = 91/120 (76%), Positives = 102/120 (85%), Gaps = 0/120 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            V VTINT SVDTNHAERDKHLRS DFLN +K P ATF ST VK +GD  DITG+LTLNGV
Sbjct  72   VKVTINTNSVDTNHAERDKHLRSGDFLNVSKNPTATFESTEVKANGDSADITGNLTLNGV  131

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVT++AKLIGQGDDPWGG RAGFE    +KLKDF IK DLGPASQEV+L++SVEG++Q
Sbjct  132  TKPVTIKAKLIGQGDDPWGGYRAGFEGSATLKLKDFGIKMDLGPASQEVELLLSVEGIRQ  191


>Q7N562.1 RecName: Full=UPF0312 protein plu2095; Flags: Precursor
Length=192

 Score = 190 bits (482),  Expect = 8e-62, Method: Compositional matrix adjust.
 Identities = 88/121 (73%), Positives = 102/121 (84%), Gaps = 0/121 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            VNVTI   S+DTNHAERDKHLRS D+ NT KYP+A FTST VKK+G++  +TGDLTLNGV
Sbjct  72   VNVTIKIASLDTNHAERDKHLRSKDYFNTEKYPEAKFTSTEVKKEGEKYVVTGDLTLNGV  131

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPV L A+L+G+G DPWGG RAGFEA GKIKLKDFN K DLGP SQE DL+IS+EGV++
Sbjct  132  TKPVILNAELMGEGKDPWGGYRAGFEASGKIKLKDFNFKADLGPKSQEADLLISIEGVRE  191

Query  121  K  121
            K
Sbjct  192  K  192


>A6UYN3.1 RecName: Full=UPF0312 protein PSPA7_0523; Flags: Precursor
Length=191

 Score = 187 bits (475),  Expect = 8e-61, Method: Compositional matrix adjust.
 Identities = 89/120 (74%), Positives = 101/120 (84%), Gaps = 0/120 (0%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGV  60
            V VTINT SVDTNHAERDKHLRS DFLN  K P ATF ST VK +GD  DITG+LTLNGV
Sbjct  72   VKVTINTNSVDTNHAERDKHLRSGDFLNVGKNPTATFESTEVKANGDSADITGNLTLNGV  131

Query  61   TKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
            TKPVT++AKL+GQG+DPWGG RAGFE    +KLKDF IK DLGPASQEV+L++SVEG++Q
Sbjct  132  TKPVTIKAKLLGQGNDPWGGYRAGFEGSATLKLKDFGIKMDLGPASQEVELLLSVEGIRQ  191


>C1DI88.1 RecName: Full=UPF0312 protein Avin_03250; Flags: Precursor
Length=192

 Score = 177 bits (448),  Expect = 1e-56, Method: Compositional matrix adjust.
 Identities = 86/121 (71%), Positives = 98/121 (81%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDG-DELDITGDLTLNG  59
            V V + T SVD+NHAERDKH+RSADFLN AK+P ATF ST VK  G D  DITG+L+LNG
Sbjct  72   VKVNLKTASVDSNHAERDKHIRSADFLNVAKHPTATFESTGVKSTGQDTFDITGNLSLNG  131

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKPV + A+ IG+G DPWGG RAGFE   K+KLKDF I+ DLGPASQEVDLIISVEGV+
Sbjct  132  VTKPVVIAARFIGEGKDPWGGYRAGFEGGTKLKLKDFGIQKDLGPASQEVDLIISVEGVR  191

Query  120  Q  120
            Q
Sbjct  192  Q  192


>A4VRG3.1 RecName: Full=UPF0312 protein PST_3941; Flags: Precursor
Length=191

 Score = 176 bits (447),  Expect = 1e-56, Method: Compositional matrix adjust.
 Identities = 88/121 (73%), Positives = 98/121 (81%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKK-DGDELDITGDLTLNG  59
            VNVT+ T SVDTNHAERDKHLRS DFLN AK+P ATF STSVK   G   DITG+LTLNG
Sbjct  71   VNVTLKTASVDTNHAERDKHLRSDDFLNVAKHPTATFESTSVKSTGGGTADITGNLTLNG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKPV + A+ IG+GDDPWGG RAGFE    + LKDF+IK DLGPASQ VDLIISVEGV+
Sbjct  131  VTKPVVIAARFIGEGDDPWGGYRAGFEGSTTLTLKDFDIKMDLGPASQTVDLIISVEGVR  190

Query  120  Q  120
            +
Sbjct  191  K  191


>A4XPC6.1 RecName: Full=UPF0312 protein Pmen_0419; Flags: Precursor
Length=191

 Score = 171 bits (433),  Expect = 2e-54, Method: Compositional matrix adjust.
 Identities = 83/121 (69%), Positives = 99/121 (82%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            V+VT+NT SVDTNHAERDKH+RSADFLN +K+  ATF STSVK  G+   DITGDLTLNG
Sbjct  71   VSVTLNTASVDTNHAERDKHIRSADFLNVSKHGTATFESTSVKSTGEGTADITGDLTLNG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKPV + AK IG+G DPWGG RAGFE    +KLKDF+I  DLGPAS+ V+LI+S+EG++
Sbjct  131  VTKPVVIAAKFIGEGKDPWGGYRAGFEGTTTLKLKDFDITKDLGPASETVELILSIEGIR  190

Query  120  Q  120
            Q
Sbjct  191  Q  191


>A6WQU7.1 RecName: Full=UPF0312 protein Shew185_3055; Flags: Precursor
 B8E915.1 RecName: Full=UPF0312 protein Sbal223_1323; Flags: Precursor
Length=191

 Score = 159 bits (403),  Expect = 7e-50, Method: Compositional matrix adjust.
 Identities = 76/121 (63%), Positives = 95/121 (79%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            VNVT+NT SVD+NHAERDKH+RSADFLNT+K+ QATFTST+V+  G+ +L I G+LTLNG
Sbjct  71   VNVTVNTLSVDSNHAERDKHIRSADFLNTSKFAQATFTSTTVEDKGNGDLVINGNLTLNG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+ + A  +G+G DPWGG RAGF       +KDF IK DLGPAS  V+L + VEGV+
Sbjct  131  VTKPLAINAHAVGEGQDPWGGYRAGFTGTTTFAMKDFGIKMDLGPASSHVELDLVVEGVR  190

Query  120  Q  120
            +
Sbjct  191  K  191


>A9KXQ8.1 RecName: Full=UPF0312 protein Sbal195_3198; Flags: Precursor
Length=191

 Score = 159 bits (403),  Expect = 7e-50, Method: Compositional matrix adjust.
 Identities = 76/121 (63%), Positives = 95/121 (79%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            VNVT+NT SVD+NHAERDKH+RSADFLNT+K+ QATFTST+V+  G+ +L I G+LTLNG
Sbjct  71   VNVTVNTLSVDSNHAERDKHIRSADFLNTSKFAQATFTSTTVEDKGNGDLVINGNLTLNG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+ + A  +G+G DPWGG RAGF       +KDF IK DLGPAS  V+L + VEGV+
Sbjct  131  VTKPLAINAHAVGEGQDPWGGYRAGFTGTTTFAMKDFGIKMDLGPASSHVELDLVVEGVR  190

Query  120  Q  120
            +
Sbjct  191  K  191


>A3D710.1 RecName: Full=UPF0312 protein Sbal_3041; Flags: Precursor
Length=191

 Score = 157 bits (397),  Expect = 5e-49, Method: Compositional matrix adjust.
 Identities = 75/121 (62%), Positives = 94/121 (78%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            VNV +NT SVD+NHAERDKH+RSADFLNT+K+ QATFTST+V+  G+ +L I G+LTLNG
Sbjct  71   VNVKVNTLSVDSNHAERDKHIRSADFLNTSKFAQATFTSTTVEDKGNGDLVINGNLTLNG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+ + A  +G+G DPWGG RAGF       +KDF IK DLGPAS  V+L + VEGV+
Sbjct  131  VTKPLAINAHAVGEGQDPWGGYRAGFTGTTTFAMKDFGIKMDLGPASSHVELDLVVEGVR  190

Query  120  Q  120
            +
Sbjct  191  K  191


>Q12MB6.1 RecName: Full=UPF0312 protein Sden_2128; Flags: Precursor
Length=191

 Score = 157 bits (397),  Expect = 6e-49, Method: Compositional matrix adjust.
 Identities = 78/121 (64%), Positives = 92/121 (76%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            V V INT SVD+NHAERDKHLRS DFLNTAK+P A F STSV   G+ +L ITGDL+LNG
Sbjct  71   VEVNINTNSVDSNHAERDKHLRSDDFLNTAKFPAAKFVSTSVADKGNGDLWITGDLSLNG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKPVT++A  +G+G DPWGG RAGF    +  +KDF IK DLGPAS  V L + VEG++
Sbjct  131  VTKPVTIKAHTVGEGQDPWGGYRAGFVGSTEFTMKDFGIKMDLGPASANVKLDLVVEGIK  190

Query  120  Q  120
            Q
Sbjct  191  Q  191


>Q0HXA7.1 RecName: Full=UPF0312 protein Shewmr7_1249; Flags: Precursor
Length=191

 Score = 154 bits (389),  Expect = 1e-47, Method: Compositional matrix adjust.
 Identities = 72/121 (60%), Positives = 93/121 (77%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            VNV +NT SVD+NHAERDKH+RS DFLNTAK+ +ATF STSV+  G+ ++ ITG+ TLNG
Sbjct  71   VNVKVNTLSVDSNHAERDKHIRSGDFLNTAKFAEATFVSTSVEDKGNGDMVITGNFTLNG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+ ++A  +G+G DPWGG RAGF       +KD+ IK DLGPAS  V+L + VEGV+
Sbjct  131  VTKPLAIQAHAVGEGQDPWGGYRAGFTGTTTFAMKDYGIKMDLGPASANVELDLVVEGVR  190

Query  120  Q  120
            +
Sbjct  191  K  191


>A0KUE5.1 RecName: Full=UPF0312 protein Shewana3_1179; Flags: Precursor
Length=191

 Score = 154 bits (388),  Expect = 1e-47, Method: Compositional matrix adjust.
 Identities = 72/121 (60%), Positives = 93/121 (77%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            VNV +NT SVD+NHAERDKH+RS DFLNTAK+ +ATF STSV+  G+ ++ ITG+ TLNG
Sbjct  71   VNVKVNTLSVDSNHAERDKHIRSGDFLNTAKFAEATFVSTSVEDKGNGDMVITGNFTLNG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+ ++A  +G+G DPWGG RAGF       +KD+ IK DLGPAS  V+L + VEGV+
Sbjct  131  VTKPLAIQAHAVGEGQDPWGGYRAGFTGTTTFAMKDYGIKMDLGPASANVELDLVVEGVR  190

Query  120  Q  120
            +
Sbjct  191  K  191


>Q0HL09.1 RecName: Full=UPF0312 protein Shewmr4_1178; Flags: Precursor
Length=191

 Score = 153 bits (387),  Expect = 2e-47, Method: Compositional matrix adjust.
 Identities = 72/121 (60%), Positives = 93/121 (77%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            VNV +NT SVD+NHAERDKH+RS DFLNTAK+ +ATF STSV+  G+ ++ ITG+ TLNG
Sbjct  71   VNVKVNTLSVDSNHAERDKHIRSGDFLNTAKFAEATFVSTSVEDKGNGDMVITGNFTLNG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+ ++A  +G+G DPWGG RAGF       +KD+ IK DLGPAS  V+L + VEGV+
Sbjct  131  VTKPLAIQAHAVGEGQDPWGGYRAGFIGTTTFAMKDYGIKMDLGPASANVELDLVVEGVR  190

Query  120  Q  120
            +
Sbjct  191  K  191


>A1RHK7.1 RecName: Full=UPF0312 protein Sputw3181_1309; Flags: Precursor
Length=191

 Score = 153 bits (386),  Expect = 3e-47, Method: Compositional matrix adjust.
 Identities = 73/121 (60%), Positives = 92/121 (76%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            VNVT+NT SVD+NHAERDKH+R  DFLNT K+ +ATF STSV+  G+ +L I G+LTLNG
Sbjct  71   VNVTVNTLSVDSNHAERDKHIRGEDFLNTGKFAKATFASTSVEDKGNGDLVINGNLTLNG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+ ++A  +G+G DPWGG RAGF       +KDF IK DLGPAS  V+L + VEGV+
Sbjct  131  VTKPLAIKAHAVGEGQDPWGGYRAGFTGTTTFAMKDFGIKMDLGPASSHVELDLVVEGVR  190

Query  120  Q  120
            +
Sbjct  191  K  191


>A4Y8Y8.1 RecName: Full=UPF0312 protein Sputcn32_2702; Flags: Precursor
Length=191

 Score = 153 bits (386),  Expect = 3e-47, Method: Compositional matrix adjust.
 Identities = 73/121 (60%), Positives = 92/121 (76%), Gaps = 1/121 (1%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            VNVT+NT SVD+NHAERDKH+R  DFLNT K+ +ATF STSV+  G+ +L I G+LTLNG
Sbjct  71   VNVTVNTLSVDSNHAERDKHIRGEDFLNTGKFAKATFASTSVEDKGNGDLVINGNLTLNG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+ ++A  +G+G DPWGG RAGF       +KDF IK DLGPAS  V+L + VEGV+
Sbjct  131  VTKPLAIKAHAVGEGQDPWGGYRAGFTGTTTFAMKDFGIKMDLGPASSHVELDLVVEGVR  190

Query  120  Q  120
            +
Sbjct  191  K  191


>Q4ZZ95.1 RecName: Full=UPF0312 protein Psyr_0457; Flags: Precursor
 Q48PB8.1 RecName: Full=UPF0312 protein PSPPH_0448; Flags: Precursor
Length=192

 Score = 140 bits (352),  Expect = 3e-42, Method: Compositional matrix adjust.
 Identities = 70/122 (57%), Positives = 88/122 (72%), Gaps = 2/122 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDE-LDITGDLTLNG  59
            +NV + T S+ TNHAERDKH+ S DFL+ AKYP+A F ST+VK  G++  D+TGDLTL+G
Sbjct  72   INVELKTASLFTNHAERDKHISSKDFLDVAKYPEAKFVSTAVKSTGEKTADVTGDLTLHG  131

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+ ++A   G+G DPWGG RAGF     + L DF IK   GP SQ +DL IS EGVQ
Sbjct  132  VTKPIVIKATFNGEGKDPWGGYRAGFNGTSTLNLNDFGIKGP-GPTSQTLDLDISFEGVQ  190

Query  120  QK  121
            +K
Sbjct  191  KK  192


>Q88D47.2 RecName: Full=UPF0312 protein PP_4981; Flags: Precursor
 A5WA14.1 RecName: Full=UPF0312 protein Pput_4854; Flags: Precursor
Length=192

 Score = 139 bits (350),  Expect = 8e-42, Method: Compositional matrix adjust.
 Identities = 72/122 (59%), Positives = 89/122 (73%), Gaps = 2/122 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDE-LDITGDLTLNG  59
            ++V + T S+ +NHAERDKH+ SADFL+  KYP A F STSVK  GD+  D+TGDLT++G
Sbjct  72   ISVDLKTASLWSNHAERDKHIASADFLDVKKYPDAKFVSTSVKSTGDKTADVTGDLTMHG  131

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKPVT +A   G+G DPWGG+RAGF A   + L DF IK   G  SQ +DL ISVEGV+
Sbjct  132  VTKPVTFKATFNGEGKDPWGGERAGFNATTTLNLNDFGIKGP-GATSQTLDLDISVEGVK  190

Query  120  QK  121
            QK
Sbjct  191  QK  192


>Q87V70.1 RecName: Full=UPF0312 protein PSPTO_5071; Flags: Precursor
Length=192

 Score = 139 bits (349),  Expect = 1e-41, Method: Compositional matrix adjust.
 Identities = 69/122 (57%), Positives = 88/122 (72%), Gaps = 2/122 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDE-LDITGDLTLNG  59
            +NV + T S+ TNHAERDKH+ S DFL+ AKYP+A F ST+VK  G++  D+TGDLTL+G
Sbjct  72   INVELKTASLFTNHAERDKHISSKDFLDVAKYPEAKFVSTAVKSTGEKTADVTGDLTLHG  131

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+ ++A   G+G DPWGG RAGF     + L DF IK   GP SQ +DL I+ EGVQ
Sbjct  132  VTKPIVIKATFNGEGKDPWGGYRAGFNGTSTLNLNDFGIKGP-GPTSQTLDLDITFEGVQ  190

Query  120  QK  121
            +K
Sbjct  191  KK  192


>Q87HV6.1 RecName: Full=UPF0312 protein VPA0850; Flags: Precursor
Length=189

 Score = 138 bits (348),  Expect = 1e-41, Method: Compositional matrix adjust.
 Identities = 66/121 (55%), Positives = 95/121 (79%), Gaps = 3/121 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            VNV ++TTS+D+NHAERDKH+RS DF++  KY +ATF ST V   G+ +LD+TGDLTL+G
Sbjct  71   VNVVVDTTSLDSNHAERDKHIRSGDFIDAGKYSEATFKSTKVVDKGNGKLDVTGDLTLHG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+T+EA+ +G G+DPWGG+RAGF    +++L DF+I   +G +S  VD+ + +EGV+
Sbjct  131  VTKPITIEAEFVGAGNDPWGGERAGFVGTTRLELADFDIPV-MGSSSY-VDMELHIEGVK  188

Query  120  Q  120
            +
Sbjct  189  K  189


>B1J2Y3.1 RecName: Full=UPF0312 protein PputW619_0484; Flags: Precursor
Length=192

 Score = 138 bits (347),  Expect = 2e-41, Method: Compositional matrix adjust.
 Identities = 71/122 (58%), Positives = 90/122 (74%), Gaps = 2/122 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDE-LDITGDLTLNG  59
            ++V + T S+ +NHAERDKH+ SADFL+  KYP+A F ST+VK  G++  D+TGDLTL+G
Sbjct  72   ISVDLKTASLWSNHAERDKHIASADFLDVKKYPEAKFVSTAVKSTGEKTADVTGDLTLHG  131

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKPVT +A   G+G DPWGG+RAGF A   + L DF IK   G  SQ +DL ISVEGV+
Sbjct  132  VTKPVTFKATFNGEGKDPWGGERAGFNATTTLNLNDFGIKGP-GATSQTLDLDISVEGVK  190

Query  120  QK  121
            QK
Sbjct  191  QK  192


>Q1I3W0.1 RecName: Full=UPF0312 protein PSEEN5043; Flags: Precursor
Length=192

 Score = 138 bits (347),  Expect = 2e-41, Method: Compositional matrix adjust.
 Identities = 71/122 (58%), Positives = 89/122 (73%), Gaps = 2/122 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDE-LDITGDLTLNG  59
            ++V + T S+ +NHAERDKH+ S DFL+  KYP+A F STSVK  GD+  D+TGDLT++G
Sbjct  72   ISVDLKTASLWSNHAERDKHIASKDFLDVKKYPEAKFVSTSVKSTGDKTADVTGDLTMHG  131

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKPVT +A   G+G DPWGG+RAGF A   + L DF IK   G  SQ +DL ISVEGV+
Sbjct  132  VTKPVTFKAVFNGEGKDPWGGERAGFNATTTLNLNDFGIKGP-GATSQTLDLDISVEGVK  190

Query  120  QK  121
            QK
Sbjct  191  QK  192


>B0KM05.1 RecName: Full=UPF0312 protein PputGB1_5030; Flags: Precursor
Length=192

 Score = 137 bits (346),  Expect = 3e-41, Method: Compositional matrix adjust.
 Identities = 70/122 (57%), Positives = 90/122 (74%), Gaps = 2/122 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDE-LDITGDLTLNG  59
            ++V + T S+ +NHAERDKH+ SADFL+  KYP+A F ST+VK  G++  D+TGDLT++G
Sbjct  72   ISVDLKTASLWSNHAERDKHIASADFLDVKKYPEAKFVSTAVKSTGEKTADVTGDLTMHG  131

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKPVT +A   G+G DPWGG+RAGF A   + L DF IK   G  SQ +DL ISVEGV+
Sbjct  132  VTKPVTFKATFNGEGKDPWGGERAGFNATTTLNLNDFGIKGP-GATSQTLDLDISVEGVK  190

Query  120  QK  121
            QK
Sbjct  191  QK  192


>A7N8H5.1 RecName: Full=UPF0312 protein VIBHAR_05924; Flags: Precursor
Length=189

 Score = 137 bits (344),  Expect = 6e-41, Method: Compositional matrix adjust.
 Identities = 65/121 (54%), Positives = 94/121 (78%), Gaps = 3/121 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            VNV ++TTS+D+NHAERDKH+RS DF++  KY +ATF ST V   G+ +L +TGDLTL+G
Sbjct  71   VNVVVDTTSLDSNHAERDKHIRSGDFIDAGKYSEATFNSTKVVDKGNGKLGVTGDLTLHG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+T+EA+ +G G+DPWGG+RAGF  + +++L DF I   +G +S  VD+ + +EGV+
Sbjct  131  VTKPITIEAEFVGAGNDPWGGERAGFIGQTRLELADFEIPV-MGSSSY-VDMELHIEGVK  188

Query  120  Q  120
            +
Sbjct  189  K  189


>Q8EBX5.1 RecName: Full=UPF0312 protein SO_3370; Flags: Precursor
Length=191

 Score = 136 bits (343),  Expect = 1e-40, Method: Compositional matrix adjust.
 Identities = 64/111 (58%), Positives = 83/111 (75%), Gaps = 1/111 (1%)

Query  11   DTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNGVTKPVTLEAK  69
            D+NHAERDKH+R  DFLNT K+ +ATF STSV+  G+ +L I G+LTLNGVTKP+ ++A 
Sbjct  81   DSNHAERDKHIRGEDFLNTGKFAKATFASTSVEDKGNGDLVINGNLTLNGVTKPLAIQAH  140

Query  70   LIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQQ  120
             +G+G DPWGG RAGF  +    +KDF IK DLGP S  V+L + VEGV++
Sbjct  141  AVGEGQDPWGGYRAGFTGKTTFAMKDFGIKIDLGPTSSHVELDLVVEGVRK  191


>Q4K4H3.1 RecName: Full=UPF0312 protein PFL_5802; Flags: Precursor
Length=198

 Score = 136 bits (343),  Expect = 1e-40, Method: Compositional matrix adjust.
 Identities = 69/127 (54%), Positives = 82/127 (65%), Gaps = 6/127 (5%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELD------ITGD  54
            + V + T SV TNHAERDKH+ S DFL+  K+  A F STSVK  G   D      + GD
Sbjct  72   IEVNVRTASVFTNHAERDKHITSKDFLDAGKFADAKFVSTSVKPTGKNADGKLTADVAGD  131

Query  55   LTLNGVTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIIS  114
            LTL+GVTKPV ++A  +G+G DPWGG RAGFE    I  +DF    DLGPAS  VDL IS
Sbjct  132  LTLHGVTKPVVVKATFLGEGKDPWGGYRAGFEGTTSINRQDFGKMMDLGPASNNVDLYIS  191

Query  115  VEGVQQK  121
             EGV+ K
Sbjct  192  FEGVKAK  198


>C3K3H1.1 RecName: Full=UPF0312 protein PFLU_5725; Flags: Precursor
Length=192

 Score = 135 bits (341),  Expect = 2e-40, Method: Compositional matrix adjust.
 Identities = 69/122 (57%), Positives = 89/122 (73%), Gaps = 2/122 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDE-LDITGDLTLNG  59
            + V + T S+ +NHAERDKH+ S DFL+ AK+  A F ST+VK  G++  D+TGDLT +G
Sbjct  72   IAVDVKTASLWSNHAERDKHIASKDFLDVAKFADAKFVSTAVKSTGEKTADVTGDLTFHG  131

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKPVT +A   G+G DPWGG+RAGF A+  + L DF IK   GP+SQ VDL IS+EGV+
Sbjct  132  VTKPVTFKATFNGEGKDPWGGERAGFNAKTTVNLNDFGIKGP-GPSSQTVDLDISLEGVK  190

Query  120  QK  121
            QK
Sbjct  191  QK  192


>Q7MED4.1 RecName: Full=UPF0312 protein VVA0736; Flags: Precursor
 Q8D7C6.1 RecName: Full=UPF0312 protein VV2_0231; Flags: Precursor
Length=189

 Score = 135 bits (339),  Expect = 4e-40, Method: Compositional matrix adjust.
 Identities = 65/121 (54%), Positives = 91/121 (75%), Gaps = 3/121 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            VNV ++T S+D+NHAERDKH+RS DF++  K+  ATFTST V   GD +LD+ GDLTL+G
Sbjct  71   VNVVVDTRSLDSNHAERDKHIRSGDFIDAGKFNTATFTSTKVMDKGDGKLDVMGDLTLHG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
            VTKP+T+ A+ +G G DPWGG+RAGF    +++L DFNI   +G +S  VD+ + VEG++
Sbjct  131  VTKPITIAAEFVGAGQDPWGGQRAGFIGTTRLELADFNIPV-MGTSSY-VDMELHVEGIK  188

Query  120  Q  120
            +
Sbjct  189  K  189


>A5F0B6.1 RecName: Full=UPF0312 protein VC0395_0473/VC395_A0785; Flags: 
Precursor
Length=189

 Score = 131 bits (330),  Expect = 8e-39, Method: Compositional matrix adjust.
 Identities = 65/121 (54%), Positives = 90/121 (74%), Gaps = 3/121 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            V V ++T S+D+NHAERDKH+RSADF++ +KY  ATF ST V   G+ +L++ GDLTL+G
Sbjct  71   VVVNVDTRSLDSNHAERDKHIRSADFIDASKYSTATFKSTEVVDKGNGQLEVKGDLTLHG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
             TKP+ + A+ IG G DPWGG+RAGF    +++LKDF I+  +G AS  VD+ + VEGVQ
Sbjct  131  QTKPIVINAEFIGAGQDPWGGQRAGFAGTTRLELKDFGIQV-MG-ASSYVDMELHVEGVQ  188

Query  120  Q  120
            +
Sbjct  189  K  189


>Q9KM50.1 RecName: Full=UPF0312 protein VC_A0539; Flags: Precursor
 C3LVF6.1 RecName: Full=UPF0312 protein VCM66_A0498; Flags: Precursor
Length=189

 Score = 130 bits (327),  Expect = 2e-38, Method: Compositional matrix adjust.
 Identities = 64/121 (53%), Positives = 90/121 (74%), Gaps = 3/121 (2%)

Query  1    VNVTINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGD-ELDITGDLTLNG  59
            V V ++T S+D+NHAERDKH+RSADF++ +KY  ATF ST V   G+ +L++ GDLTL+G
Sbjct  71   VVVNVDTRSLDSNHAERDKHIRSADFIDASKYSTATFKSTEVVDKGNGQLEVKGDLTLHG  130

Query  60   VTKPVTLEAKLIGQGDDPWGGKRAGFEAEGKIKLKDFNIKTDLGPASQEVDLIISVEGVQ  119
             TKP+ + A+ IG G DPWGG+R+GF    +++LKDF I+  +G AS  VD+ + VEGVQ
Sbjct  131  QTKPIVINAEFIGAGQDPWGGQRSGFAGTTRLELKDFGIQV-MG-ASSYVDMELHVEGVQ  188

Query  120  Q  120
            +
Sbjct  189  K  189


>Q6G5Y8.1 RecName: Full=UPF0312 protein SAS2572
 Q8NUH6.1 RecName: Full=UPF0312 protein MW2606
Length=171

 Score = 52.4 bits (124),  Expect = 3e-08, Method: Compositional matrix adjust.
 Identities = 31/96 (32%), Positives = 50/96 (52%), Gaps = 5/96 (5%)

Query  4    TINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGVTKP  63
            TI  +S++T +  RD HL+S DF  T ++ + TF + SV     E  + GDLT+ G+T  
Sbjct  51   TIIPSSINTKNEARDNHLKSGDFFGTDEFDKITFVTKSVS----ESKVVGDLTIKGITNE  106

Query  64   VTLEAKLIGQGDDPWGGKRA-GFEAEGKIKLKDFNI  98
             T + +  G   +P  G +  G    G I  +++ I
Sbjct  107  ETFDVEFNGVSKNPMDGSQVTGVIVTGTINRENYGI  142


>Q5HCL0.1 RecName: Full=UPF0312 protein SACOL2711
 Q2FUS9.1 RecName: Full=UPF0312 protein SAOUHSC_03022
 Q2FDH4.1 RecName: Full=UPF0312 protein SAUSA300_2620
Length=171

 Score = 51.6 bits (122),  Expect = 5e-08, Method: Compositional matrix adjust.
 Identities = 27/80 (34%), Positives = 43/80 (54%), Gaps = 4/80 (5%)

Query  4    TINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGVTKP  63
            TI  +S++T +  RD HL+S DF  T ++ + TF + SV     E  + GDLT+ G+T  
Sbjct  51   TIIPSSINTKNEARDNHLKSGDFFGTDEFDKITFVTKSVS----ESKVVGDLTIKGITNE  106

Query  64   VTLEAKLIGQGDDPWGGKRA  83
             T + +  G   +P  G + 
Sbjct  107  ETFDVEFNGVSKNPMDGSQV  126


>Q7A339.1 RecName: Full=UPF0312 protein SA2479
 Q99QV4.1 RecName: Full=UPF0312 protein SAV2687
Length=171

 Score = 51.2 bits (121),  Expect = 8e-08, Method: Compositional matrix adjust.
 Identities = 30/96 (31%), Positives = 51/96 (53%), Gaps = 5/96 (5%)

Query  4    TINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGVTKP  63
            TI  +S++T +  RD HL+S DF  T ++ + TF + SV ++     + GDLT+ G+T  
Sbjct  51   TIIPSSINTKNEARDNHLKSGDFFGTDEFDKITFETKSVTEN----KVVGDLTIKGITNE  106

Query  64   VTLEAKLIGQGDDPWGGKRA-GFEAEGKIKLKDFNI  98
             T + +  G   +P  G +  G    G I  +++ I
Sbjct  107  ETFDVEFNGVSKNPMDGSQVTGVIVTGTINRENYGI  142


>Q6GDB7.1 RecName: Full=UPF0312 protein SAR2769
Length=171

 Score = 50.8 bits (120),  Expect = 1e-07, Method: Compositional matrix adjust.
 Identities = 26/80 (33%), Positives = 43/80 (54%), Gaps = 4/80 (5%)

Query  4    TINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGVTKP  63
            TI  +S++T +  RD HL+S DF  T ++ + TF + S+     E  + GDLT+ G+T  
Sbjct  51   TIIPSSINTKNEARDNHLKSGDFFGTDEFDKITFVTKSIT----ESKVVGDLTIKGITNE  106

Query  64   VTLEAKLIGQGDDPWGGKRA  83
             T + +  G   +P  G + 
Sbjct  107  ETFDVEFNGVSKNPMDGSQV  126


>Q2YZA5.1 RecName: Full=UPF0312 protein SAB2563
Length=171

 Score = 50.1 bits (118),  Expect = 2e-07, Method: Compositional matrix adjust.
 Identities = 26/80 (33%), Positives = 44/80 (55%), Gaps = 4/80 (5%)

Query  4    TINTTSVDTNHAERDKHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGVTKP  63
            TI  +S++T +  RD HL+S DF  T ++ + TF + SV ++     + GDLT+ G+T  
Sbjct  51   TIIPSSINTKNDARDNHLKSGDFFGTDEFDKITFETKSVTEN----KVVGDLTIKGITNE  106

Query  64   VTLEAKLIGQGDDPWGGKRA  83
             T + +  G   +P  G + 
Sbjct  107  ETFDVEFNGVSKNPMDGSQV  126


>P45494.1 RecName: Full=Beta-Ala-Xaa dipeptidase; AltName: Full=Beta-Ala-His 
dipeptidase; AltName: Full=Peptidase V
Length=470

 Score = 32.3 bits (72),  Expect = 0.72, Method: Compositional matrix adjust.
 Identities = 16/45 (36%), Positives = 23/45 (51%), Gaps = 0/45 (0%)

Query  19   KHLRSADFLNTAKYPQATFTSTSVKKDGDELDITGDLTLNGVTKP  63
            +H   A  LN  +YPQ T   T +K+  D+     D+T NG  +P
Sbjct  338  EHAGKASLLNNVRYPQGTDPDTMIKQVLDKFSGILDVTYNGFEEP  382


>Q476S9.1 RecName: Full=Multifunctional CCA protein; Includes: RecName: 
Full=CCA-adding enzyme; AltName: Full=CCA tRNA nucleotidyltransferase; 
AltName: Full=tRNA CCA-pyrophosphorylase; AltName: 
Full=tRNA adenylyl-/cytidylyl-transferase; AltName: Full=tRNA 
nucleotidyltransferase; AltName: Full=tRNA-NT; Includes: 
RecName: Full=2'-nucleotidase; Includes: RecName: Full=2',3'-cyclic 
phosphodiesterase; Includes: RecName: Full=Phosphatase
Length=415

 Score = 30.0 bits (66),  Expect = 4.0, Method: Composition-based stats.
 Identities = 13/29 (45%), Positives = 19/29 (66%), Gaps = 0/29 (0%)

Query  54   DLTLNGVTKPVTLEAKLIGQGDDPWGGKR  82
            DLT+N + + V  + KL+G   DP GG+R
Sbjct  92   DLTINAMARAVDDDGKLVGPVIDPHGGQR  120


>P50448.1 RecName: Full=Factor XIIa inhibitor; Short=XIIaINH; Flags: Precursor
Length=468

 Score = 29.6 bits (65),  Expect = 5.1, Method: Compositional matrix adjust.
 Identities = 13/42 (31%), Positives = 25/42 (60%), Gaps = 4/42 (10%)

Query  20   HLRSA----DFLNTAKYPQATFTSTSVKKDGDELDITGDLTL  57
            HL+S+      +N+ KYP A+FT  ++ + G  L ++ +L+ 
Sbjct  288  HLKSSAIKVPMMNSKKYPVASFTDRTLNRPGGRLQLSHNLSF  329


Query= lcl|FM180568.1_prot_CAS08763.1_1215 [gene=potD] [protein=polyamine
transporter subunit PotD] [protein_id=CAS08763.1]

Length=348


                                                                   Score     E
Sequences producing significant alignments:                       (Bits)  Value

P0AFK9.1  RecName: Full=Spermidine/putrescine-binding periplas...  707     0.0   
P0A2C7.1  RecName: Full=Spermidine/putrescine-binding periplas...  657     0.0   
P44731.2  RecName: Full=Spermidine/putrescine-binding periplas...  396     4e-137
P45168.1  RecName: Full=Spermidine/putrescine-binding periplas...  372     2e-127
Q9I6J1.1  RecName: Full=Putrescine-binding periplasmic protein...  224     2e-69 
Q9I6J0.1  RecName: Full=Spermidine-binding periplasmic protein...  205     4e-62 
P31133.3  RecName: Full=Putrescine-binding periplasmic protein...  196     1e-58 
Q9KU25.1  RecName: Full=Norspermidine sensor; AltName: Full=No...  75.1    7e-14 

ALIGNMENTS
>P0AFK9.1 RecName: Full=Spermidine/putrescine-binding periplasmic protein; 
Short=SPBP; Flags: Precursor
 P0AFL0.1 RecName: Full=Spermidine/putrescine-binding periplasmic protein; 
Short=SPBP; Flags: Precursor
Length=348

 Score = 707 bits (1826),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 346/348 (99%), Positives = 348/348 (100%), Gaps = 0/348 (0%)

Query  1    MKKWSRHLLAAGALALGMSAAHADDNNTLYFYNWTEYVPPGLLEQFTKETGIKVIYSTYE  60
            MKKWSRHLLAAGALALGMSAAHADDNNTLYFYNWTEYVPPGLLEQFTKETGIKVIYSTYE
Sbjct  1    MKKWSRHLLAAGALALGMSAAHADDNNTLYFYNWTEYVPPGLLEQFTKETGIKVIYSTYE  60

Query  61   SNETMYAKLKTYKDGAYDLVVPSTYYVDKMRKEGMIQKIDKSKLSNFSNLDPDMLNKPFD  120
            SNETMYAKLKTYKDGAYDLVVPSTYYVDKMRKEGMIQKIDKSKL+NFSNLDPDMLNKPFD
Sbjct  61   SNETMYAKLKTYKDGAYDLVVPSTYYVDKMRKEGMIQKIDKSKLTNFSNLDPDMLNKPFD  120

Query  121  PNNDYSIPYIWGATAIGVNGDAVDPKSVTSWADLWKPEYKGSLLLTDDAREVFQMALRKL  180
            PNNDYSIPYIWGATAIGVNGDAVDPKSVTSWADLWKPEYKGSLLLTDDAREVFQMALRKL
Sbjct  121  PNNDYSIPYIWGATAIGVNGDAVDPKSVTSWADLWKPEYKGSLLLTDDAREVFQMALRKL  180

Query  181  GYSGNTTDPKEIEAAYNELKKLMPNVAAFNSDNPANPYMEGEVNLGMIWNGSAFVARQAG  240
            GYSGNTTDPKEIEAAYNELKKLMPNVAAFNSDNPANPYMEGEVNLGMIWNGSAFVARQAG
Sbjct  181  GYSGNTTDPKEIEAAYNELKKLMPNVAAFNSDNPANPYMEGEVNLGMIWNGSAFVARQAG  240

Query  241  TPIDVVWPKEGGIFWMDSLAIPANAKNKEGALKLINFLLRPDVAKQVAETIGYPTPNLAA  300
            TPIDVVWPKEGGIFWMDSLAIPANAKNKEGALKLINFLLRPDVAKQVAETIGYPTPNLAA
Sbjct  241  TPIDVVWPKEGGIFWMDSLAIPANAKNKEGALKLINFLLRPDVAKQVAETIGYPTPNLAA  300

Query  301  RKLLSPEVANDKTLYPDAETIKNGEWQNDVGSASSIYEEYYQKLKAGR  348
            RKLLSPEVANDKTLYPDAETIKNGEWQNDVG+ASSIYEEYYQKLKAGR
Sbjct  301  RKLLSPEVANDKTLYPDAETIKNGEWQNDVGAASSIYEEYYQKLKAGR  348


>P0A2C7.1 RecName: Full=Spermidine/putrescine-binding periplasmic protein; 
Short=SPBP; Flags: Precursor
 P0A2C8.1 RecName: Full=Spermidine/putrescine-binding periplasmic protein; 
Short=SPBP; Flags: Precursor
Length=348

 Score = 657 bits (1695),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 326/348 (94%), Positives = 340/348 (98%), Gaps = 0/348 (0%)

Query  1    MKKWSRHLLAAGALALGMSAAHADDNNTLYFYNWTEYVPPGLLEQFTKETGIKVIYSTYE  60
            MKKWSRHLLAAGALALGMSAAHA DN+TLYFYNWTEYVPPGLLEQFTKETGIKVIYSTYE
Sbjct  1    MKKWSRHLLAAGALALGMSAAHASDNDTLYFYNWTEYVPPGLLEQFTKETGIKVIYSTYE  60

Query  61   SNETMYAKLKTYKDGAYDLVVPSTYYVDKMRKEGMIQKIDKSKLSNFSNLDPDMLNKPFD  120
            SNETMYAKLKTYKDGAYDLVVPSTYYVDKMRKEGMIQKIDKSKL+NF NLDP+MLNKPFD
Sbjct  61   SNETMYAKLKTYKDGAYDLVVPSTYYVDKMRKEGMIQKIDKSKLTNFHNLDPEMLNKPFD  120

Query  121  PNNDYSIPYIWGATAIGVNGDAVDPKSVTSWADLWKPEYKGSLLLTDDAREVFQMALRKL  180
            PNNDYS+PYIWGATAIGVN DA+DPK++TSWADLWKPEYK SLLLTDDAREVFQMALRKL
Sbjct  121  PNNDYSVPYIWGATAIGVNSDAIDPKTITSWADLWKPEYKNSLLLTDDAREVFQMALRKL  180

Query  181  GYSGNTTDPKEIEAAYNELKKLMPNVAAFNSDNPANPYMEGEVNLGMIWNGSAFVARQAG  240
            GYSGNTTDPKEIEAAY ELKKLMPNVAAFNSDNPANPYMEGEVNLGM+WNGSAFVARQAG
Sbjct  181  GYSGNTTDPKEIEAAYEELKKLMPNVAAFNSDNPANPYMEGEVNLGMVWNGSAFVARQAG  240

Query  241  TPIDVVWPKEGGIFWMDSLAIPANAKNKEGALKLINFLLRPDVAKQVAETIGYPTPNLAA  300
            TP++VVWPKEGGIFWMDSLAIPANAKNKEGALKLINFLLRPDVAK+VAETIGYPTPNLAA
Sbjct  241  TPLEVVWPKEGGIFWMDSLAIPANAKNKEGALKLINFLLRPDVAKEVAETIGYPTPNLAA  300

Query  301  RKLLSPEVANDKTLYPDAETIKNGEWQNDVGSASSIYEEYYQKLKAGR  348
            RKLLSPEVANDK+LYPDA+TI  GEWQNDVG AS+IYEEYYQKLKAGR
Sbjct  301  RKLLSPEVANDKSLYPDAQTISKGEWQNDVGDASAIYEEYYQKLKAGR  348


>P44731.2 RecName: Full=Spermidine/putrescine-binding periplasmic protein 
2; Short=SPBP; Flags: Precursor
Length=350

 Score = 396 bits (1017),  Expect = 4e-137, Method: Compositional matrix adjust.
 Identities = 199/349 (57%), Positives = 253/349 (72%), Gaps = 3/349 (1%)

Query  1    MKKWSRHLLAAGALAL-GMSAAHADDNNTLYFYNWTEYVPPGLLEQFTKETGIKVIYSTY  59
            MKK+  H L    L+   + AA A  NN LY YNWT+YVP  L+ QF+KETGI+VIYST+
Sbjct  1    MKKFFAHSLKNLFLSTTALFAASAFANNKLYVYNWTDYVPSDLVAQFSKETGIEVIYSTF  60

Query  60   ESNETMYAKLKTYKD--GAYDLVVPSTYYVDKMRKEGMIQKIDKSKLSNFSNLDPDMLNK  117
            ESNE MYAKLK  ++    YDLV PS+YYV+KM KE M+Q ID+SKL+N   +   +LNK
Sbjct  61   ESNEEMYAKLKLTQNTGSGYDLVFPSSYYVNKMIKEKMLQPIDQSKLTNIHQIPKHLLNK  120

Query  118  PFDPNNDYSIPYIWGATAIGVNGDAVDPKSVTSWADLWKPEYKGSLLLTDDAREVFQMAL  177
             FDP N YS+PY++G T I VN D +DPK++TSWADLWKPE+KG +L+T DAREVF +AL
Sbjct  121  EFDPENKYSLPYVYGLTGIEVNADEIDPKTITSWADLWKPEFKGKVLMTSDAREVFHVAL  180

Query  178  RKLGYSGNTTDPKEIEAAYNELKKLMPNVAAFNSDNPANPYMEGEVNLGMIWNGSAFVAR  237
               G S NTT+ ++I+ AY  L+KL+PNVA FNSD+P  PY++GEV +GMIWNGSA++A+
Sbjct  181  LLDGKSPNTTNEEDIKTAYERLEKLLPNVATFNSDSPEVPYVQGEVAIGMIWNGSAYLAQ  240

Query  238  QAGTPIDVVWPKEGGIFWMDSLAIPANAKNKEGALKLINFLLRPDVAKQVAETIGYPTPN  297
            +    +  V+PKEG IFWMD+ AIP  AKN EGA K I+FLLRP+ AK V E +G+  PN
Sbjct  241  KENQSLQFVYPKEGAIFWMDNYAIPTTAKNVEGAHKFIDFLLRPENAKIVIERMGFSMPN  300

Query  298  LAARKLLSPEVANDKTLYPDAETIKNGEWQNDVGSASSIYEEYYQKLKA  346
              A+ LLS EVAND  L+P AE ++ G  Q DVG A  IYE+Y+ KLK 
Sbjct  301  NGAKTLLSAEVANDPKLFPPAEEVEKGIMQGDVGEAVDIYEKYWGKLKT  349


>P45168.1 RecName: Full=Spermidine/putrescine-binding periplasmic protein 
1; Short=SPBP; Flags: Precursor
Length=360

 Score = 372 bits (955),  Expect = 2e-127, Method: Compositional matrix adjust.
 Identities = 185/361 (51%), Positives = 246/361 (68%), Gaps = 14/361 (4%)

Query  1    MKKWSRHLLAAGALALGMSAAHADD------------NNTLYFYNWTEYVPPGLLEQFTK  48
            MKK++  L+ A  +A  ++A +  D            N+T+Y Y WTEYVP GLL++FTK
Sbjct  1    MKKFA-GLITASFVAATLTACNDKDAKQETAKATAAANDTVYLYTWTEYVPDGLLDEFTK  59

Query  49   ETGIKVIYSTYESNETMYAKLKTY-KDGAYDLVVPSTYYVDKMRKEGMIQKIDKSKLSNF  107
            ETGIKVI S+ ESNETMYAKLKT  + G YD++ PS Y+V KM +EGM++++D SKL   
Sbjct  60   ETGIKVIVSSLESNETMYAKLKTQGESGGYDVIAPSNYFVSKMAREGMLKELDHSKLPVL  119

Query  108  SNLDPDMLNKPFDPNNDYSIPYIWGATAIGVNGDAVDPKSVTSWADLWKPEYKGSLLLTD  167
              LDPD LNKP+D  N YS+P + GA  I  N +    +  TSWADLWKPE+   + L D
Sbjct  120  KELDPDWLNKPYDKGNKYSLPQLLGAPGIAFNTNTYKGEQFTSWADLWKPEFANKVQLLD  179

Query  168  DAREVFQMALRKLGYSGNTTDPKEIEAAYNELKKLMPNVAAFNSDNPANPYMEGEVNLGM  227
            DAREVF +AL K+G   NT DP  I+ AY EL KL PNV +FNSDNPAN ++ GEV +G 
Sbjct  180  DAREVFNIALLKIGQDPNTQDPAIIKQAYEELLKLRPNVLSFNSDNPANSFISGEVEVGQ  239

Query  228  IWNGSAFVARQAGTPIDVVWPKEGGIFWMDSLAIPANAKNKEGALKLINFLLRPDVAKQV  287
            +WNGS  +A++   P+++V+PKEG + W+D+LAIPA AKN EGA KLIN++L    A+++
Sbjct  240  LWNGSVRIAKKEKAPLNMVFPKEGPVLWVDTLAIPATAKNSEGAHKLINYMLGKKTAEKL  299

Query  288  AETIGYPTPNLAARKLLSPEVANDKTLYPDAETIKNGEWQNDVGSASSIYEEYYQKLKAG  347
               IGYPT N+ A+K L  E+  D  +YP A+ +KN  WQ+DVG A   YE+YYQ+LKA 
Sbjct  300  TLAIGYPTSNIEAKKALPKEITEDPAIYPSADILKNSHWQDDVGDAIQFYEQYYQELKAA  359

Query  348  R  348
            +
Sbjct  360  K  360


>Q9I6J1.1 RecName: Full=Putrescine-binding periplasmic protein SpuD; Flags: 
Precursor
 Q02UB7.1 RecName: Full=Putrescine-binding periplasmic protein SpuD; Flags: 
Precursor
Length=367

 Score = 224 bits (571),  Expect = 2e-69, Method: Compositional matrix adjust.
 Identities = 134/343 (39%), Positives = 202/343 (59%), Gaps = 25/343 (7%)

Query  1    MKKWSRHLLA---AGALALGMSAAHADDNNTLYFYNWTEYVPPGLLEQFTKETGIKVIYS  57
            MK++ + LLA   AG++A GM  A A DN  L+ YNW++Y+ P  LE+FTKETGIKV+Y 
Sbjct  2    MKRFGKTLLALTLAGSVA-GM--AQAADNKVLHVYNWSDYIAPDTLEKFTKETGIKVVYD  58

Query  58   TYESNETMYAKLKTYKDGAYDLVVPSTYYVDKMRKEGMIQKIDKSKLSNFSNLDPDMLN-  116
             Y+SNE + AKL   K G YD+VVPS  ++ K  K G+ QK+DKSKL N+ NL+ D+++ 
Sbjct  59   VYDSNEVLEAKLLAGKSG-YDVVVPSNSFLAKQIKAGVYQKLDKSKLPNWKNLNKDLMHT  117

Query  117  -KPFDPNNDYSIPYIWGATAIGVNGDAV-----DPKSVTSWADLWKPE-----YKGSLLL  165
             +  DP N+++IPY+WG   IG N D V     D   V SW  ++KPE      +  +  
Sbjct  118  LEVSDPGNEHAIPYMWGTIGIGYNPDKVKAAFGDNAPVDSWDLVFKPENIQKLKQCGVSF  177

Query  166  TDDAREVFQMALRKLGYSGNTTDPKEIEAAYNELKKLMPNVAAFNSDNPANPYMEGEVNL  225
             D   E+   AL  LGY  +T +PKE++AA     K+ P V  F+S    +    G + +
Sbjct  178  LDSPTEILPAALHYLGYKPDTDNPKELKAAEELFLKIRPYVTYFHSSKYISDLANGNICV  237

Query  226  GMIWNGSAFVAR----QAGTPIDVVW--PKEGGIFWMDSLAIPANAKNKEGALKLINFLL  279
             + ++G  + A+    +A   + V +  PKEG   + D +AIP +A+N EGAL  +NFL+
Sbjct  238  AIGYSGDIYQAKSRAEEAKNKVTVKYNIPKEGAGSFFDMVAIPKDAENTEGALAFVNFLM  297

Query  280  RPDVAKQVAETIGYPTPNLAARKLLSPEVANDKTLYPDAETIK  322
            +P++  ++ + + +P  N AA  L+S  + ND  +YP  E +K
Sbjct  298  KPEIMAEITDVVQFPNGNAAATPLVSEAIRNDPGIYPSEEVMK  340


>Q9I6J0.1 RecName: Full=Spermidine-binding periplasmic protein SpuE; Flags: 
Precursor
Length=365

 Score = 205 bits (521),  Expect = 4e-62, Method: Compositional matrix adjust.
 Identities = 121/325 (37%), Positives = 180/325 (55%), Gaps = 18/325 (6%)

Query  9    LAAGALALGMSAAHADDNNTLYFYNWTEYVPPGLLEQFTKETGIKVIYSTYESNETMYAK  68
            L   ALA  ++     +  +L+ YNWT+Y+ P  L+ FTKE+GI V Y  ++SNET+  K
Sbjct  9    LLVAALATAIAGPVQAEKKSLHIYNWTDYIAPTTLKDFTKESGIDVSYDVFDSNETLEGK  68

Query  69   LKTYKDGAYDLVVPSTYYVDKMRKEGMIQKIDKSKLSNFSNLDPDMLNK--PFDPNNDYS  126
            L +   G YD+VVPS  ++ K  + G  QK+DKSKL N+ NLDP +L +    DP N Y+
Sbjct  69   LVSGHSG-YDIVVPSNNFLGKQIQAGAFQKLDKSKLPNWKNLDPALLKQLEVSDPGNQYA  127

Query  127  IPYIWGATAIGVN----GDAVDPKSVTSWADLWKPE-----YKGSLLLTDDAREVFQMAL  177
            +PY+WG   IG N     + +  + + SWA L++PE      K  +   D   E+   AL
Sbjct  128  VPYLWGTNGIGYNVAKVKEVLGDQPIDSWAILFEPENMKKLAKCGVAFMDSGDEMLPAAL  187

Query  178  RKLGYSGNTTDPKEIEAAYNELKKLMPNVAAFNSDNPANPYMEGEVNLGMIWNGSAFVA-  236
              LG   NT DPK+ + A   L K+ P V+ F+S    +    G + +   ++G  F A 
Sbjct  188  NYLGLDPNTHDPKDYKKAEEVLTKVRPYVSYFHSSKYISDLANGNICVAFGYSGDVFQAA  247

Query  237  ---RQAGTPIDV--VWPKEGGIFWMDSLAIPANAKNKEGALKLINFLLRPDVAKQVAETI  291
                +AG  ID+  V PKEG   W D +AIPA+AK  + A   I++LLRP+V  +V++ +
Sbjct  248  ARAEEAGKGIDIQYVIPKEGANLWFDLMAIPADAKAADNAYAFIDYLLRPEVIAKVSDYV  307

Query  292  GYPTPNLAARKLLSPEVANDKTLYP  316
            GY      AR L+   V++ + +YP
Sbjct  308  GYANAIPGARPLMDKSVSDSEEVYP  332


>P31133.3 RecName: Full=Putrescine-binding periplasmic protein; Flags: 
Precursor
Length=370

 Score = 196 bits (499),  Expect = 1e-58, Method: Compositional matrix adjust.
 Identities = 120/338 (36%), Positives = 183/338 (54%), Gaps = 21/338 (6%)

Query  2    KKWSRHLLAAGALALGMSAAHADDNNTLYFYNWTEYVPPGLLEQFTKETGIKVIYSTYES  61
            KKW   L+A   +A+ +    A+   TL+ YNW++Y+ P  +  F KETGIKV+Y  ++S
Sbjct  6    KKWLSGLVAGALMAVSVGTLAAE-QKTLHIYNWSDYIAPDTVANFEKETGIKVVYDVFDS  64

Query  62   NETMYAKLKTYKDGAYDLVVPSTYYVDKMRKEGMIQKIDKSKLSNFSNLDPDMLN--KPF  119
            NE +  KL     G +DLVVPS  ++++    G+ Q +DKSKL  + NLDP++L      
Sbjct  65   NEVLEGKLMAGSTG-FDLVVPSASFLERQLTAGVFQPLDKSKLPEWKNLDPELLKLVAKH  123

Query  120  DPNNDYSIPYIWGATAIGVNGDAV-----DPKSVTSWADLWKPE-----YKGSLLLTDDA  169
            DP+N +++PY+W  T IG N D V     +   V SW  + KPE         +   D  
Sbjct  124  DPDNKFAMPYMWATTGIGYNVDKVKAVLGENAPVDSWDLILKPENLEKLKSCGVSFLDAP  183

Query  170  REVFQMALRKLGYSGNTTDPKEIEA-AYNELKKLMPNVAAFNSDNPANPYMEGEVNLGMI  228
             EVF   L  LG   N+T   +    A + L KL PN+  F+S    N    G++ + + 
Sbjct  184  EEVFATVLNYLGKDPNSTKADDYTGPATDLLLKLRPNIRYFHSSQYINDLANGDICVAIG  243

Query  229  WNGSAFVA----RQAGTPIDVVW--PKEGGIFWMDSLAIPANAKNKEGALKLINFLLRPD  282
            W G  + A    ++A   ++V +  PKEG + + D  A+PA+AKNK+ A + +N+LLRPD
Sbjct  244  WAGDVWQASNRAKEAKNGVNVSFSIPKEGAMAFFDVFAMPADAKNKDEAYQFLNYLLRPD  303

Query  283  VAKQVAETIGYPTPNLAARKLLSPEVANDKTLYPDAET  320
            V   +++ + Y   N AA  L+S EV  +  +YP A+ 
Sbjct  304  VVAHISDHVFYANANKAATPLVSAEVRENPGIYPPADV  341


>Q9KU25.1 RecName: Full=Norspermidine sensor; AltName: Full=Norspermidine-binding 
protein; Flags: Precursor
Length=359

 Score = 75.1 bits (183),  Expect = 7e-14, Method: Compositional matrix adjust.
 Identities = 69/305 (23%), Positives = 134/305 (44%), Gaps = 19/305 (6%)

Query  29   LYFYNWTEYVPPGLLEQFTKETGIKVIYSTYESNETMYAKLKTYKDGAYDLVVPSTYYVD  88
            L  Y W + + P ++E + K+TG+ V    +++++     +       +D++V       
Sbjct  36   LNVYLWEDTIAPSVVEAWHKKTGVSVNLFHFDNDDERSLLMLKSVQLPFDIMVLDNVSAF  95

Query  89   KMRKEGMIQKIDKSKLSNFSNLDPDMLNKPFDPNNDYSIPYIWGATAIGVNGDAVDPKSV  148
               ++ + +  D + L N +N DP  L         +++PY WG+  I       D K  
Sbjct  96   IFSRQNVFE--DLTALPNRANNDPMWLQA----CGTHAVPYFWGSVGIAYRKSLFD-KPP  148

Query  149  TSWADL--WKPEYKGSLLLTDDAREVFQMALRKLGYSGNTTDPKEIEAAYNELKKLMPNV  206
            T W+++    P ++G + +  D+ E    AL  L  S  T     +  AY  L    P++
Sbjct  149  TQWSEVVDIAPAHRGRVGMLKDSVETLLPALYMLNASPITDSIDTLRQAYRLLDAANPHI  208

Query  207  AAFN---SDNPANPYMEGEVNLGMIWNGSAFVARQAGTPIDVVW----PKEGGIFWMDSL  259
              +    S   ++P  +  +++ + ++G  +   +     D  W    P+     W+D +
Sbjct  209  LTYEYVLSYVRSHPQTDN-LHMAVSYSGDHYSLNRFFNTQD--WDFSVPEGRPYLWVDCM  265

Query  260  AIPANAKNKEGALKLINFLLRPDVAKQVAETIGYPTPNLAARKLLSPEVANDKTLYPDAE  319
            A+ + + N   A   ++FL++PD+A   AE I   +PN  AR LL  E   D ++Y   +
Sbjct  266  AVNSVSPNTVQAKAFLDFLMKPDIAAINAEYIRAASPNYKARALLPVEHREDLSIYLPEQ  325

Query  320  TIKNG  324
             +  G
Sbjct  326  RLAEG  330


Query= lcl|FM180568.1_prot_CAS08742.1_1194 [gene=fhuE]
[protein=ferric-rhodotorulic acid outer membrane transporter]
[protein_id=CAS08742.1]

Length=729


                                                                   Score     E
Sequences producing significant alignments:                       (Bits)  Value

P16869.2  RecName: Full=FhuE receptor; AltName: Full=Outer-mem...  1481    0.0   
P38047.1  RecName: Full=Ferric-pseudobactin BN7/BN8 receptor; ...  419     1e-134
P25184.1  RecName: Full=Ferric-pseudobactin 358 receptor; Flag...  412     1e-131
P48632.2  RecName: Full=Ferripyoverdine receptor; Flags: Precu...  397     8e-126
P42512.1  RecName: Full=Fe(3+)-pyochelin receptor; AltName: Fu...  298     3e-89 
Q08017.1  RecName: Full=Ferric-pseudobactin M114 receptor PbuA...  287     3e-84 
Q47162.2  RecName: Full=Ferrichrysobactin receptor; Flags: Pre...  105     3e-22 
O86241.1  RecName: Full=Uncharacterized TonB-dependent recepto...  65.9    3e-10 
Q8CW90.1  RecName: Full=Catecholate siderophore receptor Fiu; ...  62.0    1e-08 
Q1REC0.1  RecName: Full=Catecholate siderophore receptor Fiu; ...  62.0    1e-08 
Q8X7W7.1  RecName: Full=Catecholate siderophore receptor Fiu; ...  61.6    2e-08 
P75780.1  RecName: Full=Catecholate siderophore receptor Fiu; ...  61.6    2e-08 
Q05098.1  RecName: Full=Ferric enterobactin receptor; Flags: P...  48.5    2e-04 
A1JTG3.1  RecName: Full=Pesticin receptor; AltName: Full=IPR65...  43.1    0.009 
P0C2M9.1  RecName: Full=Pesticin receptor; AltName: Full=IPR65...  42.7    0.009 
P46359.2  RecName: Full=Pesticin receptor; AltName: Full=IRPC;...  41.6    0.025 
Q6LLU3.1  RecName: Full=Vitamin B12 transporter BtuB; AltName:...  39.3    0.11  
Q4KMC8.1  RecName: Full=Fructose-bisphosphate aldolase C-A; Al...  34.7    2.6   
Q8PTK1.1  RecName: Full=DNA ligase 2; AltName: Full=Polydeoxyr...  33.1    9.0   

ALIGNMENTS
>P16869.2 RecName: Full=FhuE receptor; AltName: Full=Outer-membrane receptor 
for Fe(III)-coprogen, Fe(III)-ferrioxamine B and Fe(III)-rhodotrulic 
acid; Flags: Precursor
Length=729

 Score = 1481 bits (3835),  Expect = 0.0, Method: Compositional matrix adjust.
 Identities = 716/729 (98%), Positives = 720/729 (99%), Gaps = 0/729 (0%)

Query  1    MLSTQFNRDNQHQTTSKPSLLAACIALALLPSAAFAAPATEETVIVEGSATTPVDDENDY  60
            MLSTQFNRDNQ+Q  +KPSLLA CIALALLPSAAFAAPATEETVIVEGSAT P D ENDY
Sbjct  1    MLSTQFNRDNQYQAITKPSLLAGCIALALLPSAAFAAPATEETVIVEGSATAPDDGENDY  60

Query  61   SVTSTSAGTKMQMTQRDIPQSVTIVSQQRMEDQQLQTLGEVMENTLGISKSQADSDRALY  120
            SVTSTSAGTKMQMTQRDIPQSVTIVSQQRMEDQQLQTLGEVMENTLGISKSQADSDRALY
Sbjct  61   SVTSTSAGTKMQMTQRDIPQSVTIVSQQRMEDQQLQTLGEVMENTLGISKSQADSDRALY  120

Query  121  YSRGFQIDNYMVDGIPTYFESRWNLGDALSDMALFERVEVVRGATGLMTGTGNPSAAINM  180
            YSRGFQIDNYMVDGIPTYFESRWNLGDALSDMALFERVEVVRGATGLMTGTGNPSAAINM
Sbjct  121  YSRGFQIDNYMVDGIPTYFESRWNLGDALSDMALFERVEVVRGATGLMTGTGNPSAAINM  180

Query  181  VRKHATSREFKGDVSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNS  240
            VRKHATSREFKGDVSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNS
Sbjct  181  VRKHATSREFKGDVSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNS  240

Query  241  EKTFFSGIVDADLGDLTTLSAGYEYQRIDVNSPTWGGLPRWNTDGSGNSYDRARSTAPDW  300
            EKTFFSGIVDADLGDLTTLSAGYEYQRIDVNSPTWGGLPRWNTDGS NSYDRARSTAPDW
Sbjct  241  EKTFFSGIVDADLGDLTTLSAGYEYQRIDVNSPTWGGLPRWNTDGSSNSYDRARSTAPDW  300

Query  301  AYNDKEINKVFMTLKQRFADTWQATLNATHSEVEFDSKMMYVDAYVNKADGMLVGPYSNY  360
            AYNDKEINKVFMTLKQ+FADTWQATLNATHSEVEFDSKMMYVDAYVNKADGMLVGPYSNY
Sbjct  301  AYNDKEINKVFMTLKQQFADTWQATLNATHSEVEFDSKMMYVDAYVNKADGMLVGPYSNY  360

Query  361  GPGFDYVGGTGWNSGKRKVDALDLFADGSYELFGRQHNLMFGGSYSKQNNRYFSSWANIF  420
            GPGFDYVGGTGWNSGKRKVDALDLFADGSYELFGRQHNLMFGGSYSKQNNRYFSSWANIF
Sbjct  361  GPGFDYVGGTGWNSGKRKVDALDLFADGSYELFGRQHNLMFGGSYSKQNNRYFSSWANIF  420

Query  421  PDEIGSFYNFNGNFPQTDWSPQSLAQDDTTHMKSLYAATRVTLADPLHLILGARYTNWRV  480
            PDEIGSFYNFNGNFPQTDWSPQSLAQDDTTHMKSLYAATRVTLADPLHLILGARYTNWRV
Sbjct  421  PDEIGSFYNFNGNFPQTDWSPQSLAQDDTTHMKSLYAATRVTLADPLHLILGARYTNWRV  480

Query  481  DTLTYSMEKNHTTPYAGLVFDINDNWSTYASYTSIFQPQKDRDSSGKYLAPITGNNYELG  540
            DTLTYSMEKNHTTPYAGLVFDINDNWSTYASYTSIFQPQ DRDSSGKYLAPITGNNYELG
Sbjct  481  DTLTYSMEKNHTTPYAGLVFDINDNWSTYASYTSIFQPQNDRDSSGKYLAPITGNNYELG  540

Query  541  LKSDWMNSRLTTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAI  600
            LKSDWMNSRLTTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAI
Sbjct  541  LKSDWMNSRLTTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAI  600

Query  601  TDNWQLTFGATRYIAEDNEGNAVNPNLPRTTIKMFTSYRLPVMPELTVGGGVNWQNRVYT  660
            TDNWQLTFGATRYIAEDNEGNAVNPNLPRTT+KMFTSYRLPVMPELTVGGGVNWQNRVYT
Sbjct  601  TDNWQLTFGATRYIAEDNEGNAVNPNLPRTTVKMFTSYRLPVMPELTVGGGVNWQNRVYT  660

Query  661  DTVTPYGTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDTNVEGSIVYGAPRN  720
            DTVTPYGTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDTNVEGSIVYG PRN
Sbjct  661  DTVTPYGTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDTNVEGSIVYGTPRN  720

Query  721  FSITGTYQF  729
            FSITGTYQF
Sbjct  721  FSITGTYQF  729


>P38047.1 RecName: Full=Ferric-pseudobactin BN7/BN8 receptor; Flags: Precursor
Length=809

 Score = 419 bits (1078),  Expect = 1e-134, Method: Compositional matrix adjust.
 Identities = 248/682 (36%), Positives = 372/682 (55%), Gaps = 56/682 (8%)

Query  70   KMQMTQRDIPQSVTIVSQQRMEDQQLQTLGEVMENTLGIS--KSQADSDRALYYSRGFQI  127
            ++ +T R+ PQS+T++++QR++DQ+L  L + +E T GI+  +    S+   Y+SRGF I
Sbjct  162  RLNLTPRETPQSLTVMTRQRLDDQRLTNLTDALEATPGITVVRDGLGSESDSYWSRGFAI  221

Query  128  DNYMVDGIPTYFESRWNLGDALSDMALFERVEVVRGATGLMTGTGNPSAAINMVRKHATS  187
             NY VDG+PT       L +    MA+F+RVE+VRGATGL++G GNPSA IN++RK  T+
Sbjct  222  QNYEVDGVPTSTR----LDNYSQSMAMFDRVEIVRGATGLISGMGNPSATINLIRKRPTA  277

Query  188  REFKGDVSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNSEKTFFSG  247
             E +  ++ E G+W++     D+  PLTE G IR R V  Y+   +W+DRYN +     G
Sbjct  278  -EAQASITGEAGNWDRYGTGFDVSGPLTETGNIRGRFVADYKTEKAWIDRYNQQSQLMYG  336

Query  248  IVDADLGDLTTLSAGYEYQRIDVNSPTWGGLPRWNTDGSGNSYDRARSTAPDWAYNDKEI  307
            I + DL + T L+ G+ Y R D++SP   GLP   + G   +  R+ + APDW+YND E 
Sbjct  337  ITEFDLSEDTLLTVGFSYLRSDIDSPLRSGLPTRFSTGERTNLKRSLNAAPDWSYNDHEQ  396

Query  308  NKVFMTLKQRFADTWQATLNATHSEVEFDSKMMYVDAYVNK-ADGMLVGPYSNYGPGFDY  366
               F +++Q+  + W   +  TH+E +FD    +    +N    G+   P          
Sbjct  397  TSFFTSIEQQLGNGWSGKIELTHAENKFDELFNFAMGELNPDGSGLSQLPVR--------  448

Query  367  VGGTGWNSGKRKVDALDLFADGSYELFGRQHNLMFGGSYS--KQNNRYFSSW----ANIF  420
                   SG  + D LDL+A G + LFGR+H L+ G + S  ++N   +  W    A   
Sbjct  449  ------FSGTPRQDNLDLYATGPFSLFGREHELITGMTLSQYRENTPSWGGWRYDYAGSP  502

Query  421  PDEIGSFYNFNGNFPQTDWSPQSLAQDDTTHMKSLYAATRVTLADPLHLILGARYTNWRV  480
               I + +N++G   +  +     +  D     + Y  +R ++ D L LILG+R  NW+ 
Sbjct  503  AGAIDNLFNWDGKSAKPAFVESGKSSIDEDQYAA-YLTSRFSVTDDLSLILGSRLINWKR  561

Query  481  DT--LTYSMEKNHT--------TPYAGLVFDINDNWSTYASYTSIFQPQKD--RDSSGKY  528
            DT    Y  E+            PYAG+ +D++D WS YASYT IF PQ     D S K 
Sbjct  562  DTSDRPYGGEETEVNREENGVFIPYAGVGYDLDDTWSLYASYTKIFNPQGAWVTDESNKP  621

Query  529  LAPITGNNYELGLKSDWMNSRLTTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTV  588
            L P+ G  YELG+K   +N +L ++LA+F++EQDN+A            +  Y A   T 
Sbjct  622  LDPMEGVGYELGIKGTHLNGKLNSSLAVFKLEQDNLAI--------WQHDNVYSAEQDTT  673

Query  589  SKGVEFELNGAITDNWQLTFGATRYIAEDNEGNAVNPNLPRTTIKMFTSYRLP-VMPELT  647
            SKG+E ELNG + + WQ + G +  +  D +   +N NLPR + K FTSYRL   + ++T
Sbjct  674  SKGIELELNGELAEGWQASAGYSYSVTTDADDQRINTNLPRNSFKTFTSYRLHGPLDKIT  733

Query  648  VGGGVNWQNRVYTDTVTPYGTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDT  707
            +GGGVNWQ++V  D  T        QGSYA+ +L  RY + ++ S   N+NN+FD+ Y +
Sbjct  734  IGGGVNWQSKVGADLHT------FSQGSYAVTNLMARYDINQHLSASVNLNNVFDREYYS  787

Query  708  NVEGSIVYGAPRNFSITGTYQF  729
                  VYG PRN   +  Y F
Sbjct  788  QSGLYGVYGTPRNVMTSFKYSF  809


>P25184.1 RecName: Full=Ferric-pseudobactin 358 receptor; Flags: Precursor
Length=819

 Score = 412 bits (1059),  Expect = 1e-131, Method: Compositional matrix adjust.
 Identities = 246/685 (36%), Positives = 377/685 (55%), Gaps = 32/685 (5%)

Query  60   YSVTSTSAGTKMQMTQRDIPQSVTIVSQQRMEDQQLQTLGEVMENTLGISKSQADSDRAL  119
            Y+   TS  TKM ++ R+ PQ++T+V++QRM+DQ L ++ EV+  T GI+ SQ   +R  
Sbjct  152  YTTRVTSTATKMNLSIRETPQTITVVTRQRMDDQHLGSMNEVLTQTPGITMSQDGGERFN  211

Query  120  YYSRGFQIDNYMVDGIPTYFESR-WNLGDALSDMALFERVEVVRGATGLMTGTGNPSAAI  178
             YSRG  I+ Y  DG+ TY +++  N+   L D+ L++R+E+VRGATGLMTG G+PSA +
Sbjct  212  IYSRGSAINIYQFDGVTTYQDNQTRNMPSTLMDVGLYDRIEIVRGATGLMTGAGDPSAVV  271

Query  179  NMVRKHATSREFKGDVSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRY  238
            N++RK  T REFK  + A  GSW+  R  AD+  PLT+DG++R R     Q+N +++D Y
Sbjct  272  NVIRKRPT-REFKSHIQAGVGSWDYYRAEADVSGPLTDDGRVRGRFFAAKQDNHTFMDWY  330

Query  239  NSEKTFFSGIVDADLGDLTTLSAGYEYQRIDVNSPTWGGLPRWNTDGSGNSYDRARSTAP  298
              ++    G+V+AD+ D T    G + Q   VN     G+P   T+G   ++ R+ S+  
Sbjct  331  TQDRDVLYGVVEADVTDTTVARFGIDRQTYKVNGAP--GVPIIYTNGQPTNFSRSTSSDA  388

Query  299  DWAYNDKEINKVFMTLKQRFADTWQATLNATHSEVEFDSKMMYVDAYVNKADGMLVGPYS  358
             W Y+D         L+Q+ A  WQ  L A + +V+ DS   Y     N++   L G   
Sbjct  389  RWGYDDYTTTNYTFGLEQQLAHDWQFKLAAAYMDVDRDSFSSYYSTTTNRSYLELDGSTE  448

Query  359  NYGPGFDYVGGTGWNSGKRKVDALDLFADGSYELFGRQHNLMFGGSYSKQNNRYFSSWAN  418
                        G  + K+    +D    G ++L G+ H L+ G +Y +  N++      
Sbjct  449  I---------SAGIVTAKQHQKGVDATLQGPFQLLGQTHELIVGYNYLEYENKHRGDSG-  498

Query  419  IFPDEIGSFYNFNGNFPQT--DWSPQSLAQDDTTHMKSLYAATRVTLADPLHLILGARYT  476
              PD   +FY+++   P+   D     +  + +      + A+R  L D LHLILGAR +
Sbjct  499  --PDVNINFYDWDNQTPKPGDDEIIPGIQYNISNRQSGYFVASRFNLTDDLHLILGARAS  556

Query  477  NWRVDTLTYSM----------EKNHTTPYAGLVFDINDNWSTYASYTSIFQPQKDRDSSG  526
            N+R D   + +          E+   TPYAG+V+D+ +  S YASYT IF+PQ + D +G
Sbjct  557  NYRFDYALWRIGNEPAPYKMVERGVVTPYAGIVYDLTNEQSVYASYTDIFKPQNNVDITG  616

Query  527  KYLAPITGNNYELGLKSDWMNSRLTTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDG  586
            K L P  G NYELG K +++  RL   +A++ +++DN+A+ST   +P S G  A +AVDG
Sbjct  617  KPLDPEVGKNYELGWKGEFLEGRLNANIALYMVKRDNLAESTNEVVPDSGGLIASRAVDG  676

Query  587  TVSKGVEFELNGAITDNWQLTFGATRYIAEDNEGNAVNPNLPRTTIKMFTSYRLPVMPE-  645
              +KGV+ EL+G +   W +  G +    ED +G  + P LP  T + + +YRLP   E 
Sbjct  677  AETKGVDVELSGEVLPGWNVFTGYSHTRTEDADGKRLTPQLPMDTFRFWNTYRLPGEWEK  736

Query  646  LTVGGGVNWQNRVYTDTVTPYGTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTY  705
            LT+GGGVNW ++  T     Y +    Q  Y +  L  RY++ ++ +   NVNN+FDK Y
Sbjct  737  LTLGGGVNWNSKS-TLNFARYNS-HVTQDDYFVTSLMARYRINESLAATLNVNNIFDKKY  794

Query  706  DTNVEGSI-VYGAPRNFSITGTYQF  729
               + GS   YGAPRN ++T  Y F
Sbjct  795  YAGMAGSYGHYGAPRNATVTLRYDF  819


>P48632.2 RecName: Full=Ferripyoverdine receptor; Flags: Precursor
Length=815

 Score = 397 bits (1019),  Expect = 8e-126, Method: Compositional matrix adjust.
 Identities = 257/727 (35%), Positives = 386/727 (53%), Gaps = 48/727 (7%)

Query  28   ALLPSAAFAAPATEE---TVIVEGSATTPVDDENDYSVTSTSAGTKMQMTQRDIPQSVTI  84
            A+  S A AA ++ +   T+I      T  +D   Y+  + +  T++ +T R+ PQS+T+
Sbjct  112  AITISVAEAADSSVDLGATMITSNQLGTITEDSGSYTPGTIATATRLVLTPRETPQSITV  171

Query  85   VSQQRMEDQQLQTLGEVMENTLGISKSQADSDRALYYSRGFQIDNYMVDGIP-TYFESRW  143
            V++Q M+D  L  + +VM +T GI+ S  D+DR  YY+RGF I+N+  DGIP T     +
Sbjct  172  VTRQNMDDFGLNNIDDVMRHTPGITVSAYDTDRNNYYARGFSINNFQYDGIPSTARNVGY  231

Query  144  NLGDALSDMALFERVEVVRGATGLMTGTGNPSAAINMVRKHATSREFKGDVSAEYGSWNK  203
            + G+ LSDMA+++RVEV++GATGL+TG G+  A IN++RK  T  EFKG V    GSW+ 
Sbjct  232  SAGNTLSDMAIYDRVEVLKGATGLLTGAGSLGATINLIRKKPT-HEFKGHVELGAGSWDN  290

Query  204  ERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNSEKTFFSGIVDADLGDLTTLSAGY  263
             R   D+  PLTE G +R R V  YQ+  S++D Y  + + + GI++ DL   T L+ G 
Sbjct  291  YRSELDVSGPLTESGNVRGRAVAAYQDKHSFMDHYERKTSVYYGILEFDLNPDTMLTVGA  350

Query  264  EYQRIDVNSPTW-GGLPRWNTDGSGNSYDRARSTAPDWAYNDKEINKVFMTLKQRFADTW  322
            +YQ  D     W G  P +++ G+ N   R+ +    W+  ++    VF  L+  FA+ W
Sbjct  351  DYQDNDPKGSGWSGSFPLFDSQGNRNDVSRSFNNGAKWSSWEQYTRTVFANLEHNFANGW  410

Query  323  QATLNATHSEVEFDSKMMYVDAYVNKADGMLVGPYSNYGPGFDYVGGTGWNSGKRKVDAL  382
                     +V+ D K+    A +    G ++G +         V      +G+ K ++L
Sbjct  411  VG-------KVQLDHKINGYHAPL----GAIMGDWPAPDNSAKIVAQK--YTGETKSNSL  457

Query  383  DLFADGSYELFGRQHNLMFGGSYSKQNNRYFSSWANI-------FPDEIGSFYNFNGNFP  435
            D++  G ++  GR+H L+ G S S      FS W          + +    F N++G+  
Sbjct  458  DIYLTGPFQFLGREHELVVGTSAS------FSHWEGKSYWNLRNYDNTTDDFINWDGDIG  511

Query  436  QTDWSPQSLAQDDTTHMKSLYAATRVTLADPLHLILGARYTNWRVDTLTYSM-EKNHTTP  494
            + DW   S   DD T     Y   R  + D L+L LG R  ++RV  L  ++ E     P
Sbjct  512  KPDWGTPSQYIDDKTRQLGSYMTARFNVTDDLNLFLGGRVVDYRVTGLNPTIRESGRFIP  571

Query  495  YAGLVFDINDNWSTYASYTSIFQPQKD--RDSSGKYLAPITGNNYELGLKSDWMNSRLTT  552
            Y G V+D+ND +S YASYT IF PQ    RDSS K L P  G NYE+G+K ++++ RL T
Sbjct  572  YVGAVYDLNDTYSVYASYTDIFMPQDSWYRDSSNKLLEPDEGQNYEIGIKGEYLDGRLNT  631

Query  553  TLAIFRIEQDNVAQSTG--TPIPGSNGET-AYKAVDGTVSKGVEFELNGAITDNWQLTFG  609
            +LA F I ++N A+        P +   T AYK +    +KG E E++G +   WQ+  G
Sbjct  632  SLAYFEIHEENRAEEDALYNSKPTNPAITYAYKGIKAK-TKGYEAEISGELAPGWQVQAG  690

Query  610  ATRYIAEDNEGNAVNPNLPRTTIKMFTSYRLP-VMPELTVGGGVNWQNR----VYTDTVT  664
             T  I  D+ G  V+   P+  + ++TSY+    + +LTVGGG  WQ +    VY +  +
Sbjct  691  YTHKIIRDDSGKKVSTWEPQDQLSLYTSYKFKGALDKLTVGGGARWQGKSWQMVYNNPRS  750

Query  665  PYGTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDTNVE--GSIVYGAPRNFS  722
             +  F  E   Y LVDL  RYQ+T   S   NVNN+FDKTY TN+    S  YG PRN  
Sbjct  751  RWEKFSQED--YWLVDLMARYQITDKLSASVNVNNVFDKTYYTNIGFYTSASYGDPRNLM  808

Query  723  ITGTYQF  729
             +  + F
Sbjct  809  FSTRWDF  815


>P42512.1 RecName: Full=Fe(3+)-pyochelin receptor; AltName: Full=Fe(III)-pyochelin 
receptor; Flags: Precursor
Length=720

 Score = 298 bits (762),  Expect = 3e-89, Method: Compositional matrix adjust.
 Identities = 205/669 (31%), Positives = 340/669 (51%), Gaps = 38/669 (6%)

Query  70   KMQMTQRDIPQSVTIVSQQRMEDQQLQTLGEVMENTLGISKSQADSDRALYYSRGFQIDN  129
            K+ +  R++PQS +++  +R+E Q L +L E M+   G++          YY RGF++D+
Sbjct  71   KVPLKPRELPQSASVIDHERLEQQNLFSLDEAMQQATGVTVQPFQLLTTAYYVRGFKVDS  130

Query  130  YMVDGIPTYFESRWNLGDALSDMALFERVEVVRGATGLMTGTGNPSAAINMVRKHATSRE  189
            + +DG+P       N   +  DMA++ERVE++RG+ GL+ GTGNP+A +N+VRK    RE
Sbjct  131  FELDGVPALLG---NTASSPQDMAIYERVEILRGSNGLLHGTGNPAATVNLVRKRP-QRE  186

Query  190  FKGDVSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNSEKTFFSGIV  249
            F    +   G W++ R   D+  PL+  G +R R V  Y++ D + D  +       G+ 
Sbjct  187  FAASTTLSAGRWDRYRAEVDVGGPLSASGNVRGRAVAAYEDRDYFYDVADQGTRLLYGVT  246

Query  250  DADLGDLTTLSAGYEYQRIDVNSPTWGGLPRWNTDGSGNSYDRARSTAPDWAYNDKEINK  309
            + DL   T L+ G +YQ ID  +    G+P    DGS     R      DW     +  +
Sbjct  247  EFDLSPDTLLTVGAQYQHIDSIT-NMAGVPM-AKDGSNLGLSRDTYLDVDWDRFKWDTYR  304

Query  310  VFMTLKQRFADTWQATLNATHSEVEFDSKMMYVDAYVNKADGMLVGPYSNYGPGFDYVGG  369
             F +L+Q+    W+  ++A + E   DS++ Y  ++        + P +  G G   +G 
Sbjct  305  AFGSLEQQLGGGWKGKVSAEYQEA--DSRLRYAGSF------GAIDPQT--GDGGQLMGA  354

Query  370  T-GWNSGKRKVDALDLFADGSYELFGRQHNLMFGGSYSKQNNRYFSSWANIFPDEIGSFY  428
               + S +R +DA     +G   LFG  H L+ G +Y++   R  ++     P+   + Y
Sbjct  355  AYKFKSIQRSLDA---NLNGPVRLFGLTHELLGGVTYAQGETRQDTARFLNLPNTPVNVY  411

Query  429  NFNGN-FPQTDWSPQSLAQDDTTHMKSLYAATRVTLADPLHLILGARYTNWRVDTLTYSM  487
             ++ +  P+      +     TT  K LYA  R+ LA+PL L++G R + W  DT     
Sbjct  412  RWDPHGVPRPQIGQYTSPGTTTTTQKGLYALGRIKLAEPLTLVVGGRESWWDQDTPATRF  471

Query  488  EKNHT-TPYAGLVFDINDNWSTYASYTSIFQPQKDRDS-SGKYLAPITGNNYELGLKSDW  545
            +     TPY GL++D   +WS Y SY  ++QPQ DR + + + L+P+ G  YE G+K + 
Sbjct  472  KPGRQFTPYGGLIWDFARDWSWYVSYAEVYQPQADRQTWNSEPLSPVEGKTYETGIKGEL  531

Query  546  MNSRLTTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAITDNWQ  605
             + RL  +LA FRI+ +N  Q      PG      Y +     S+G E E  G +T  W 
Sbjct  532  ADGRLNLSLAAFRIDLENNPQED-PDHPGPPNNPFYISGGKVRSQGFELEGTGYLTPYWS  590

Query  606  L----TFGATRYI--AEDNEGNAVNPNLPRTTIKMFTSYRLPVMP-ELTVGGGVNWQNRV  658
            L    T+ +T Y+  ++++ G   +   PR  ++++++Y LP      +VGGG+  Q   
Sbjct  591  LSAGYTYTSTEYLKDSQNDSGTRYSTFTPRHLLRLWSNYDLPWQDRRWSVGGGLQAQ---  647

Query  659  YTDTVTPYGTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTY---DTNVEGSIVY  715
             +D    Y      QG YALV++   Y++ ++++   NVNNLFD+TY    +N   +  Y
Sbjct  648  -SDYSVDYRGVSMRQGGYALVNMRLGYKIDEHWTAAVNVNNLFDRTYYQSLSNPNWNNRY  706

Query  716  GAPRNFSIT  724
            G PR+F+++
Sbjct  707  GEPRSFNVS  715


>Q08017.1 RecName: Full=Ferric-pseudobactin M114 receptor PbuA; Flags: 
Precursor
Length=826

 Score = 287 bits (734),  Expect = 3e-84, Method: Compositional matrix adjust.
 Identities = 230/761 (30%), Positives = 360/761 (47%), Gaps = 86/761 (11%)

Query  5    QFNRDNQHQTTSKPSLLAACIALALLPSAAFAAPATEETVIVEGSATTPVDDENDYSVTS  64
            ++ RD    T   P   A   A+ L P+   A+     T   EGS        N Y+   
Sbjct  106  RYQRDGNTVTVLGP---ATGSAMELAPTNVNASRLGATT---EGS--------NSYTTGG  151

Query  65   TSAGTKMQMTQRDIPQSVTIVSQQRMEDQQLQTLGEVMENTLGISKSQADSDRALYYSRG  124
             + G  +  + ++ PQSVT+++++ ++DQ L T+ +VME T GI+   +      +YSRG
Sbjct  152  VTIGKGVH-SLKETPQSVTVMTRKMLDDQNLNTIEQVMEKTPGITVYDSPMGGKYFYSRG  210

Query  125  FQID-NYMVDGIPTYFESRWNLGDAL-SDMALFERVEVVRGATGLMTGTGNPSAAINMVR  182
            F++   Y  DG+P    S +   D+  SDMA+++RVEV+RGA G+M G G  +  +N VR
Sbjct  211  FRMSGQYQYDGVPLDIGSSYVQADSFNSDMAIYDRVEVLRGAAGMMKGAGGTAGGVNFVR  270

Query  183  KHATSREFKGDVSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNSEK  242
            K          +S   G+W+  R   D   PL + G IR R V   Q    + D  + + 
Sbjct  271  KRGQDTAHT-QLSLSAGTWDNYRGQVDTGGPLNDSGTIRGRAVVTEQTRQYFYDVGSRKD  329

Query  243  TFFSGIVDADLGDLTTLSAGYEYQRIDVNSPTWGGLPRWNTDGSGNSYDRARSTAPDWAY  302
              + G +D DL   TTL  G+ ++ +D  +P WGGLPR+     G+     RST  + A+
Sbjct  330  QIYYGALDFDLSPDTTLGLGFAWEDVDA-TPCWGGLPRY---ADGSDLHLKRSTCLNTAW  385

Query  303  NDKEINKV--FMTLKQRFADTWQATLNATHS------EVEFDSKMMYVDAYVNKADGMLV  354
            N++   +   F  LK +F D W   +   +S      E  F S  + V A     + +++
Sbjct  386  NNQRSKRATYFADLKHQFNDDWSLKVAGVYSRNTQDMEYAFPSGAVPVGA--TATNTLML  443

Query  355  GPYSNYGPGFDYVGGTGWNSGKRKVDALDLFADGSYELFGRQHNLMFGGSYSKQNNRYFS  414
            G   +Y                ++    D + DG ++ FG+QH L  G + S+ +   F 
Sbjct  444  GSIYDY---------------DQRDYGFDAYVDGKFDAFGQQHELTIGANASRSHKDDFY  488

Query  415  SWANIFPDEIGSFYNFNGNFPQTDWS----PQSLAQDDTTHMK--SLYAATRVTLADPLH  468
            + A +   +  +  + N + PQ D S      S       H+K    Y+  R+ LADPL 
Sbjct  489  AVAALPQRQ--NVLDPNHHIPQPDESYYLANASRGGPVDMHIKQYGAYSIARLKLADPLT  546

Query  469  LILGARYTNWRVDTL-------------TYSMEKNHTTPYAGLVFDINDNWSTYASYTSI  515
            L+LG+R + ++ DT              T S E    TP+AG++FD+NDN + YASYT I
Sbjct  547  LVLGSRVSWYKSDTDSVQYFRGEGTQVDTKSTETGQVTPFAGVLFDLNDNLTAYASYTDI  606

Query  516  FQPQKD-RDSSGKYLAPITGNNYELGLKSDWMNSRLTTTLAIFRIEQDNVAQSTGTPIPG  574
            F PQ   +   G  L P+ G +YELG+K +W + RL +T  +FR  Q + AQ      P 
Sbjct  607  FTPQGAYKTIDGSTLKPLVGQSYELGIKGEWFDGRLNSTFNLFRTLQKDAAQDD----PR  662

Query  575  SNGETAYKAVDGTVSKGVEFELNGAITDNWQLTFGAT---RYIAED----NEGNAVNPNL  627
                +         ++G E E++G + D  QL  G T     + ED     +G   N  +
Sbjct  663  CEDSSCSINSGKVRAQGFEAEVSGEVIDRLQLLAGYTYTQTKVLEDADATQDGVVYNSYV  722

Query  628  PRTTIKMFTSYRLP-VMPELTVGGGVNWQNRVYTDTVTPYGTFRAEQGSYALVDLFTRYQ  686
            PR  ++++  Y L   +  +T+G GVN Q   Y    +P G    +   YA+ +    Y+
Sbjct  723  PRHLLRVWGDYSLSGPLDRVTIGAGVNAQTGNY--RTSPIGGDNIDGAGYAVWNGRIGYR  780

Query  687  VTKNFSLQGNVNNLFDKTYDTNV--EG-SIVYGAPRNFSIT  724
            +   +S+  N NNLFDK Y + +  EG    YG PRNF ++
Sbjct  781  IDDTWSVALNGNNLFDKRYYSTIGTEGFGNFYGDPRNFVMS  821


>Q47162.2 RecName: Full=Ferrichrysobactin receptor; Flags: Precursor
Length=735

 Score = 105 bits (262),  Expect = 3e-22, Method: Compositional matrix adjust.
 Identities = 185/766 (24%), Positives = 304/766 (40%), Gaps = 111/766 (14%)

Query  18   PSLLAACIALALLPSAAFAAPATEETVIVEGSATTPVDDENDYSVTSTSA-GTKMQMTQR  76
            P++LA+ + +A    AA    A  +T+IV  +A   V       V   SA GTK      
Sbjct  23   PAVLASTLLMAAHAQAAETTGA--DTMIVSANAGESVTAPLKGIVAKESASGTKTSTPLI  80

Query  77   DIPQSVTIVSQQRMEDQQLQTLGEVMENTLGI-SKSQADSDRA-LYYSRGFQIDNYMVDG  134
              PQSVT+V++ +M+ Q + ++ + +  + G+ +  +  S+R     +RGF+     +DG
Sbjct  81   KTPQSVTVVTRDQMDAQAVSSVSDALNYSSGVVTNYRGSSNRNDEVIARGFRYAPKFLDG  140

Query  135  IPTYFESRWNLGDALSDMA--LFERVEVVRGATGLMTGTGNPSAAINMVRKHATSREFKG  192
            +      +   G  +  M   L ERVE+V G   ++ G  NP   I+M  K  T+   + 
Sbjct  141  LSYGLSGQ---GSTIGKMNPWLLERVEMVHGPASVLYGQVNPGGLISMTSKRPTAETIR-  196

Query  193  DVSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNSEKTFFSGIVDAD  252
             V    G+ +      D    L +D  +  R+ G       ++     E+   +  +   
Sbjct  197  KVQFSAGNQHLGEAAFDFGGALNDDKTLLYRLDGIASTKHEFVKDSKQERIAVAPSLTWL  256

Query  253  LGDLTTLSAGYEYQRIDVNSPTWG---GLPRWNTDGSGNS----YDRARSTAPDWAYNDK  305
                T+ +    YQ    N P  G    LP+  T    ++    YD   S  P++  + +
Sbjct  257  PNPDTSFTLLTSYQ----NDPKAGYRNFLPKIGTVVEASAGYIPYDLNVSD-PNYNQSKR  311

Query  306  EINKVFMTLKQRFADTWQATLNATHSEVEFDSKMMYVDAYVNKADGMLVGPYSNYGPGFD  365
            E   +   L   F D +    N  ++++    K +    Y   AD           P  D
Sbjct  312  EQGSIGYNLDHSFNDVFSFQQNVRYTQLREKYKYL---VYTKNADA----------PATD  358

Query  366  YVGGTGWNSGKRKVDALDLFA-----DGSYELFGRQHNLMFGGSYS----------KQNN  410
                T     +++ + +  FA       ++      H ++ G  Y            +NN
Sbjct  359  ---TTILRRPQKEENEISEFAIDNQLKATFATGSVNHTVLSGLDYKWLTLEKKMWLDRNN  415

Query  411  RYFSSWANIFPDEIGSFYNFNGNFPQTDWSPQSLAQDDTTHMKSLYAATRVTLADPL---  467
             Y  +WAN         YN + N         S+  + +T+ ++      V L D L   
Sbjct  416  DYSFNWAN-------PTYNVSVN--------DSMLTELSTNERNKLNQVGVYLQDQLEWN  460

Query  468  --HLILGARYTNWRVDTLTYSM----EKN--HTTPYAGLVFDINDNWSTYASYTSIFQPQ  519
              +L+L  R+   RVD   Y+     E+N    T  AGL++  ++  S Y SY++ F+P 
Sbjct  461  QWNLLLSGRHDWSRVDKQDYAADTTTERNDGKFTGRAGLLYAFDNGISPYVSYSTSFEPN  520

Query  520  KDRDSSG-KYLAPITGNNYELGLKSDWMNSRLTTTLAIFRIEQDNVAQSTGTPIPGSNGE  578
             D  + G     P TG   E+G+K     S    T+++F I Q N        I   N  
Sbjct  521  LDSGAPGTPAFKPTTGEQKEVGVKFQPKGSNTLLTVSLFDITQKN--------ITSYNSV  572

Query  579  TAYKAVDGTV-SKGVEFELNGAITDNWQL------TFGATRYIAEDNEGNAVNPNLPRTT  631
            T Y    G V SKGVE E +  +T    L      T   T+     ++ N    ++PR  
Sbjct  573  TRYNEQIGKVKSKGVETEAHTQLTPEISLMAAYSYTDAVTKESYTASQVNKAPSSIPRHA  632

Query  632  IKMFTSYRLPVMP--ELTVGGGVNWQNRVYTDTVTPYGTFRAEQGSYALVDLFTRYQV--  687
               + SY     P   +T+G GV +    Y D    +     +  +Y L D   RY++  
Sbjct  633  ASAWGSYSFHNGPLKGVTLGTGVRYIGSTYGDNAESF-----KVPAYTLFDAMARYELGS  687

Query  688  ----TKNFSLQGNVNNLFDKTYDTNVEG--SIVYGAPRNFSITGTY  727
                 K  ++Q NVNNL DK Y  +  G  +  YG+ R    T +Y
Sbjct  688  LASQLKGAAVQLNVNNLTDKHYVASCGGDTACFYGSGRTVVATVSY  733


>O86241.1 RecName: Full=Uncharacterized TonB-dependent receptor HI_1466.1
Length=345

 Score = 65.9 bits (159),  Expect = 3e-10, Method: Compositional matrix adjust.
 Identities = 64/230 (28%), Positives = 103/230 (45%), Gaps = 24/230 (10%)

Query  497  GLVFDINDNWSTYASYTSIFQPQKDRD--SSGKYLAPITGNNYELGLKSDWMNSRLTTTL  554
            G V+    N +T+ ++   F+PQ +R    +G+ L    G ++E GLK  + N+ L  T+
Sbjct  102  GSVYKFTPNIATFFNHAESFRPQNNRTLIINGE-LPAEQGKSFETGLK--YENAYLNATV  158

Query  555  AIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAITDNWQL----TFGA  610
            A+F I + NVA++        NG    + V    S+G+EF+LNG +TDN  +    T+  
Sbjct  159  ALFNINKRNVAETVNV-----NGTNELQIVGKQRSRGIEFDLNGQLTDNLSIAANYTYTK  213

Query  611  TRYIAEDNEGNAVNPNL---PRTTIKMFTSYRLPVMP--ELTVGGGVNWQNRVYTDTVTP  665
             + +   N   AV   L   P+    +F +Y +       + VGGG  +    Y    T 
Sbjct  214  VKNLENHNNKLAVGKQLSGVPKHQASLFLAYNIGEFDFGNIRVGGGARYLGSWYAYNNTY  273

Query  666  YGTFRAEQGSYALVDLFTRYQVT---KNFSLQGNVNNLFDKTYDTNVEGS  712
               ++  Q    + D F  Y      K  S Q N  NL +K Y  +  G+
Sbjct  274  TKAYKLPQA--IVYDTFIAYDTKISGKKVSFQLNGKNLSNKVYSPSTSGN  321


>Q8CW90.1 RecName: Full=Catecholate siderophore receptor Fiu; AltName: 
Full=Ferric iron uptake protein; AltName: Full=TonB-dependent 
receptor Fiu; Flags: Precursor
Length=760

 Score = 62.0 bits (149),  Expect = 1e-08, Method: Compositional matrix adjust.
 Identities = 66/253 (26%), Positives = 103/253 (41%), Gaps = 28/253 (11%)

Query  496  AGLVFDINDNWSTYASYTSIFQP---------QKDRDSSGKY--LAPITGNNYELGLKSD  544
            AG ++ + +N + Y +Y    QP         Q    +S       P   N  E+G K  
Sbjct  517  AGALYHLTENGNVYINYAVSQQPPGGNNFALAQSGSGNSANRTDFKPQKANTSEIGTKWQ  576

Query  545  WMNSRLTTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAITDNW  604
             ++ RL  T A+FR + +N  +         N +  Y        +G E  + G IT  W
Sbjct  577  VLDKRLLLTAALFRTDIENEVEQ--------NDDGTYSQYGKKRVEGYEISVAGNITPAW  628

Query  605  QLTFGATRYIAEDNEGNAV----NPNLPRTTIKMFTSY-RLPVMPELTVGGGVNWQNRVY  659
            Q+  G T+  A    G  V    + +LP T    FT + +     +++VG G  +   ++
Sbjct  629  QMIGGYTQQKATIKNGKDVAQDGSSSLPYTPEHAFTLWSQYQATDDISVGAGARYIGSMH  688

Query  660  TDTVTPYGTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDTNVEGSIVY---G  716
              +    GT    +G Y + D    Y+V +N   Q NV NLFD  Y  ++  S      G
Sbjct  689  KGSDGAVGTPAFTEG-YWVADAKLGYRVNRNLDFQLNVYNLFDTDYVASINKSGYRYHPG  747

Query  717  APRNFSITGTYQF  729
             PR F +T    F
Sbjct  748  EPRTFLLTANMHF  760


 Score = 57.0 bits (136),  Expect = 5e-07, Method: Compositional matrix adjust.
 Identities = 72/283 (25%), Positives = 125/283 (44%), Gaps = 35/283 (12%)

Query  23   ACIALALLPSA-AFAAPA---TEETVIVEGSATTPVDDENDYSVTSTSAGTKMQMTQRDI  78
            A + + + P A A AA      ++T++VE  A+TP            SA  K      D 
Sbjct  19   AGLCIGITPVAQALAAEGQANADDTLVVE--ASTP-----SLYAPQQSADPKFSRPVADT  71

Query  79   PQSVTIVSQQRMEDQQLQTLGEVMENTLGI------SKSQADSDRALYYSRGFQIDNYM-  131
             +++T++S+Q ++DQ    L + ++N  G+          + +  A+Y  RG    N + 
Sbjct  72   TRTMTVISEQVIKDQGATNLTDALKNVPGVGAFFAGENGNSTTGDAIYM-RGADTSNSIY  130

Query  132  VDGIPTYFESRWNLGDALSDMALFERVEVVRGATGLMTGTGNPSAAINMVRKHATSREFK  191
            +DGI        ++G    D    E+VEV++G +G   G   P+ +INM+ K    R   
Sbjct  131  IDGI-------RDIGSVSRDTFNTEQVEVIKGPSGTDYGRSAPTGSINMISKQP--RNDS  181

Query  192  G-DVSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNSEKTFFSGIVD  250
            G D SA  GS    R   D+   + +   +R  ++ G + +D+  D+  +E+   +  V 
Sbjct  182  GIDASASIGSAWFRRGTLDVNQVIGDTTAVRLNVM-GEKTHDAGRDKVKNERYGVAPSVV  240

Query  251  ADLGDLTTLSAGY----EYQRIDVNSPTWGGLPRWNTDGSGNS  289
              LG    L   Y    ++   D   PT  GLP ++   +G +
Sbjct  241  FGLGTANRLYLNYLHVTQHNTPDGGIPTI-GLPGYSAPSAGTA  282


>Q1REC0.1 RecName: Full=Catecholate siderophore receptor Fiu; AltName: 
Full=Ferric iron uptake protein; AltName: Full=TonB-dependent 
receptor Fiu; Flags: Precursor
Length=760

 Score = 62.0 bits (149),  Expect = 1e-08, Method: Compositional matrix adjust.
 Identities = 66/253 (26%), Positives = 103/253 (41%), Gaps = 28/253 (11%)

Query  496  AGLVFDINDNWSTYASYTSIFQP---------QKDRDSSGKY--LAPITGNNYELGLKSD  544
            AG ++ + +N + Y +Y    QP         Q    +S       P   N  E+G K  
Sbjct  517  AGALYHLTENGNIYINYAVSQQPPGGNNFALAQSGSGNSANRTDFKPQKANTSEIGTKWQ  576

Query  545  WMNSRLTTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAITDNW  604
             ++ RL  T A+FR + +N  +         N +  Y        +G E  + G IT  W
Sbjct  577  VLDKRLLLTAALFRTDIENEVEQ--------NDDGTYSQYGKKRVEGYEISVAGNITPAW  628

Query  605  QLTFGATRYIAEDNEGNAV----NPNLPRTTIKMFTSY-RLPVMPELTVGGGVNWQNRVY  659
            Q+  G T+  A    G  V    + +LP T    FT + +     +++VG G  +   ++
Sbjct  629  QMIGGYTQQKATIKNGKDVAQDGSSSLPYTPEHAFTLWSQYQATDDISVGAGARYIGSMH  688

Query  660  TDTVTPYGTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDTNVEGSIVY---G  716
              +    GT    +G Y + D    Y+V +N   Q NV NLFD  Y  ++  S      G
Sbjct  689  KGSDGAVGTPAFTEG-YWVADAKLGYRVNRNLDFQLNVYNLFDTDYVASINKSGYRYHPG  747

Query  717  APRNFSITGTYQF  729
             PR F +T    F
Sbjct  748  EPRTFLLTANMHF  760


 Score = 57.4 bits (137),  Expect = 3e-07, Method: Compositional matrix adjust.
 Identities = 72/283 (25%), Positives = 125/283 (44%), Gaps = 35/283 (12%)

Query  23   ACIALALLPSA-AFAAPA---TEETVIVEGSATTPVDDENDYSVTSTSAGTKMQMTQRDI  78
            A + + + P A A AA      ++T++VE  A+TP            SA  K      D 
Sbjct  19   AGLCIGITPVAQALAAEGQANADDTLVVE--ASTP-----SLYAPQQSADPKFSRPVADT  71

Query  79   PQSVTIVSQQRMEDQQLQTLGEVMENTLGI------SKSQADSDRALYYSRGFQIDNYM-  131
             +++T++S+Q ++DQ    L + ++N  G+          + +  A+Y  RG    N + 
Sbjct  72   TRTMTVISEQVIKDQGATNLTDALKNVPGVGAFFAGENGNSTTGDAIYM-RGADTSNSIY  130

Query  132  VDGIPTYFESRWNLGDALSDMALFERVEVVRGATGLMTGTGNPSAAINMVRKHATSREFK  191
            +DGI        ++G    D    E+VEV++G +G   G   P+ +INM+ K    R   
Sbjct  131  IDGI-------RDIGSVSRDTFNTEQVEVIKGPSGTDYGRSAPTGSINMISKQP--RNDS  181

Query  192  G-DVSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNSEKTFFSGIVD  250
            G D SA  GS    R   D+   + +   +R  ++ G + +D+  D+  +E+   +  V 
Sbjct  182  GIDASASIGSAWFRRGTLDVNQVIGDTTAVRLNVM-GEKTHDAGRDKVKNERYGVAPSVA  240

Query  251  ADLGDLTTLSAGY----EYQRIDVNSPTWGGLPRWNTDGSGNS  289
              LG    L   Y    ++   D   PT  GLP ++   +G +
Sbjct  241  FGLGTANRLYLNYLHVTQHNTPDGGIPTI-GLPGYSAPSAGTA  282


>Q8X7W7.1 RecName: Full=Catecholate siderophore receptor Fiu; AltName: 
Full=Ferric iron uptake protein; AltName: Full=TonB-dependent 
receptor Fiu; Flags: Precursor
Length=760

 Score = 61.6 bits (148),  Expect = 2e-08, Method: Compositional matrix adjust.
 Identities = 66/253 (26%), Positives = 103/253 (41%), Gaps = 28/253 (11%)

Query  496  AGLVFDINDNWSTYASYTSIFQP---------QKDRDSSGKY--LAPITGNNYELGLKSD  544
            AG ++ + +N + Y +Y    QP         Q    +S       P   N  E+G K  
Sbjct  517  AGALYHLTENGNVYINYAVSQQPPGGNNFALAQSGSGNSANRTDFKPQKANTSEIGTKWQ  576

Query  545  WMNSRLTTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAITDNW  604
             ++ RL  T A+FR + +N  +         N +  Y        +G E  + G IT  W
Sbjct  577  VLDKRLLLTAALFRTDIENEVEQ--------NDDGTYSQYGKKRVEGYEISVAGNITPAW  628

Query  605  QLTFGATRYIAEDNEGNAV----NPNLPRTTIKMFTSY-RLPVMPELTVGGGVNWQNRVY  659
            Q+  G T+  A    G  V    + +LP T    FT + +     +++VG G  +   ++
Sbjct  629  QVIGGYTQQKATIKNGKDVAQDGSSSLPYTPEHAFTLWSQYQATDDISVGAGARYIGSMH  688

Query  660  TDTVTPYGTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDTNVEGSIVY---G  716
              +    GT    +G Y + D    Y+V +N   Q NV NLFD  Y  ++  S      G
Sbjct  689  KGSDGAVGTPAFTEG-YWVADAKLGYRVNRNLDFQLNVYNLFDTDYVASINKSGYRYHPG  747

Query  717  APRNFSITGTYQF  729
             PR F +T    F
Sbjct  748  EPRTFLLTANMHF  760


 Score = 57.8 bits (138),  Expect = 2e-07, Method: Compositional matrix adjust.
 Identities = 70/280 (25%), Positives = 123/280 (44%), Gaps = 33/280 (12%)

Query  24   CIALALLPSAAFAAPAT--EETVIVEGSATTPVDDENDYSVTSTSAGTKMQMTQRDIPQS  81
            CI +  +  A  A   T  ++T++VE  A+TP            SA  K      D  ++
Sbjct  22   CIGITPVAQALAAEGQTNADDTLVVE--ASTP-----SLYAPQQSADPKFSRPVADTTRT  74

Query  82   VTIVSQQRMEDQQLQTLGEVMENTLGI------SKSQADSDRALYYSRGFQIDNYM-VDG  134
            +T++S+Q ++DQ    L + ++N  G+          + +  A+Y  RG    N + +DG
Sbjct  75   MTVISEQVIKDQGATNLTDALKNVPGVGAFFAGENGNSTTGDAIYM-RGADTSNSIYIDG  133

Query  135  IPTYFESRWNLGDALSDMALFERVEVVRGATGLMTGTGNPSAAINMVRKHATSREFKG-D  193
            I        ++G    D    E+VEV++G +G   G   P+ +INM+ K    R   G D
Sbjct  134  I-------RDIGSVSRDTFNTEQVEVIKGPSGTDYGRSAPTGSINMISKQP--RNDSGID  184

Query  194  VSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNSEKTFFSGIVDADL  253
             SA  GS    R   D+   + +   +R  ++ G + +D+  D+  +E+   +  +   L
Sbjct  185  ASASIGSAWFRRGTLDVNQVIGDTTAVRLNVM-GEKTHDAGRDKVKNERYGVAPSIAFGL  243

Query  254  GDLTTLSAGY----EYQRIDVNSPTWGGLPRWNTDGSGNS  289
            G    L   Y    ++   D   PT  GLP ++   +G +
Sbjct  244  GTANRLYLNYLHVTQHNTPDGGIPTI-GLPGYSAPSAGTA  282


>P75780.1 RecName: Full=Catecholate siderophore receptor Fiu; AltName: 
Full=Ferric iron uptake protein; AltName: Full=TonB-dependent 
receptor Fiu; Flags: Precursor
Length=760

 Score = 61.6 bits (148),  Expect = 2e-08, Method: Compositional matrix adjust.
 Identities = 66/253 (26%), Positives = 103/253 (41%), Gaps = 28/253 (11%)

Query  496  AGLVFDINDNWSTYASYTSIFQP---------QKDRDSSGKY--LAPITGNNYELGLKSD  544
            AG ++ + +N + Y +Y    QP         Q    +S       P   N  E+G K  
Sbjct  517  AGALYHLTENGNVYINYAVSQQPPGGNNFALAQSGSGNSANRTDFKPQKANTSEIGTKWQ  576

Query  545  WMNSRLTTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAITDNW  604
             ++ RL  T A+FR + +N  +         N +  Y        +G E  + G IT  W
Sbjct  577  VLDKRLLLTAALFRTDIENEVEQ--------NDDGTYSQYGKKRVEGYEISVAGNITPAW  628

Query  605  QLTFGATRYIAEDNEGNAV----NPNLPRTTIKMFTSY-RLPVMPELTVGGGVNWQNRVY  659
            Q+  G T+  A    G  V    + +LP T    FT + +     +++VG G  +   ++
Sbjct  629  QVIGGYTQQKATIKNGKDVAQDGSSSLPYTPEHAFTLWSQYQATDDISVGAGARYIGSMH  688

Query  660  TDTVTPYGTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDTNVEGSIVY---G  716
              +    GT    +G Y + D    Y+V +N   Q NV NLFD  Y  ++  S      G
Sbjct  689  KGSDGAVGTPAFTEG-YWVADAKLGYRVNRNLDFQLNVYNLFDTDYVASINKSGYRYHPG  747

Query  717  APRNFSITGTYQF  729
             PR F +T    F
Sbjct  748  EPRTFLLTANMHF  760


 Score = 58.5 bits (140),  Expect = 2e-07, Method: Compositional matrix adjust.
 Identities = 71/280 (25%), Positives = 123/280 (44%), Gaps = 33/280 (12%)

Query  24   CIALALLPSAAFAAPAT--EETVIVEGSATTPVDDENDYSVTSTSAGTKMQMTQRDIPQS  81
            CI +  +  A  A   T  ++T++VE  A+TP            SA  K      D  ++
Sbjct  22   CIGITPVAQALAAEGQTNADDTLVVE--ASTP-----SLYAPQQSADPKFSRPVADTTRT  74

Query  82   VTIVSQQRMEDQQLQTLGEVMENTLGI------SKSQADSDRALYYSRGFQIDNYM-VDG  134
            +T++S+Q ++DQ    L + ++N  G+          + +  A+Y  RG    N + +DG
Sbjct  75   MTVISEQVIKDQGATNLTDALKNVPGVGAFFAGENGNSTTGDAIYM-RGADTSNSIYIDG  133

Query  135  IPTYFESRWNLGDALSDMALFERVEVVRGATGLMTGTGNPSAAINMVRKHATSREFKG-D  193
            I        ++G    D    E+VEV++G +G   G   P+ +INM+ K    R   G D
Sbjct  134  I-------RDIGSVSRDTFNTEQVEVIKGPSGTDYGRSAPTGSINMISKQP--RNDSGID  184

Query  194  VSAEYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLDRYNSEKTFFSGIVDADL  253
             SA  GS    R   D+   + +   +R  ++ G + +D+  D+  +E+   +  V   L
Sbjct  185  ASASIGSAWFRRGTLDVNQVIGDTTAVRLNVM-GEKTHDAGRDKVKNERYGVAPSVAFGL  243

Query  254  GDLTTLSAGY----EYQRIDVNSPTWGGLPRWNTDGSGNS  289
            G    L   Y    ++   D   PT  GLP ++   +G +
Sbjct  244  GTANRLYLNYLHVTQHNTPDGGIPTI-GLPGYSAPSAGTA  282


>Q05098.1 RecName: Full=Ferric enterobactin receptor; Flags: Precursor
Length=746

 Score = 48.5 bits (114),  Expect = 2e-04, Method: Compositional matrix adjust.
 Identities = 169/752 (22%), Positives = 277/752 (37%), Gaps = 123/752 (16%)

Query  20   LLAACIALALLPSAAFAAPATEETVIVEGSATT-PVDDENDYSVTSTSAGTKMQMTQR--  76
            LL++C    LL +A  AA   + +VI  G  T      E        S  T   + +R  
Sbjct  13   LLSSC----LLANAVHAAGQGDGSVIELGEQTVVATAQEETKQAPGVSIITAEDIAKRPP  68

Query  77   --DIPQSVTIV----------SQQRMEDQQLQTLGEVMENTLGISKSQADSDR--ALYYS  122
              D+ Q +  +          S QR  ++Q+   G   ENTL +   +  S R    Y  
Sbjct  69   SNDLSQIIRTMPGVNLTGNSSSGQRGNNRQIDIRGMGPENTLILVDGKPVSSRNSVRYGW  128

Query  123  RGFQIDNYMVDGIPTYFESRWNLGDALSDMALFERVEVVRGATGLMTGTGNPSAAINMVR  182
            RG +          +  ++ W   D +      ER+EV+RG      G G     +N++ 
Sbjct  129  RGER---------DSRGDTNWVPADQV------ERIEVIRGPAAARYGNGAAGGVVNIIT  173

Query  183  KHATSREFKGDVSA------EYGSWNKERYVADLQSPLTEDGKIRARIVGGYQNNDSWLD  236
            K A + E  G++S              ER    L  PLTE+  +  R+ G     DS  D
Sbjct  174  KQAGA-ETHGNLSVYSNFPQHKAEGASERMSFGLNGPLTEN--LSYRVYGNIAKTDS--D  228

Query  237  RYNSEKTFFSGIVDADLGDLTTLSAGYEYQRIDVNSPTWGGLPRWNTDGSGNSYDRARST  296
             ++      S       G L     G   + ID    +W   P    +     + R  + 
Sbjct  229  DWDINAGHESNRTGKQAGTLPAGREGVRNKDID-GLLSWRLTPEQTLEFEA-GFSRQGNI  286

Query  297  APDWAYNDKEINKVFMTLKQRFADTWQATLNATH-SEVEFDSKMMYV------DAYVNKA  349
                  N    N V   L       ++ T + TH  E +F S + Y+      ++ +N  
Sbjct  287  YTGDTQNTNSNNYVKQMLGHETNRMYRETYSVTHRGEWDFGSSLAYLQYEKTRNSRIN--  344

Query  350  DGMLVGPYSNYGPGFDYVGGTGWNSGKRKVDALDLFADGSYEL---FGRQHNLMFGGSYS  406
            +G+  G    + P          N+G       DL A G   L    G +  L  G  ++
Sbjct  345  EGLAGGTEGIFDPN---------NAGFYTATLRDLTAHGEVNLPLHLGYEQTLTLGSEWT  395

Query  407  KQNNRYFSSWANIFPDEIGSFYNFNGNFPQTDWSPQSLAQDDTTHMKSLYAATRVTLADP  466
            +Q     SS      +E GS     G         ++ +   +  + SL+A   + L   
Sbjct  396  EQKLDDPSSNTQ-NTEEGGSIPGLAG---------KNRSSSSSARIFSLFAEDNIELMPG  445

Query  467  LHLILGARYTNWRV--DTLTYSMEKNH-----TTPYAGL--------VFDINDNWSTYAS  511
              L  G R+ +  +  D  + S+  +H      T  AG+        ++ +N ++  Y+ 
Sbjct  446  TMLTPGLRWDHHDIVGDNWSPSLNLSHALTERVTLKAGIARAYKAPNLYQLNPDYLLYSR  505

Query  512  YTSIFQPQKD---RDSSGKYLAPITGNNYELGLKSDWMNSRLTTTLAIFRIEQDNVAQST  568
                +        R + G  L   T  N ELG+  ++ +  L   L  FR +  N  +S 
Sbjct  506  GQGCYGQSTSCYLRGNDG--LKAETSVNKELGI--EYSHDGLVAGLTYFRNDYKNKIESG  561

Query  569  GTPI---PGSNGETAYKA------VDGTVSKGVEFELNGAITDNWQLTFGATRYIAEDN-  618
             +P+    G  G+ A  A      V   V +G+E  L   + D  + +   T  +   N 
Sbjct  562  LSPVDHASGGKGDYANAAIYQWENVPKAVVEGLEGTLTLPLADGLKWSNNLTYMLQSKNK  621

Query  619  EGNAVNPNLPRTTIKMFTSYRLPVMPELTVGGGVNWQNR-------VYTDTVTPYGTFRA  671
            E   V    PR T+     ++     +L++   V W  +        + D VT  G+   
Sbjct  622  ETGDVLSVTPRYTLNSMLDWQ--ATDDLSLQATVTWYGKQKPKKYDYHGDRVT--GSAND  677

Query  672  EQGSYALVDLFTRYQVTKNFSLQGNVNNLFDK  703
            +   YA+  L   Y+++KN SL   V+NLFDK
Sbjct  678  QLSPYAIAGLGGTYRLSKNLSLGAGVDNLFDK  709


>A1JTG3.1 RecName: Full=Pesticin receptor; AltName: Full=IPR65; AltName: 
Full=IRPC; Flags: Precursor
Length=673

 Score = 43.1 bits (100),  Expect = 0.009, Method: Compositional matrix adjust.
 Identities = 55/229 (24%), Positives = 89/229 (39%), Gaps = 47/229 (21%)

Query  502  INDNWSTYASYTSIFQPQKDRDSSGKYLAPITG-----------NNYELGLKSDWMNSRL  550
            + D+W  Y      ++P      SG  + P  G            NYELG +  +  + +
Sbjct  441  LTDDWRVYTRIAQGYKP------SGYNIVPTAGLDAKPFVAEKSINYELGTR--YETADV  492

Query  551  TTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAITDNWQLTFGA  610
            T   A F     ++   +G P+       A KA D T   GVE E        W      
Sbjct  493  TLQAATFYTHTKDMQLYSG-PVGMQTLSNAGKA-DAT---GVELEAKWRFAPGW------  541

Query  611  TRYIAEDNEGNAVNPNLPRTTIKMFTSYRLPVMPELTVGGGVN---------WQNRVYTD  661
                + D  GN +       + +++   R+P +P    G  VN            R+  +
Sbjct  542  ----SWDINGNVIRSEFTNDS-ELYHGNRVPFVPRYGAGSSVNGVIDTRYGALMPRLAVN  596

Query  662  TVTPY---GTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDT  707
             V P+   G  +  QG+YA +D    +Q T+  ++  +V+NLFD+ Y T
Sbjct  597  LVGPHYFDGDNQLRQGTYATLDSSLGWQATERINISVHVDNLFDRRYRT  645


>P0C2M9.1 RecName: Full=Pesticin receptor; AltName: Full=IPR65; AltName: 
Full=IRPC; Flags: Precursor
Length=673

 Score = 42.7 bits (99),  Expect = 0.009, Method: Compositional matrix adjust.
 Identities = 55/229 (24%), Positives = 89/229 (39%), Gaps = 47/229 (21%)

Query  502  INDNWSTYASYTSIFQPQKDRDSSGKYLAPITG-----------NNYELGLKSDWMNSRL  550
            + D+W  Y      ++P      SG  + P  G            NYELG +  +  + +
Sbjct  441  LTDDWRVYTRIAQGYKP------SGYNIVPTAGLDAKPFVAEKSINYELGTR--YETADV  492

Query  551  TTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAITDNWQLTFGA  610
            T   A F     ++   +G P+       A KA D T   GVE E        W      
Sbjct  493  TLQAATFYTHTKDMQLYSG-PVGMQTLSNAGKA-DAT---GVELEAKWRFAPGW------  541

Query  611  TRYIAEDNEGNAVNPNLPRTTIKMFTSYRLPVMPELTVGGGVN---------WQNRVYTD  661
                + D  GN +       + +++   R+P +P    G  VN            R+  +
Sbjct  542  ----SWDINGNVIRSEFTNDS-ELYHGNRVPFVPRYGAGSSVNGVIDTRYGALMPRLAVN  596

Query  662  TVTPY---GTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDT  707
             V P+   G  +  QG+YA +D    +Q T+  ++  +V+NLFD+ Y T
Sbjct  597  LVGPHYFDGDNQLRQGTYATLDSSLGWQATERINISVHVDNLFDRRYRT  645


>P46359.2 RecName: Full=Pesticin receptor; AltName: Full=IRPC; Flags: Precursor
Length=673

 Score = 41.6 bits (96),  Expect = 0.025, Method: Compositional matrix adjust.
 Identities = 55/229 (24%), Positives = 88/229 (38%), Gaps = 47/229 (21%)

Query  502  INDNWSTYASYTSIFQPQKDRDSSGKYLAPITG-----------NNYELGLKSDWMNSRL  550
            + D+W  Y      ++P      SG  + P  G            NYELG +  +  + +
Sbjct  441  LTDDWRVYTRVAQGYKP------SGYNIVPTAGLDAKPFVAEKSINYELGTR--YETADV  492

Query  551  TTTLAIFRIEQDNVAQSTGTPIPGSNGETAYKAVDGTVSKGVEFELNGAITDNWQLTFGA  610
            T   A F     ++   +G P+       A KA D T   GVE E        W      
Sbjct  493  TLQAATFYTHTKDMQLYSG-PVRMQTLSNAGKA-DAT---GVELEAKWRFAPGW------  541

Query  611  TRYIAEDNEGNAVNPNLPRTTIKMFTSYRLPVMPELTVGGGVN---------WQNRVYTD  661
                + D  GN +       + +++   R+P +P    G  VN            R+  +
Sbjct  542  ----SWDINGNVIRSEFTNDS-ELYHGNRVPFVPRYGAGSSVNGVIDTRYGALMPRLAVN  596

Query  662  TVTPY---GTFRAEQGSYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDT  707
             V P+   G  +  QG+YA +D    +Q T+  ++   V+NLFD+ Y T
Sbjct  597  LVGPHYFDGDNQLRQGTYATLDSSLGWQATERMNISVYVDNLFDRRYRT  645


>Q6LLU3.1 RecName: Full=Vitamin B12 transporter BtuB; AltName: Full=Cobalamin 
receptor; AltName: Full=Outer membrane cobalamin translocator; 
Flags: Precursor
Length=606

 Score = 39.3 bits (90),  Expect = 0.11, Method: Compositional matrix adjust.
 Identities = 22/55 (40%), Positives = 30/55 (55%), Gaps = 3/55 (5%)

Query  675  SYALVDLFTRYQVTKNFSLQGNVNNLFDKTYDTNVEGSIVYGAPRNFSITGTYQF  729
            +Y LVD+   Y VT N S++G + NLFDK Y   V         R++  T TY+F
Sbjct  555  AYTLVDIAASYFVTDNLSVRGRIANLFDKDY---VAKETYNVQERSYYATATYKF  606


>Q4KMC8.1 RecName: Full=Fructose-bisphosphate aldolase C-A; AltName: Full=Aldolase 
C-like; AltName: Full=Brain-type aldolase-A
Length=364

 Score = 34.7 bits (78),  Expect = 2.6, Method: Compositional matrix adjust.
 Identities = 13/39 (33%), Positives = 23/39 (59%), Gaps = 0/39 (0%)

Query  570  TPIPGSNGETAYKAVDGTVSKGVEFELNGAITDNWQLTF  608
             P+PG+NGETA + +DG   +  +++ +GA    W+   
Sbjct  114  VPLPGTNGETATQGLDGLSERCAQYKKDGADFAKWRCVM  152


>Q8PTK1.1 RecName: Full=DNA ligase 2; AltName: Full=Polydeoxyribonucleotide 
synthase [ATP] 2
Length=568

 Score = 33.1 bits (74),  Expect = 9.0, Method: Compositional matrix adjust.
 Identities = 25/68 (37%), Positives = 35/68 (51%), Gaps = 6/68 (9%)

Query  340  MYVDAYVNKADGMLV-GPYSNYGPGFDYVGGTGWNSGKRKVDALDLFADGSYELFGRQHN  398
            +Y +A     +G++V  P S Y PG     G  W   K  +D LDL   G+   FGR+ N
Sbjct  399  IYREALKAGHEGVMVKNPNSVYSPGKR---GKNWLKKKPLMDTLDLVIVGAEWGFGRRAN  455

Query  399  LMFGGSYS  406
            L+  GSY+
Sbjct  456  LI--GSYT  461


  Database: Non-redundant UniProtKB/SwissProt sequences
    Posted date:  Mar 25, 2018  2:22 PM
  Number of letters in database: 176,816,051
  Number of sequences in database:  469,154

Lambda      K        H
   0.329    0.141    0.412 
Gapped
Lambda      K        H
   0.267   0.0410    0.140 
Matrix: BLOSUM62
Gap Penalties: Existence: 11, Extension: 1
Number of Sequences: 469154
Number of Hits to DB: 1772435
Number of extensions: 1273
Number of successful extensions: 288
Number of sequences better than 100: 56
Number of HSP's better than 100 without gapping: 0
Number of HSP's gapped: 284
Number of HSP's successfully gapped: 56
Length of database: 176816051
T: 21
A: 40
X1: 16 (7.6 bits)
X2: 38 (14.6 bits)
X3: 64 (24.7 bits)
S1: 40 (20.0 bits)
ka-blk-alpha gapped: 1.9
ka-blk-alpha ungapped: 0.7916
ka-blk-alpha_v gapped: 42.6028
ka-blk-alpha_v ungapped: 4.96466
ka-blk-sigma gapped: 43.6362





''';

void main() {
//  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//    // Build our app and trigger a frame.
////    await tester.pumpWidget(MyApp());
//
//    // Verify that our counter starts at 0.
//    expect(find.text('0'), findsOneWidget);
//    expect(find.text('1'), findsNothing);
//
//    // Tap the '+' icon and trigger a frame.
//    await tester.tap(find.byIcon(Icons.add));
//    await tester.pump();
//
//    // Verify that our counter has incremented.
//    expect(find.text('0'), findsNothing);
//    expect(find.text('1'), findsOneWidget);
//  });

  test('crc32 test', () {
//    String path = refSeqDirPath('BMSK_chr11');
//    print(path);
    print(generateCodonTable(defaultCodonTable));
  });

  test('blaster', () {
    var blaster = Blaster(blastContent);
    blaster.displayAlignments(blastContent);
  });

  test('log scale', () {
    // var logScale = LogScale.transformer()..domain = [8, 100000];
    // var ticks = logScale.ticks(5);
    // print('---------------------------');
    // print('ticks: $ticks');

    var domain = List.generate(10, (i) => (i) * .1);

    var logScale = ScaleLog.number(domain: [0, 1], range: [10, 90])..fixDomain();
    var powScale = ScalePow.number(domain: [0, 1], range: [10, 90])..exponent = .5;
    var lineScale = ScaleLinear.number(domain: [0, 1], range: [10, 90]);

    print('ticks: ${logScale.domain} ');

    var logr = domain.map((e) => logScale.scale(e));
    var pr = domain.map((e) => powScale.scale(e));
    var lr = domain.map((e) => lineScale.scale(e));
    print(domain);
    print(lr);
    print(pr);
    print(logr);
  });

  test('color schema', () {
    // Function blue = interpolateBlue();
    // Color c = Color(blue(.3).toInt());
    // print(c);
  });

  test('regex', () {
    var _regExp = RegExp('([^:]+):([0-9]+) *- *([0-9]+)');
    bool v = _regExp.hasMatch('NC_0009133:695666 - 839578');
    print('=======> has match: $v');
  });
}
