import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/markdown_widget.dart';

class UpdateSide extends StatelessWidget {
  const UpdateSide({Key? key}) : super(key: key);

  final String updates = '''
## Hic add normalize 
## Add app layout mode 
## sc compare update  
## track zoom optimize  
## Track zoom animation and duration customize
      ''';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SimpleMarkdownWidget(source: updates),
    );
  }
}
