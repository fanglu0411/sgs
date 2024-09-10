import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/bean/feature_beans.dart';
import 'package:flutter_smart_genome/extensions/widget_extensions.dart';

class FeatureSearchWidget extends StatefulWidget {
  final ValueChanged<Feature>? onResult;
  final List<Feature> dataSource;

  const FeatureSearchWidget({
    Key? key,
    this.onResult,
    this.dataSource = const [],
  }) : super(key: key);

  @override
  _FeatureSearchWidgetState createState() => _FeatureSearchWidgetState();
}

class _FeatureSearchWidgetState extends State<FeatureSearchWidget> {
  late TextEditingController _controller;

  List<Feature> _findFeatures = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
  }

  void _searchFeature(String keyword) async {
    if (keyword.length == 0) {
      return;
    }
    _findFeatures = _searchFeatureInternal(widget.dataSource, keyword);
    setState(() {});
  }

  List<Feature> _searchFeatureInternal(List<Feature> features, String keyword) {
    List<Feature> findFeatures = [];
    for (Feature feature in features) {
      if ((feature.featureId).contains(keyword)) {
        findFeatures.add(feature);
      } else if (feature.hasChildren) {
        List<Feature> findChildren = _searchFeatureInternal(feature.children!, keyword);
        if (findChildren.length > 0) {
          findFeatures.addAll(findChildren);
        }
      }
    }
    return findFeatures;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 56,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: inputBorder(),
              hintText: 'Search keyword, gene, attribute',
              suffixIcon: IconButton(
                //constraints: BoxConstraints.tightFor(width: 20, height: 20),
                icon: Icon(Icons.search),
                onPressed: () => _searchFeature(_controller.text),
              ),
            ),
            onChanged: (v) {
              if (v.length == 0) {
                setState(() {
                  _findFeatures = [];
                });
              }
            },
            onEditingComplete: () {
              _searchFeature(_controller.text);
            },
          ),
        ),
        if (_findFeatures.length > 0)
          Container(
            constraints: BoxConstraints.expand(height: 400),
            child: ListView.builder(
              itemCount: _findFeatures.length,
              itemBuilder: (context, index) {
                Feature _feature = _findFeatures[index];
                return ListTile(
                  title: Text('${_feature.featureId}'),
                  subtitle: Text('${_feature.range}'),
                  onTap: () {
                    widget.onResult?.call(_feature);
                  },
                ).withBottomBorder(color: Theme.of(context).dividerColor);
              },
            ),
          )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
