import 'package:flutter/material.dart';

import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:json_view/json_view.dart';

class JsonWidget extends StatefulWidget {
  final Map json;
  final bool search;
  const JsonWidget({Key? key, this.search = true, required this.json}) : super(key: key);

  @override
  State<JsonWidget> createState() => _JsonWidgetState();
}

class _JsonWidgetState extends State<JsonWidget> {
  @override
  Widget build(BuildContext context) {
    return JsonView(
      json: widget.json, //.map<String, dynamic>((key, value) => MapEntry<String, dynamic>(key, value)),
      styleScheme: JsonStyleScheme(
        keysStyle: TextStyle(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK, color: Colors.black87),
        valuesStyle: TextStyle(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK),
      ),
      padding: EdgeInsets.only(top: 20, left: 10),
    );
  }
}

// class _JsonWidgetState extends State<JsonWidget> {
//   final searchController = TextEditingController();
//   final itemScrollController = ItemScrollController();
//   final DataExplorerStore store = DataExplorerStore();
//
//   @override
//   initState() {
//     super.initState();
//     _loadData();
//   }
//
//   _loadData() async {
//     Map<String, dynamic> map = widget.json.map<String, dynamic>((key, value) => MapEntry<String, dynamic>(key, value));
//     await store.buildNodes(map, areAllCollapsed: true);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool _dark = Theme.of(context).brightness == Brightness.dark;
//     var style = TextStyle(fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK);
//     return ChangeNotifierProvider.value(
//       value: store,
//       child: Consumer<DataExplorerStore>(
//         builder: (context, state, child) => Container(
//           padding: EdgeInsets.symmetric(horizontal: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 10),
//               if (widget.search)
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: searchController,
//                         onChanged: (term) => state.search(term),
//                         decoration: const InputDecoration(
//                           hintText: 'Search',
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
//                           constraints: BoxConstraints(maxHeight: 30),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     if (state.searchResults.isNotEmpty) Text(_searchFocusText()),
//                     if (state.searchResults.isNotEmpty)
//                       IconButton(
//                         padding: EdgeInsets.zero,
//                         constraints: BoxConstraints.tightFor(width: 30, height: 30),
//                         splashRadius: 16,
//                         onPressed: () {
//                           store.focusPreviousSearchResult();
//                           _scrollToSearchMatch();
//                         },
//                         icon: const Icon(Icons.arrow_drop_up),
//                       ),
//                     if (state.searchResults.isNotEmpty)
//                       IconButton(
//                         padding: EdgeInsets.zero,
//                         constraints: BoxConstraints.tightFor(width: 30, height: 30),
//                         splashRadius: 16,
//                         onPressed: () {
//                           store.focusNextSearchResult();
//                           _scrollToSearchMatch();
//                         },
//                         icon: const Icon(Icons.arrow_drop_down),
//                       ),
//                   ],
//                 ),
//               // const SizedBox(height: 6.0),
//               Row(
//                 children: [
//                   TextButton.icon(
//                     icon: Icon(MaterialCommunityIcons.expand_all, size: 16),
//                     onPressed: state.areAllExpanded() ? null : state.expandAll,
//                     label: const Text('Expand All'),
//                   ),
//                   const SizedBox(width: 8.0),
//                   TextButton.icon(
//                     icon: Icon(MaterialCommunityIcons.collapse_all, size: 16),
//                     onPressed: state.areAllCollapsed() ? null : state.collapseAll,
//                     label: const Text('Collapse All'),
//                   ),
//                   const SizedBox(width: 8.0),
//                   TextButton.icon(
//                     icon: Icon(MaterialCommunityIcons.content_copy, size: 16),
//                     onPressed: () {
//                       Clipboard.setData(ClipboardData(text: json.encode(widget.json))).then((value) {
//                         showToast(text: 'Data copied');
//                       });
//                     },
//                     label: const Text('Copy'),
//                   ),
//                 ],
//               ),
//               Divider(height: 1.0),
//               const SizedBox(height: 6.0),
//               Expanded(
//                 child: JsonDataExplorer(
//                   nodes: state.displayNodes,
//                   itemScrollController: itemScrollController,
//                   itemSpacing: 4,
//
//                   /// Builds a widget after each root node displaying the
//                   /// number of children nodes that it has. Displays `{x}`
//                   /// if it is a class or `[x]` in case of arrays.
//                   rootInformationBuilder: (context, node) => DecoratedBox(
//                     decoration: const BoxDecoration(
//                       color: Color(0x80E1E1E1),
//                       borderRadius: BorderRadius.all(Radius.circular(2)),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                       child: Text(
//                         node.isClass ? '{${node.childrenCount}}' : '[${node.childrenCount}]',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: const Color(0xFF6F6F6F),
//                         ),
//                       ),
//                     ),
//                   ),
//                   collapsableToggleBuilder: (context, node) => AnimatedRotation(
//                     turns: node.isCollapsed ? -0.25 : 0,
//                     duration: const Duration(milliseconds: 300),
//                     child: const Icon(Icons.arrow_drop_down),
//                   ),
//                   trailingBuilder: (context, node) => node.isFocused && !node.isRoot
//                       ? IconButton(
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints.tightFor(width: 30, height: 18),
//                           icon: const Icon(Icons.copy, size: 16),
//                           splashRadius: 15,
//                           onPressed: () => _copyNodeValue(node),
//                         )
//                       : const SizedBox(),
//
//                   /// Creates a custom format for classes and array names.
//                   rootNameFormatter: (dynamic name) => '$name',
//                   valueFormatter: (value) {
//                     if (value is num) return "${value}";
//                     bool isColor = value is String ? GetUtils.hasMatch(value, r'^#[0-9a-fA-F]{6,8}$') : false;
//                     if (isColor) {
//                       return "${value}";
//                     }
//                     return '"${value}"';
//                   },
//                   valueStyleBuilder: (dynamic value, style) {
//                     final isUrl = _valueIsUrl(value);
//                     bool isColor = value is String ? GetUtils.hasMatch(value, r'^#[0-9a-fA-F]{6,8}$') : false;
//
//                     if (value is num) {
//                       style = style.copyWith(color: Colors.blueAccent);
//                     } else if (isColor) {
//                       style = style.copyWith(
//                         color: Colors.white70,
//                         backgroundColor: Color(int.tryParse(value.substring(1), radix: 16)).withAlpha(255),
//                         height: 1.1,
//                       );
//                     } else {
//                       style = style.copyWith(color: Colors.green);
//                     }
//                     return PropertyOverrides(
//                       style: isUrl
//                           ? style.copyWith(
//                               decoration: TextDecoration.underline,
//                             )
//                           : style,
//                       onTap: isUrl ? () => _launchUrl(value as String) : null,
//                     );
//                   },
//
//                   /// Theme definitions of the json data explorer
//                   theme: DataExplorerTheme(
//                     rootKeyTextStyle: style,
//                     propertyKeyTextStyle: style,
//                     keySearchHighlightTextStyle: style.copyWith(
//                       backgroundColor: Theme.of(context).highlightColor,
//                     ),
//                     focusedKeySearchHighlightTextStyle: style.copyWith(
//                       backgroundColor: const Color(0xFFF29D0B),
//                     ),
//                     valueTextStyle: style.copyWith(
//                       color: Colors.red,
//                     ),
//                     valueSearchHighlightTextStyle: style.copyWith(
//                       color: Colors.red,
//                       backgroundColor: Theme.of(context).focusColor,
//                       fontSize: 14,
//                     ),
//                     focusedValueSearchHighlightTextStyle: style.copyWith(
//                       backgroundColor: const Color(0xFFF29D0B),
//                       fontSize: 14,
//                     ),
//                     indentationLineColor: Theme.of(context).dividerColor,
//                     highlightColor: Theme.of(context).highlightColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _searchFocusText() => '${store.focusedSearchResultIndex + 1} of ${store.searchResults.length}';
//
//   void _copyNodeValue(NodeViewModelState node) {
//     if (node.isRoot) {
//       final value = node.isClass ? 'class' : 'array';
//       debugPrint('${node.key}: $value');
//       return;
//     }
//     // debugPrint('${node.key}: ${node.value}');
//     Clipboard.setData(ClipboardData(text: "${node.value}"));
//   }
//
//   void _scrollToSearchMatch() {
//     final index = store.displayNodes.indexOf(store.focusedSearchResult.node);
//     if (index != -1) {
//       itemScrollController.scrollTo(
//         index: index,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOutCubic,
//       );
//     }
//   }
//
//   bool _valueIsUrl(dynamic value) {
//     if (value is String) {
//       return Uri.tryParse(value)?.hasAbsolutePath ?? false;
//     }
//     return false;
//   }
//
//   Future _launchUrl(String url) {
//     // return openu(url);
//   }
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }
// }