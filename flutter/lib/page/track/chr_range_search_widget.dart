
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/chromosome_list/chromosome_list_page.dart';
import 'package:flutter_smart_genome/widget/basic/chr_position_input_field.dart';
import 'package:flutter_smart_genome/widget/basic/range_input_field_widget.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

class ChrRangeSearchWidget extends StatefulWidget {
  final ChromosomeData? chromosome;
  final Range? range;
  final bool asPage;
  final dynamic speciesId;

  final ValueChanged<ChromosomeData>? onChromosomeChange;
  final ValueChanged<Range>? onRangeChange;

  const ChrRangeSearchWidget({
    Key? key,
    this.chromosome,
    this.range,
    this.onChromosomeChange,
    this.onRangeChange,
    this.asPage = true,
    this.speciesId,
  }) : super(key: key);

  @override
  _ChrRangeSearchWidgetState createState() => _ChrRangeSearchWidgetState();
}

class _ChrRangeSearchWidgetState extends State<ChrRangeSearchWidget> {
  ChromosomeData? _chr;

  @override
  void initState() {
    super.initState();
    _chr = widget.chromosome;
  }

  @override
  Widget build(BuildContext context) {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    Widget body = Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChrPositionInputField(chr: _chr, range: widget.range),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
//              borderRadius: BorderRadius.circular(6),
            ),
            child: RangeInputFieldWidget(
              range: widget.range,
              borderWidth: 1,
              brightness: Theme.of(context).brightness,
              prefix: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                ),
                onPressed: _onSelectChr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${_chr?.chrName} '),
                    Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
              autoFocus: true,
              onSubmit: (range) {
                //Navigator.of(context).pop(range);
                if (_chr?.id == widget.chromosome?.id) {
                  Navigator.of(context).pop(range);
//                  widget.onRangeChange?.call(range);
                } else {
                  Navigator.of(context).pop(_chr);
//                  widget.onChromosomeChange?.call(_chr);
                }
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(child: SearchGeneWidget())
        ],
      ),
    );
//    if (widget.asPage) {
    body = Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: body,
    );
//    }
    return body;
  }

  void _onSelectChr() async {
    Widget _chrList = ChromosomeListPage(
      chr: _chr?.id,
      species: widget.speciesId,
      onSelected: (chr) {
        Navigator.of(context).pop(chr);
      },
    );

    var result;

    if (widget.asPage) {
      result = await showCupertinoModalPopup(
        context: context,
        builder: (context) => _chrList,
      );
//      result = await showModalBottomSheet(
//        context: context,
//        builder: (context) => _chrList,
//        isScrollControlled: false,
//      );
    } else {
      result = await showDialog(
        barrierColor: Colors.white10.withAlpha(10),
        context: context,
        builder: (c) {
          double _height = MediaQuery.of(c).size.height;
          return AlertDialog(
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            content: Container(
              constraints: BoxConstraints.tightFor(width: 600, height: _height * .8),
              child: _chrList,
            ),
          );
        },
      );
    }

    if (null != result) {
      setState(() {
        _chr = result;
      });
      widget.onChromosomeChange?.call(result);
    }
  }
}

class SearchGeneWidget extends StatefulWidget {
  @override
  _SearchGeneWidgetState createState() => _SearchGeneWidgetState();
}

class _SearchGeneWidgetState extends State<SearchGeneWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              suffixIcon: TextButton(
                child: Text('Search'),
                onPressed: () {},
              ),
              hintText: 'gene id/ attribute keyword',
              border: UnderlineInputBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('History'),
        ),
      ],
    );
  }
}
