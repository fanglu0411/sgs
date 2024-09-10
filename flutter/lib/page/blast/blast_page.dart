import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/components/blast_result_widget.dart';

class BlastPage extends StatefulWidget {
  @override
  _BlastPageState createState() => _BlastPageState();
}

class _BlastPageState extends State<BlastPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blast Result')),
      body: BlastResultWidget(blastResult: ''),
    );
  }
}