var defaultStarts = ['ATG'];
var defaultStops = ['TAA', 'TAG', 'TGA'];

Map defaultCodonTable = {
  "TCA": "S",
  "TCC": "S",
  "TCG": "S",
  "TCT": "S",
  "TTC": "F",
  "TTT": "F",
  "TTA": "L",
  "TTG": "L",
  "TAC": "Y",
  "TAT": "Y",
  "TAA": "*",
  "TAG": "*",
  "TGC": "C",
  "TGT": "C",
  "TGA": "*",
  "TGG": "W",
  "CTA": "L",
  "CTC": "L",
  "CTG": "L",
  "CTT": "L",
  "CCA": "P",
  "CCC": "P",
  "CCG": "P",
  "CCT": "P",
  "CAC": "H",
  "CAT": "H",
  "CAA": "Q",
  "CAG": "Q",
  "CGA": "R",
  "CGC": "R",
  "CGG": "R",
  "CGT": "R",
  "ATA": "I",
  "ATC": "I",
  "ATT": "I",
  "ATG": "M",
  "ACA": "T",
  "ACC": "T",
  "ACG": "T",
  "ACT": "T",
  "AAC": "N",
  "AAT": "N",
  "AAA": "K",
  "AAG": "K",
  "AGC": "S",
  "AGT": "S",
  "AGA": "R",
  "AGG": "R",
  "GTA": "V",
  "GTC": "V",
  "GTG": "V",
  "GTT": "V",
  "GCA": "A",
  "GCC": "A",
  "GCG": "A",
  "GCT": "A",
  "GAC": "D",
  "GAT": "D",
  "GAA": "E",
  "GAG": "E",
  "GGA": "G",
  "GGC": "G",
  "GGG": "G",
  "GGT": "G"
};

Map generateCodonTable(Map table) {
  /**
   *  take CodonTable above and generate larger codon table that includes
   *  all permutations of upper and lower case nucleotides
   */
  var tempCodonTable = {};
  for (String codon in table.keys) {
    // looping through codon table, make sure not hitting generic properties...
    if (table.containsKey(codon)) {
      var aa = table[codon];
      // console.log("Codon: ", codon, ", aa: ", aa);
      var nucs = [[], [], []];
      for (var i = 0; i < 3; i++) {
        var nuc = codon[i];
//        nucs[i] = [];
        nucs[i].add(nuc.toUpperCase());
        nucs[i].add(nuc.toLowerCase());
      }
      for (var i = 0; i < 2; i++) {
        var n0 = nucs[0][i];
        for (var j = 0; j < 2; j++) {
          var n1 = nucs[1][j];
          for (var k = 0; k < 2; k++) {
            var n2 = nucs[2][k];
            var triplet = n0 + n1 + n2;
            tempCodonTable[triplet] = aa;
          }
        }
      }
    }
  }
  return tempCodonTable;
}
