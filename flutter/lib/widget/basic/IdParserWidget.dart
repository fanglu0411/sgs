import 'package:flutter/material.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';

class IdParserWidget extends StatefulWidget {
  final String regExp;

  final EdgeInsets? padding;

  final ValueChanged<List<String>>? onChange;

  const IdParserWidget({Key? key, this.padding, this.regExp = ',|;| |\n|\r', this.onChange}) : super(key: key);

  @override
  _IdParserWidgetState createState() => _IdParserWidgetState();
}

class _IdParserWidgetState extends State<IdParserWidget> {
  TextEditingController _controller = TextEditingController();

  List<String> _parsedList = [];
  List<String> _selectedList = [];

  late RegExp _regExp;

  bool _selectAll = true;

  @override
  void initState() {
    super.initState();
    _regExp = RegExp(widget.regExp);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: _buildInputWidget(),
          ),
          SizedBox(width: 20),
          Expanded(
            flex: 5,
            child: _parsedListWidget(),
          )
        ],
      ),
    );
  }

  Widget _buildInputWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.clear_all),
              constraints: BoxConstraints.tightFor(width: 30, height: 30),
              iconSize: 20,
              hoverColor: Colors.transparent,
              padding: EdgeInsets.all(0),
              tooltip: 'Clear',
              onPressed: () {
                _controller.clear();
              },
            ),
            IconButton(
              constraints: BoxConstraints.tightFor(width: 30, height: 30),
              iconSize: 20,
              icon: Icon(Icons.select_all),
              hoverColor: Colors.transparent,
              padding: EdgeInsets.all(0),
              tooltip: 'Select All',
              onPressed: () {
                _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
              },
            ),
          ],
        ),
        SizedBox(height: 5),
        Expanded(child: LayoutBuilder(
          builder: (context, constraints) {
            double height = constraints.maxHeight;
            int lines = height ~/ 18;
//            return TextArea();
            return TextField(
              controller: _controller,
              minLines: lines,
              maxLines: lines,
              textAlign: TextAlign.start,
              autofocus: false,
              obscureText: false,
              enableInteractiveSelection: true,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                border: inputBorder(),
                hintText: 'gene1\ngene2\ngene3',
                labelText: 'Element id',
//                suffixIcon: Icon(Icons.clear),
              ),
              textAlignVertical: TextAlignVertical.top,
              onChanged: _onTextChange,
            );
          },
        )),
        SizedBox(height: 10),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.file_upload),
          label: Text('Upload from file'),
        ),
      ],
    );
  }

  void _onTextChange(String value) {
    List ids = value.split(_regExp).map((e) => e.trim()).where((value) => value.length > 0).distinct().toList();
    _parsedList = ids as List<String>;
    _selectedList = List.from(ids);
    setState(() {});
    _callback();
  }

  void _toggleSelectAll(bool selectAll) {
    _selectAll = selectAll;
    if (selectAll) {
      _selectedList = List.from(_parsedList);
    } else {
      _selectedList.clear();
      _selectedList = [];
    }
    setState(() {});
  }

  Widget _parsedListWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
//          color: Colors.grey[200],
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text('Parsed Ids', textScaleFactor: 1.3),
              ),
              IconButton(
                hoverColor: Colors.transparent,
                tooltip: _selectAll ? 'Select All' : 'Unselect All',
                icon: Icon(_selectAll ? Icons.check_box : Icons.check_box_outline_blank),
                onPressed: () => _toggleSelectAll(!_selectAll),
              ),
            ],
          ),
        ),
        Expanded(
          child: Material(
            color: Theme.of(context).cardColor,
            child: ListView.builder(
              itemCount: _parsedList.length,
              itemBuilder: (context, index) {
                String _id = _parsedList[index];
                bool selected = _selectedList.contains(_id);
                return ListTile(
                  title: Text(_id),
                  selected: selected,
                  leading: selected ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),
                  onTap: () {
                    if (_selectedList.contains(_id)) {
                      _selectedList.remove(_id);
                    } else {
                      _selectedList.add(_id);
                    }
                    setState(() {});
                    _callback();
                  },
                ).withBottomBorder(color: Theme.of(context).dividerColor);
              },
            ),
          ),
        ),
      ],
    );
  }

  _callback() {
    if (widget.onChange != null) {
      widget.onChange!(List.from(_selectedList));
    }
  }
}