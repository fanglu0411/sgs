import itertools
import pandas as pd


def read_gff3(input_file):
    return Gff3DataFrame(input_file)


class Gff3DataFrame(object):
    """This class contains header information in the header attribute and
    a actual annotation data in the pandas dataframe in the df
    attribute.

    """

    def __init__(self, input_gff_file=None, input_df=None, input_header=None) -> None:
        """Create an instance."""
        if input_gff_file is not None:
            self._gff_file = input_gff_file
            self._read_gff3_to_df()
            self._read_gff_header()
        else:
            self.df = input_df
            self.header = input_header

    def _read_gff3_to_df(self) -> pd.DataFrame:
        """Create a pandas dataframe.

        By the pandas library the gff3 file is read and
        a pd dataframe with the given column-names is returned."""
        self.df = pd.read_csv(
            self._gff_file,
            sep="\t",
            comment="#",
            names=[
                "seq_id",
                "source",
                "type",
                "start",
                "end",
                "score",
                "strand",
                "phase",
                "attributes",
            ],
        )
        return self.df

    def _read_gff_header(self) -> str:
        """Create a header.

        The header of the gff file is read, means all lines,
        which start with '#'."""
        self.header = ""
        for line in open(self._gff_file):
            if line.startswith("#"):
                self.header += line
            else:
                break
        return self.header

    def _to_xsv(self, output_file=None, sep=None) -> None:
        """Function for creating a csv or tsv file."""

        self.df.to_csv(
            output_file,
            sep=sep,
            index=False,
            header=[
                "seq_id",
                "source",
                "type",
                "start",
                "end",
                "score",
                "strand",
                "phase",
                "attributes",
            ],
        )

    def to_csv(self, output_file=None) -> None:
        """Create a csv file.

        The pandas data frame is saved as a csv file.

        :param output_file: Desired name of the output csv file
        :type output_file: str
        :return: csv file with the content of the dataframe
        :rtype: data file in csv format
        """
        self._to_xsv(output_file=output_file, sep=",")

    def to_tsv(self, output_file=None) -> None:
        """Create a tsv file.

        The pandas data frame is saved as a tsv file.

        :param output_file: Desired name of the output tsv file
        :type output_file: str
        :return: tsv file with the content of the dataframe
        :rtype: data file in tsv format
        """
        self._to_xsv(output_file=output_file, sep="\t")

    def to_gff3(self, gff_file) -> None:
        """Create a gff3 file.

        The pandas dataframe is saved as a gff3 file.

        :param gff_file: Desired name of the output gff file
        :type gff_file: str
        :return: gff3 file with the content of the dataframe
        :rtype: data file in gff3 format
        """
        df_nine_col = self.df[
            [
                "seq_id",
                "source",
                "type",
                "start",
                "end",
                "score",
                "strand",
                "phase",
                "attributes",
            ]
        ]
        gff_feature = df_nine_col.to_csv(sep="\t", index=False, header=None)
        with open(gff_file, "w") as fh:
            fh.write(self.header)
            fh.write(gff_feature)

    def filter_feature_of_type(self, feature_type_list) -> "Gff3DataFrame":
        """Filtering the pandas dataframe by feature_type.

        For this method a list of feature-type(s) has to be given,
        as e.g. ['CDS', 'ncRNA'].

        :param feature_type_list: List of name(s) of the desired feature(s)
        :type feature_type_list: list
        :return: original header and dataframe of the selected features
                saved as object of the class Gff3DataFrame
        :rtype: class 'gffpandas.gffpandas.Gff3DataFrame'
        """
        feature_df = self.df.loc[self.df.type.isin(feature_type_list)]
        return Gff3DataFrame(input_df=feature_df, input_header=self.header)

    def filter_by_length(self, min_length=None, max_length=None) -> "Gff3DataFrame":
        """Filtering the pandas dataframe by the gene_length.

        For this method the desired minimal and maximal bp length
        have to be given.

        :param min_length: minimal bp length of the feature
        :type min_length: int
        :param max_length: maximal bp length of the feature
        :type max_length: int
        :return: original header and dataframe with features, whose lengths
                fits the set parameters, saved as object of the class
                Gff3DataFrame
        :rtype: class 'gffpandas.gffpandas.Gff3DataFrame'
        """
        gene_length = self.df.end - self.df.start
        filtered_by_length = self.df[
            (gene_length >= min_length) & (gene_length <= max_length)
        ]
        return Gff3DataFrame(input_df=filtered_by_length, input_header=self.header)

    def attributes_to_columns(self) -> pd.DataFrame:
        """Saving each attribute-tag to a single column.

        Attribute column will be split by the tags in the single columns.
        For this method only a pandas DataFrame and not a Gff3DataFrame
        will be returned. Therefore, this data frame can not be saved as
        gff3 file.

        :return: pandas dataframe, whereby the attribute column of the gff3
                file are splitted into the different attribute tags
        :rtype: pandas DataFrame
        """
        attribute_df = self.df.copy()
        df_attributes = attribute_df.loc[:, "seq_id":"attributes"]
        attribute_df["at_dic"] = attribute_df.attributes.apply(
            lambda attributes: dict(
                [
                    key_value_pair.split(sep="=", maxsplit=1)
                    for key_value_pair in attributes.split(";")
                ]
            )
        )
        attribute_df["at_dic_keys"] = attribute_df["at_dic"].apply(
            lambda at_dic: list(at_dic.keys())
        )
        merged_attribute_list = list(
            itertools.chain.from_iterable(attribute_df["at_dic_keys"])
        )
        nonredundant_list = sorted(list(set(merged_attribute_list)))
        for atr in nonredundant_list:
            df_attributes[atr] = attribute_df["at_dic"].apply(
                lambda at_dic: at_dic.get(atr)
            )
        return df_attributes

    def get_feature_by_attribute(self, attr_tag, attr_value_list) -> "Gff3DataFrame":
        """Filtering the pandas dataframe by a attribute.

        The 9th column of a gff3-file contains the list of feature
        attributes in a tag=value format.
        For this method the desired attribute tag as well as the
        corresponding value have to be given. If the value is not available
        an empty dataframe would be returned.

        :param attr_tag: Name of attribute tag, by which the df
                         will be filtered
        :type attr_tag: str
        :param attr_value_list: List of value name or several value names,
                which has/have to be associated with the attribute tag.
                If an entry includes the value with the corresponding tag it
                is selected
        :type attr_value_list: list
        :return: original header and dataframe with the entries, which contain
            the desired attribute values, both saved as object of the class
            Gff3DataFrame
        :rtype: class 'gffpandas.gffpandas.Gff3DataFrame'
        """
        df_copy = self.df.copy()
        attribute_df = Gff3DataFrame.attributes_to_columns(self)
        filtered_by_attr_df = df_copy.loc[attribute_df[attr_tag].isin(attr_value_list)]
        return Gff3DataFrame(input_df=filtered_by_attr_df, input_header=self.header)

    def stats_dic(self) -> dict:
        """Gives the following statistics for the data:

        The maximal bp-length, minimal bp-length, the count of sense (+) and
        antisense (-) strands as well as the count of each available
        feature.

        :return: information about the given dataframe, which are the length of
            the longest and shortest feature entry (in bp), the number of
            feature on the sense and antisense strand and the number of
            different feature types.
        :rtype: dictionary
        """
        df_w_region = self.df[self.df.type != "region"]
        gene_length = df_w_region.end - df_w_region.start
        strand_counts = pd.value_counts(self.df["strand"]).to_dict()
        type_counts = pd.value_counts(self.df["type"]).to_dict()
        stats_dic = {
            "Maximal_bp_length": gene_length.max(),
            "Minimal_bp_length": gene_length.min(),
            "Counted_strands": strand_counts,
            "Counted_feature_types": type_counts,
        }
        return stats_dic

    def overlaps_with(
        self,
        seq_id=None,
        start=None,
        end=None,
        type=None,
        strand=None,
        complement=False,
    ) -> "Gff3DataFrame":
        """To see which entries overlap with a comparable feature.

        For this method the chromosom accession number has to be given.
        The start and end bp position for the to comparable feature have to be
        given, as well as optional the feature-type of it and if it is on the
        sense (+) or antisense (-) strand. \n
        | Possible overlaps (see code): \n
        | --------=================------------------
        | --------------=====================--------
        |
        | -------===================---------------
        | -------===================---------------
        |
        | ------========================-----------
        | ------============-----------------------
        |
        | ---------=====================-----------
        | ------------------============-----------

        By selecting 'complement=True', all the feature, which do not overlap
        with the to comparable feature will be returned.

        :param seq_id: accession number of the feature
        :type seq_id: str
        :param start: start position of the feature
        :type start: int
        :param end: end position of the feature
        :type end: int
        :param type: type of the feature
        :type type: str
        :param strand: minus (-) for antisense and plus (+) for sense strand
        :type strand: str
        :return: original header and dataframe, containing the entries which
            overlap or do not overlap (complement=True) with the given
            parameters, both saved as object of the class Gff3DataFrame
        :rtype: class 'gffpandas.gffpandas.Gff3DataFrame'
        """
        overlap_df = self.df
        condition = (
            ((overlap_df.start > start) & (overlap_df.start < end))
            | ((overlap_df.end > start) & (overlap_df.end < end))
            | ((overlap_df.start < start) & (overlap_df.end > start))
            | ((overlap_df.start == start) & (overlap_df.end == end))
            | ((overlap_df.start == start) & (overlap_df.end > end))
            | ((overlap_df.start < start) & (overlap_df.end == end))
        )
        overlap_df = overlap_df[overlap_df.seq_id == seq_id]
        if type is not None:
            overlap_df = overlap_df[overlap_df.type == type]
        if strand is not None:
            overlap_df = overlap_df[overlap_df.strand == strand]
        if not complement:
            overlap_df = overlap_df[condition]
        else:
            overlap_df = overlap_df[~condition]
        return Gff3DataFrame(input_df=overlap_df, input_header=self.header)

    def find_duplicated_entries(self, seq_id=None, type=None) -> "Gff3DataFrame":
        """Find entries which are redundant.

        For this method the chromosom accession number (seq_id) as well as the
        feature-type have to be given. Then all entries which are redundant
        according to start- and end-position as well as strand-type will be
        found.

        :param seq_id: corresponding accession number
        :type seq_id: str
        :param type: feature type
        :type type: str
        :return: original header and dataframe containing the duplicated
            entries, both saved as object of the class Gff3DataFrame
        :rtype: class 'gffpandas.gffpandas.Gff3DataFrame'
        """
        input_df = self.df[self.df.seq_id == seq_id]
        df_feature = input_df[input_df.type == type]
        duplicate = df_feature.loc[df_feature[["end", "start", "strand"]].duplicated()]
        return Gff3DataFrame(input_df=duplicate, input_header=self.header)
