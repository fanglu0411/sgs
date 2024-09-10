import 'package:flutter/material.dart';

class FeatureInputWidget extends StatefulWidget {
  final List<String> features;
  final ValueChanged<List<String>>? onChange;

  const FeatureInputWidget({
    Key? key,
    required this.features,
    this.onChange,
  }) : super(key: key);

  @override
  State<FeatureInputWidget> createState() => _FeatureInputWidgetState();
}

class _FeatureInputWidgetState extends State<FeatureInputWidget> {
  String _reg = ',|;|\n|\r|\t';

  bool _editMode = false;
  late TextEditingController _textEditingController;

  late List<String> _features;

  @override
  void initState() {
    super.initState();
    _features = widget.features;
    _textEditingController = TextEditingController(text: (_features).join('\n'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.primary), borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              'Feature List',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 1),
          SizedBox(height: 10),
          IndexedStack(
            index: _editMode ? 0 : 1,
            children: [
              Container(
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'feature1\n'
                        'feature2\n'
                        'feature3\n'
                        'or\n'
                        'feature1, feature2, feature3',
                  ),
                  onChanged: (v) {
                    print(v);
                  },
                  minLines: 6,
                  maxLines: 10,
                  onSubmitted: _submit,
                ),
              ),
              GestureDetector(
                onDoubleTap: () {
                  _editMode = true;
                  setState(() {});
                },
                child: Container(
                  // constraints: BoxConstraints(maxHeight: 400, minHeight: 200),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.start,
                    children: _features.map((f) {
                      return InputChip(
                        label: Text(f),
                        onDeleted: () {
                          _features.remove(f);
                          _textEditingController.text = _features.join('\n');
                          setState(() {});
                          widget.onChange?.call(_features);
                        },
                      );
                    }).toList(),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: _editMode ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
            children: [
              if (_editMode)
                ElevatedButton(
                  onPressed: () {
                    _editMode = false;
                    setState(() {});
                  },
                  child: Text('BACK'),
                ),
              if (_editMode) SizedBox(width: 12),
              if (_editMode)
                ElevatedButton(
                  onPressed: () {
                    _textEditingController.text = "";
                  },
                  child: Text('CLEAR'),
                ),
              if (_editMode) SizedBox(width: 12),
              if (_editMode)
                ElevatedButton(
                  onPressed: () {
                    _submit(_textEditingController.text);
                  },
                  child: Text('COMMIT'),
                ),
              if (!_editMode)
                ElevatedButton(
                  onPressed: () {
                    _editMode = true;
                    setState(() {});
                  },
                  child: Text('EDIT'),
                )
            ],
          ),
        ],
      ),
    );
  }

  _submit(String v) {
    _features = v.split(RegExp(_reg)).where((f) => f.isNotEmpty).map((e) => e.trim()).toList();
    _editMode = false;
    setState(() {});
    widget.onChange?.call(_features);
  }
}
