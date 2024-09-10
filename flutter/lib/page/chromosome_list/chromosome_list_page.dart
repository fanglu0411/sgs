import 'package:dartx/dartx.dart' as dx;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_smart_genome/mixin/view_size_mixin.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';
import 'package:flutter_smart_genome/service/sgs_app_service.dart';

import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';

class ChromosomeListPage extends StatefulWidget {
  final String species;
  final String? chr;
  final String? chr2;
  final ValueChanged<List<ChromosomeData?>>? onSelected;
  final bool asPage;

  const ChromosomeListPage({
    Key? key,
    required this.species,
    this.chr,
    this.chr2,
    this.onSelected,
    this.asPage = true,
  }) : super(key: key);

  @override
  _ChromosomeListPageState createState() => _ChromosomeListPageState();
}

class _ChromosomeListPageState extends State<ChromosomeListPage> with ViewSizeMixin {
  List<ChromosomeData> _chromosomes = [];
  late num _maxSize;
  bool _loading = true;
  List<ChromosomeData>? _filteredChromosomes;
  TextEditingController? _searchFieldController;

  late String? _id;
  String? _id2;
  String? _chooseSelectedChr;

  @override
  void initState() {
    super.initState();
    _id = widget.chr;
    _id2 = widget.chr2;
    _chooseSelectedChr = 'chr1';
    _searchFieldController = TextEditingController();
    _loadChromosomes();
  }

  _loadChromosomes() async {
    String host = SgsAppService.get()!.site!.url;
    _chromosomes = await AbsPlatformService.get()!.loadChromosomes(host: host, speciesId: widget.species);
    if (_chromosomes.length > 0) {
      List<num> sizeList = _chromosomes.map<num>((e) => e.range.size).toList();
      _maxSize = sizeList.reduce(math.max);
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  String? get checkedChrId => _chooseSelectedChr == 'chr1' ? _id : _id2;

  @override
  Widget build(BuildContext context) {
    var body;
    if (_loading) {
      body = Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: LoadingWidget(
          loadingState: LoadingState.loading,
          message: 'Chromosome is loading...',
          onErrorClick: (s) => _loadChromosomes,
        ),
      );
    } else {
      List<Widget> list = (_filteredChromosomes ?? _chromosomes).map<Widget>(_buildItem).toList();
      bool empty = list.isEmpty;
      ChromosomeData? _chr1 = null != _id ? _chromosomes.firstOrNullWhere((e) => e.id == _id) : null;
      ChromosomeData? _chr2 = null != _id2 ? _chromosomes.firstOrNullWhere((e) => e.id == _id2) : null;

      bool dark = Brightness.dark == Theme.of(context).brightness;
      Widget? header = null; //_chr1 == null ? null : buildHeader(dark, _chr1, _chr2);

      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) header,
          _buildSearchField(context),
          if (empty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: LoadingWidget(
                loadingState: LoadingState.error,
                message: 'Chromosome is empty!',
                onErrorClick: (s) => _loadChromosomes,
              ),
            ),
          Expanded(
            child: Scrollbar(
              child: ListView(
                children: ListTile.divideTiles(tiles: list, context: context).toList(),
              ),
            ),
          )
        ],
      );
    }

    if (!widget.asPage) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Chromosome'),
        actions: [
          Tooltip(
            child: TextButton(onPressed: _confirmChromosomeSelection, child: Text('Update')),
            message: 'Update chromosome selection',
          ),
        ],
      ),
      body: body,
    );
  }

  Card buildHeader(bool dark, ChromosomeData _chr1, ChromosomeData _chr2) {
    return Card(
      elevation: 2,
      color: dark ? Colors.grey[700] : Colors.grey[200],
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MultiChromosomeGroup(
            chr1: _chr1,
            chr2: _chr2,
            onFocusChange: (chr) {
              _chooseSelectedChr = chr;
              setState(() {});
            },
            onRemoveChr2: () {
              setState(() {
                _id2 = null;
              });
            },
          ),
          if (!widget.asPage)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: MaterialButton(
                padding: EdgeInsets.zero,
                height: 32,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                colorBrightness: Brightness.dark,
                color: Theme.of(context).colorScheme.primary,
                onPressed: _confirmChromosomeSelection,
                child: Text('Update Chromosomes'),
              ),
            ),
          SizedBox(height: 12),
          Divider(height: 1.0),
        ],
      ),
    );
  }

  _confirmChromosomeSelection() {
    ChromosomeData? _chr1 = null != _id ? _chromosomes.firstOrNullWhere((e) => e.id == _id) : null;
    ChromosomeData? _chr2 = null != _id2 ? _chromosomes.firstOrNullWhere((e) => e.id == _id2) : null;
    List<ChromosomeData?> list = [_chr1, _chr2];
    if (widget.onSelected != null) {
      widget.onSelected!(list);
    } else {
      Navigator.of(context).maybePop(list);
    }
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 32,
      child: TextField(
        controller: _searchFieldController,
        decoration: InputDecoration(
          hintText: 'chr name keyword',
          prefixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          suffixIcon: IconButton(
            iconSize: 20,
            splashRadius: 15,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchFieldController!.text = '';
              _onFilterChromosome(context, null);
            },
          ),
        ),
        onSubmitted: (value) => _onFilterChromosome(context, value),
        onChanged: (value) => _onFilterChromosome(context, value),
      ),
    );
  }

  void _onFilterChromosome(BuildContext context, String? value) {
    setState(() {
      if (null == value || value.length == 0) {
        _filteredChromosomes = null;
      } else {
        _filteredChromosomes = _chromosomes.where((element) => element.chrName.toLowerCase().contains(value)).toList();
      }
    });
  }

  Widget _buildItem(ChromosomeData chromosome) {
    double progress = _maxSize != null ? chromosome.range.size / _maxSize : 0;
    bool selected = chromosome.id == checkedChrId;
    return CustomPaint(
      painter: ProgressPainter(progress: progress, color: Theme.of(context).colorScheme.primary.withAlpha(100)),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity(vertical: VisualDensity.minimumDensity, horizontal: VisualDensity.minimumDensity),
        title: Text(chromosome.chrName),
        subtitle: Text(chromosome.range.print()),
        trailing: selected ? Icon(Icons.check) : null,
        selected: selected,
        onTap: () => _onItemSelect(chromosome),
      ),
    );
  }

  _onItemSelect(ChromosomeData e) {
    if (_chooseSelectedChr == 'chr1') {
      _id = e.id;
    } else {
      _id2 = e.id;
    }
    setState(() {});
    // if (widget.onSelected != null) {
    //   setState(() {
    //     _id = e.id;
    //   });
    //   widget.onSelected(e);
    // } else {
    //   Navigator.of(context).maybePop(e);
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _searchFieldController?.dispose();
  }
}

