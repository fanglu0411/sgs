import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';

List<String> operators = ['<', '<=', '==', ">", '>='];

class FilterColumn {
  String column;
  List<String>? tags;
  FilterColumn(this.column, {this.tags});
  bool get hasTag => tags != null && tags!.length > 0;
}

class FilterItem {
  String? get column => this['column'];
  String? get tag => this['tag'];
  String? get operator => this['operator'];
  dynamic get value => this['value'];
  String? get logicTo => this['pre_logic_operator'];

  void set logicTo(String? logic) {
    this['pre_logic_operator'] = logic;
  }

  late Map<String, dynamic> _form;

  FilterItem({String? column, String? tag, String? operator, String? value, String? linkCondition}) {
    _form = {
      'column': column,
      'tag': tag,
      'operator': operator,
      'value': value,
      'pre_logic_operator': linkCondition,
    };
  }

  void setValue(String key, value) {
    _form[key] = value;
  }

  operator [](String key) => _form[key];
  operator []=(String key, value) => _form[key] = value;

  Map get json => _form;

  String get sql => 'column = ${column} and tag = $tag and value ${operator} $value';

  bool validate() {
    return column != null && operator != null && value != null;
  }
}

Future<List<FilterItem>?> showTableFilterDialog(BuildContext context, List<FilterColumn> filterColumns, {List<FilterItem>? filters}) async {
  var dialog = AlertDialog(
    title: Row(
      children: [
        Text('Advanced Data Filter'),
        Spacer(),
        IconButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          icon: Icon(Icons.close),
          tooltip: 'Close',
        ),
      ],
    ),
    content: Container(
      constraints: BoxConstraints(maxWidth: 900, minWidth: 400),
      child: TableFilterView(
        filterColumns: filterColumns,
        filters: filters,
        onSubmit: (filters) {
          Navigator.of(context).pop(filters);
        },
      ),
    ),
  );
  return showDialog<List<FilterItem>?>(context: context, builder: (c) => dialog, barrierDismissible: false);
}

class TableFilterView extends StatefulWidget {
  final ValueChanged<List<FilterItem>?>? onSubmit;
  final List<FilterColumn> filterColumns;
  final List<FilterItem>? filters;
  const TableFilterView({Key? key, this.onSubmit, required this.filterColumns, this.filters}) : super(key: key);

  @override
  State<TableFilterView> createState() => _TableFilterViewState();
}

