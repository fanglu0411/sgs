import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';
import 'package:dartx/dartx.dart';

class CascadeSelectListWidget<P, C> extends StatefulWidget {
  final Map<P, List<C>> dataSource;

  final Function1<dynamic, String>? parentTitleFunc;
  final Function1<dynamic, String>? childTitleFunc;

  final ValueChanged<List>? onChange;

  CascadeSelectListWidget({
    Key? key,
    required this.dataSource,
    this.onChange,
    this.parentTitleFunc,
    this.childTitleFunc,
  }) : super(key: key);

  @override
  _CascadeSelectListWidgetState createState() => _CascadeSelectListWidgetState<P, C>();
}

class _CascadeSelectListWidgetState<P, C> extends State<CascadeSelectListWidget> {
  late P _selectParent;
  List<C> _selectedChildren = [];

  Map<P, List<C>> _selectedMap = {};

  @override
  void initState() {
    super.initState();
    _selectParent = widget.dataSource.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _searchWidget(),
        _controlBar(),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(child: _parentList(), flex: 3),
//              SizedBox(width: 20),
              Expanded(child: _childrenList(), flex: 5),
              SizedBox(width: 20),
              Expanded(child: _selectedListWidget(), flex: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchWidget() {
    return Container(
//      constraints: BoxConstraints.expand(height: 60),
      padding: EdgeInsets.symmetric(vertical: 20),
      child: TextField(
        decoration: InputDecoration(
          border: inputBorder(),
          hintText: 'Input gene id/ transcript id /etc to search',
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          labelText: 'Search Elements',
        ),
      ),
    );
  }

  Widget _controlBar() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Text('Elements Type', textScaleFactor: 1.3),
        ),
        Expanded(
          flex: 5,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.clear_all),
                tooltip: 'clear',
                onPressed: _onClearAllChildren,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Selected Elements', textScaleFactor: 1.3),
          ),
        ),
      ],
    );
  }

  _onClearAllChildren() {
    //_selectedMap.remove(_selectParent);
    List<C> children = widget.dataSource[_selectParent] as List<C>;
    for (C c in children) {
      if (_selectedChildren.contains(c)) {
        _selectedChildren.remove(c);
      }
    }
    setState(() {});
  }

  Widget _parentList() {
    List<P> parents = widget.dataSource.keys.toList() as List<P>;

    return Material(
      color: Theme.of(context).cardColor,
      child: ListView.builder(
        itemCount: parents.length,
        itemBuilder: (context, index) {
          P p = parents[index];
          bool _selected = p == _selectParent;
          String _title = widget.parentTitleFunc != null ? widget.parentTitleFunc!(p) : '$p';
          return ListTile(
            title: Text(_title),
            selected: _selected,
            trailing: _selected ? Icon(Icons.play_arrow) : null,
            onTap: () {
              if (_selectParent == p) return;
              setState(() {
                _selectParent = p;
              });
            },
          ).withBottomBorder(color: Theme.of(context).dividerColor);
        },
      ),
    );
  }

  Widget _childrenList() {
    List<C> children = widget.dataSource[_selectParent] as List<C>;
    return Container(
      color: Theme.of(context).cardColor.withAlpha(200),
      child: ListView.builder(
        itemCount: children.length,
        itemBuilder: (context, index) {
          C c = children[index];
          String _title = widget.childTitleFunc != null ? widget.childTitleFunc!(c) : '$c';
          bool selected = _selectedChildren.contains(c);
          return ListTile(
            title: Text(_title),
            selected: selected,
            leading: selected ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),
            onTap: () {
              //List<C> children = _selectedMap[_selectParent] ?? [];
              setState(() {
                if (_selectedChildren.contains(c)) {
                  _selectedChildren.remove(c);
                } else {
                  _selectedChildren.add(c);
                }
                //_selectedMap[_selectParent] = children;
                _callback();
              });
            },
          ).withBottomBorder(color: Theme.of(context).dividerColor);
        },
      ),
    );
  }

  Widget _selectedListWidget() {
    //List<C> _selectedChildren = _selectedMap.values.flatten();

    return Material(
      color: Theme.of(context).cardColor.withAlpha(200),
      child: ListView.builder(
        itemCount: _selectedChildren.length,
        itemBuilder: (context, index) {
          C c = _selectedChildren[index];

          return ListTile(
            title: Text('${c}'),
            trailing: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedChildren.remove(c);
                  _callback();
                });
              },
            ),
            onTap: () {},
          ).withBottomBorder(color: Theme.of(context).dividerColor);
        },
      ),
    );
  }

  _callback() {
    ValueChanged<List<C>>? onChange = widget.onChange;
    if (onChange != null) {
      //List<C> _selectedChildren = _selectedMap.values.flatten();
      onChange(List.from(_selectedChildren));
    }
  }
}