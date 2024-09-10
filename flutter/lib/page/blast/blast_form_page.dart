import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/routes.dart';

class BlastFormPage extends StatefulWidget {
  @override
  _BlastFormPageState createState() => _BlastFormPageState();
}

class _BlastFormPageState extends State<BlastFormPage> {
  List<String> _blastTypes = ['blastp', 'blastx', 'blastn', 'tblastn'];
  List<String> _eValues = ['1e-5', '1e-10', '1e-15', '1e-20'];
  List<String> _targets = ['gene', 'cds', 'chromosome'];
  TextEditingController _controller = TextEditingController();

  String _blastType = 'blastn';
  String _eValue = '1e-5';
  String _target = 'gene';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blast')),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _blastTypeRow(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _eValueRow(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _targetRow(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _sequenceField(),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
//              child: ElevatedButton.icon(
//                onPressed: () {
//                  Navigator.of(context).pushNamed(RoutePath.blast_result);
//                },
//                icon: Icon(Icons.file_upload),
//                label: Text('SUBMIT'),
//              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: () {
            Navigator.of(context).pushNamed(RoutePath.blast_result);
          }),
    );
  }

  Widget _blastTypeRow() {
    Map<String, Widget> segs = _blastTypes.asMap().map(
          (key, value) => MapEntry(
            value,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(value),
            ),
          ),
        );
    Color _color = Theme.of(context).colorScheme.primary;
    return Row(
      children: <Widget>[
        SizedBox(
          child: Text('Blast Type: ', textAlign: TextAlign.right),
          width: 70,
        ),
        CupertinoSegmentedControl<String>(
          groupValue: _blastType,
          borderColor: _color,
          selectedColor: _color,
          children: segs,
          onValueChanged: (value) {
            setState(() {
              _blastType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _eValueRow() {
    Map<String, Widget> segs = _eValues.asMap().map(
          (key, value) => MapEntry(
            value,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(value),
            ),
          ),
        );
    Color _color = Theme.of(context).colorScheme.primary;
    return Row(
      children: <Widget>[
        SizedBox(
          child: Text('E-value: ', textAlign: TextAlign.right),
          width: 70,
        ),
        CupertinoSegmentedControl<String>(
          groupValue: _eValue,
          borderColor: _color,
          selectedColor: _color,
          children: segs,
          onValueChanged: (value) {
            setState(() {
              _eValue = value;
            });
          },
        ),
      ],
    );
  }

  Widget _targetRow() {
    Map<String, Widget> segs = _targets.asMap().map(
          (key, value) => MapEntry(
            value,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(value),
            ),
          ),
        );
    Color _color = Theme.of(context).colorScheme.primary;
    return Row(
      children: <Widget>[
        SizedBox(
          child: Text('Target: ', textAlign: TextAlign.right),
          width: 70,
        ),
        CupertinoSegmentedControl<String>(
          groupValue: _target,
          borderColor: _color,
          selectedColor: _color,
          children: segs,
          onValueChanged: (value) {
            setState(() {
              _target = value;
            });
          },
        ),
      ],
    );
  }

  Widget _sequenceField() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double height = constraints.maxHeight;
        int lines = height ~/ 10;
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
            border: OutlineInputBorder(),
            hintText: '''single sequence:
ACACAAAAAAATTATTATACG

multi sequences:
> sequence1
ACACAAAAAAATTATTATACG
> sequence2
GTGGGTAATAACACATATACC
            ''',
            labelText: 'Sequence',
//                suffixIcon: Icon(Icons.clear),
          ),
          textAlignVertical: TextAlignVertical.top,
//          onChanged: _onTextChange,
        );
      },
    );
  }
}