class _TableFilterViewState extends State<TableFilterView> {
  late List<FilterItem> _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.filters ??
        [
          FilterItem(column: widget.filterColumns.first.column, operator: "==", linkCondition: null),
        ];
  }

  void _onDelete(FilterItem filter) {
    _filters.remove(filter);
    if (_filters.length > 0) _filters.first.logicTo = null;
    setState(() {});
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._filters.mapIndexed((i, e) => FilterView(
                  filter: e,
                  nextFilter: i < _filters.length - 1 ? _filters[i + 1] : null,
                  index: i,
                  optionColumns: widget.filterColumns,
                  onDelete: _onDelete,
                  onChange: (v) {
                    setState(() {});
                  },
                )),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 80),
              child: OutlinedButton.icon(
                onPressed: _addFilter,
                icon: Icon(Icons.add),
                label: Text('Add Filter'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _cancel,
                  child: Text('CANCEL'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red, side: BorderSide(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: _commit,
                  child: Text('OK'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(90, 36),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _addFilter() {
    _filters.add(FilterItem(linkCondition: 'and'));
    setState(() {});
  }

  void _cancel() {
    widget.onSubmit?.call(null);
  }

  void _commit() {
    if (_formKey.currentState!.validate()) {}
    if (_filters.every((f) => f.validate())) {
      widget.onSubmit?.call(_filters);
    } else {
      showToast(text: 'Filter has invalid value');
    }
  }
}

class FilterView extends StatefulWidget {
  final FilterItem filter;
  final FilterItem? nextFilter;
  final int index;
  final ValueChanged<FilterItem> onDelete;
  final ValueChanged<FilterItem> onChange;
  final List<FilterColumn> optionColumns;

  const FilterView({Key? key, required this.filter, required this.index, required this.onDelete, this.nextFilter, required this.onChange, required this.optionColumns}) : super(key: key);

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  @override
  Widget build(BuildContext context) {
    var operatorColor = widget.filter.logicTo == "and" ? Colors.orange : Colors.blue;
    var filterColor = widget.filter.logicTo == "and" || (widget.nextFilter?.logicTo == 'and') ? Colors.orange : Colors.blue;

    var columns = widget.optionColumns.map<String>((e) => e.column).toList();
    List<String>? tags = widget.filter.column == null ? null : widget.optionColumns.firstOrNullWhere((c) => c.column == widget.filter.column)?.tags;

    Widget _widget = Container(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
      child: Row(
        children: [
          Text(
            'Filter ${widget.index + 1}',
            style: TextStyle(color: filterColor, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 10),
          Expanded(child: _filterItem('Column', 'column', widget.filter, columns)),
          Expanded(child: _filterItem('Tag', 'tag', widget.filter, tags)),
          Expanded(child: _filterItem('Operator', 'operator', widget.filter, operators)),
          Expanded(child: _textItem('Value', 'value', widget.filter)),
          if (widget.index > 0)
            IconButton(
              constraints: BoxConstraints.tightFor(width: 32, height: 32),
              padding: EdgeInsets.zero,
              splashRadius: 18,
              onPressed: () => widget.onDelete.call(widget.filter),
              icon: Icon(Icons.delete),
              tooltip: 'delete filter',
            )
          else
            SizedBox(width: 28),
        ],
      ),
    );
    if (widget.index > 0) {
      _widget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(width: 10),
              SizedBox(
                width: 64,
                child: Text(
                  '${widget.filter.logicTo}'.toUpperCase(),
                  style: TextStyle(color: operatorColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              ToggleButtonGroup(
                borderRadius: BorderRadius.circular(5),
                constraints: BoxConstraints.tightFor(height: 24),
                selectedIndex: widget.filter.logicTo == 'and' ? 0 : 1,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'AND',
                        style: TextStyle(fontWeight: FontWeight.w500, color: widget.filter.logicTo == 'and' ? Colors.orange : null),
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'OR',
                        style: TextStyle(fontWeight: FontWeight.w500, color: widget.filter.logicTo == 'or' ? Colors.blue : null),
                      )),
                ],
                onChange: (i) {
                  widget.filter.logicTo = i == 0 ? 'and' : 'or';
                  // setState(() {});
                  widget.onChange.call(widget.filter);
                },
              ),
            ],
          ),
          _widget,
        ],
      );
    }
    return _widget;
  }

  Widget _filterItem(
    String title,
    String key,
    FilterItem filter,
    List<String>? options,
  ) {
    List<DropdownMenuItem<String>> items = (options ?? []).map((e) {
      return DropdownMenuItem(child: Text('${e}'), value: e);
    }).toList();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonFormField(
        items: items,
        onChanged: (v) {
          filter[key] = v;
          if (key == 'column') setState(() {});
        },
        value: filter[key],
        hint: Text('None'),
        decoration: InputDecoration(
          prefixText: '${key}: ',
          errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          // prefixStyle: TextStyle(fontSize: 12),
          border: OutlineInputBorder(),
          constraints: BoxConstraints(maxHeight: 32),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        ),
        // validator: (v) {
        //   if (v == null || v.isEmpty) return "${key} is empty";
        //   return null;
        // },
      ),
    );
  }

  Widget _textItem(
    String title,
    String key,
    FilterItem filter,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        onChanged: (v) {
          filter[key] = v;
        },
        initialValue: filter[key],
        autofocus: false,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
            child: Text('$key: ', style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16)),
          ),
          hintText: 'None',
          border: OutlineInputBorder(),
          constraints: BoxConstraints(maxHeight: 30),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        ),
      ),
    );
  }
}