class ProgressPainter extends CustomPainter {
  late double progress;
  late Color color;
  double progressHeight = 2;

  ProgressPainter({
    this.progress = 0,
    this.color = Colors.lightBlue,
  }) {
    _paint = Paint()..color = color;
  }

  Paint? _paint;

  @override
  void paint(Canvas canvas, Size size) {
    double progressWidth = size.width * progress;
    if (progressWidth < 1) progressWidth = 1.0;

    canvas.drawRect(Rect.fromLTWH(0, size.height - progressHeight, progressWidth, progressHeight), _paint!);
  }

  @override
  bool shouldRepaint(ProgressPainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}

class MultiChromosomeGroup extends StatefulWidget {
  final ChromosomeData? chr1;
  final ChromosomeData? chr2;
  final ValueChanged<String>? onFocusChange;
  final VoidCallback? onRemoveChr2;

  MultiChromosomeGroup({
    Key? key,
    this.chr1,
    this.chr2,
    this.onFocusChange,
    this.onRemoveChr2,
  }) : super(key: key) {
    assert(chr1 != null);
  }

  @override
  _MultiChromosomeGroupState createState() => _MultiChromosomeGroupState();
}

class _MultiChromosomeGroupState extends State<MultiChromosomeGroup> {
  String _selectedChr = 'chr1';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildChr('chr1', widget.chr1!),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.height, size: 16),
              Icon(Icons.height, size: 16),
              Icon(Icons.height, size: 16),
            ],
          ),
          widget.chr2 == null ? _buildEmptyChr2() : buildChr('chr2', widget.chr2!),
        ],
      ),
    );
  }

  Widget _buildEmptyChr2() {
    bool chr1Selected = _selectedChr == 'chr2';
    return MaterialButton(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16),
          SizedBox(width: 10),
          Text(
            'select chromosome below',
            style: TextStyle(
              fontWeight: FontWeight.w100,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: chr1Selected ? 2.0 : 1.0,
          color: chr1Selected ? Theme.of(context).colorScheme.primary : Colors.black54,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: () {
        _selectedChr = 'chr2';
        widget.onFocusChange?.call('chr2');
        setState(() {});
      },
    );
  }

  Widget buildChr(String chrId, ChromosomeData chr) {
    bool chrSelected = _selectedChr == chrId;

    return MaterialButton(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text('${chrId}: '),
          SizedBox(width: 10),
          Text(
            chr.chrName,
            style: TextStyle(
              fontWeight: chr == null ? FontWeight.w100 : FontWeight.w200,
              // color: chr == null ? Colors.black38 : Theme.of(context).colorScheme.primary,
            ),
          ),
          if (chrId == 'chr2') Spacer(),
          if (chrId == 'chr2')
            IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 20, height: 20),
              splashRadius: 12,
              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
              tooltip: 'remove',
              onPressed: widget.onRemoveChr2,
            )
        ],
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: chrSelected ? 2.0 : 1.0,
          color: chrSelected ? Theme.of(context).colorScheme.primary : Colors.black54,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: () {
        _selectedChr = chrId;
        widget.onFocusChange?.call(chrId);
        setState(() {});
      },
    );
  }
}
