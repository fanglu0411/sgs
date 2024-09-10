import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_smart_genome/base/global_state.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/page/admin/species/species_edit_page.dart';
import 'package:flutter_smart_genome/page/admin/species/species_logic.dart';
import 'package:flutter_smart_genome/routes.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/toggle_button_group.dart';
import 'package:get/get.dart';

class GenomeDataListView extends StatefulWidget {
  final SiteItem siteItem;
  final AccountBean account;
  final bool cardView;

  const GenomeDataListView({
    Key? key,
    required this.siteItem,
    required this.account,
    this.cardView = true,
  }) : super(key: key);

  @override
  _GenomeDataListViewState createState() => _GenomeDataListViewState();
}

class _GenomeDataListViewState extends State<GenomeDataListView> {
  Species? _species;
  bool _cardMode = true;
  late SpeciesLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = Get.put(SpeciesLogic(widget.siteItem));
    _cardMode = widget.cardView;
    accountObs.listen(_onAccountChange);
  }

  void _onAccountChange(AccountBean? account) {
    _logic.site = SiteItem(url: account!.url);
    Future.delayed(Duration(milliseconds: 200)).then((c) {
      _logic.loadData(true);
    });
  }

  @override
  void didUpdateWidget(GenomeDataListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.siteItem.url != widget.siteItem.url || oldWidget.account.url != widget.account.url) {
      _logic.site = widget.siteItem;
      _logic.loadData(true);
    }
  }

  Widget _builder(SpeciesLogic logic) {
    Widget _body;
    if (_logic.loading) {
      _body = Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: LoadingWidget(loadingState: LoadingState.loading),
      );
    } else if (_logic.error != null) {
      _body = Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
        child: LoadingWidget(
          loadingState: LoadingState.error,
          message: _logic.error!.message,
          onErrorClick: (s) {
            logic.loadData();
          },
        ),
      );
    } else if (logic.isEmpty) {
      _body = Center(
        child: OutlinedButton.icon(
          icon: Icon(Icons.add, size: 32),
          onPressed: _addOrEditSpecies,
          label: Text('Add Project'),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(200, 128),
            textStyle: TextStyle(fontSize: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      );
    } else {
      _body = _buildList(context, logic.data);
    }
    return _widget(context, _body);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SpeciesLogic>(
      init: _logic,
      builder: _builder,
    );
  }

  PreferredSizeWidget _appBar() {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      title: Text('Project List'),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
      // backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(10),
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: [
        Center(
          child: ToggleButtonGroup(
            constraints: BoxConstraints.tightFor(height: 30, width: 40),
            selectedIndex: _cardMode ? 0 : 1,
            borderRadius: BorderRadius.circular(4),
            onChange: (i) {
              setState(() {
                _cardMode = i == 0;
              });
            },
            children: [
              Tooltip(
                  child: Icon(
                    Icons.grid_view,
                    size: 18,
                  ),
                  message: 'Grid View'),
              Tooltip(child: Icon(Icons.list, size: 18), message: 'List View'),
            ],
          ),
        ),
        SizedBox(width: 12),
        IconButton(
          onPressed: () {
            _logic.loadData(true);
          },
          icon: Icon(Icons.refresh),
          // color: Colors.white,
          tooltip: 'Reload Projects',
        ),
        SizedBox(width: 12),
        IconButton(
          onPressed: () => _addOrEditSpecies(),
          icon: Icon(Icons.add_box),
          tooltip: 'New Project',
          // color: Colors.white,
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget _widget(BuildContext context, Widget body) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    // return body;
    return Scaffold(
      appBar: _appBar(),
      // backgroundColor: Colors.transparent,
      body: body,
    );
  }

  Widget _buildList(BuildContext context, List<Species> species) {
    var _children = (species).map(_cardMode ? _cardItemBuilder : _listItemBuilder);
    if (_cardMode) {
      // return Wrap(
      //   children: _children.toList(),
      //   spacing: 20,
      //   runSpacing: 20,
      // );
      var size = MediaQuery.of(context).size;
      int columns = size.width <= 800 ? 1 : 2;
      var itemWidth = (size.width - 20 * (columns + 1)) / columns;
      double aspectRatio = 3.68;
      return GridView(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: aspectRatio,
        ),
        children: _children.toList(),
      );
    }
    return ListView(
      children: ListTile.divideTiles(tiles: _children, context: context).toList(),
    );
  }

  Widget _listItemBuilder(Species __species) {
    bool speciesSelected = __species == _species;
    Widget leading = __species.iconUrl != null
        ? CircleAvatar(
            child: Image.network(__species.iconUrl!),
          )
        : CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
            child: Text(
              '${__species.name!.substring(0, 1).toUpperCase()}',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
            ),
          );

    Widget? progressWidget;
    if (!__species.statusDone) {
      progressWidget = Text('${__species.progress}%  ${__species.msg ?? ''}', style: TextStyle(height: 1.5));
    }
    return InkWell(
      onDoubleTap: () => __onSpeciesTap(__species, 'track'),
      child: ListTile(
        leading: leading,
        title: Text('${__species.name}'),
        subtitle: progressWidget,
        selected: speciesSelected,
        // onTap: () {},
        minVerticalPadding: 24,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.info_outline, size: 18),
              tooltip: 'About Project',
              onPressed: () => __showProjectDetail(__species),
              style: IconButton.styleFrom(minimumSize: Size(50, 42), padding: EdgeInsets.symmetric(horizontal: 10)),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              icon: Icon(
                Icons.view_list,
                size: 18,
              ),
              label: Text('Data List'),
              onPressed: () => __onSpeciesTap(__species, 'track'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                minimumSize: Size(80, 40),
              ),
            ),
            SizedBox(width: 12),
            // OutlinedButton(
            //   child: Text('Single Cell'),
            //   onPressed: () => __onSpeciesTap(__species, 'cell'),
            // ),
            // SizedBox(width: 12),
            _statusWidget(__species),
            // Chip(
            //   avatar: statusIcon,
            //   label: Text('${__species.status}'),
            //   backgroundColor: __species.statusDone ? Theme.of(context).colorScheme.primary.withAlpha(50) : (__species.statusError ? Colors.red : null),
            // ),
            // IconButton(
            //   tooltip: 'Edit Species',
            //   icon: Icon(Icons.edit),
            //   onPressed: () => _addOrEditSpecies(context, __species),
            // ),
            SizedBox(width: 6),
            IconButton(
              tooltip: 'Delete',
              icon: Icon(Icons.delete),
              color: Colors.red,
              padding: EdgeInsets.zero,
              splashRadius: 20,
              constraints: BoxConstraints.tightFor(width: 40, height: 40),
              onPressed: () => _deleteConfirm(context, __species),
            )
          ],
        ),
      ),
    );
  }

  Widget _statusWidget(Species __species) {
    Widget statusWidget;
    if (__species.statusDone) {
      statusWidget = Chip(
        side: BorderSide.none,
        avatar: Icon(Icons.check_circle, color: Colors.green),
        label: Text('${__species.status}'),
        visualDensity: VisualDensity.compact,
        backgroundColor: Colors.green.withOpacity(.25),
      );
    } else if (__species.statusError) {
      statusWidget = Chip(
        side: BorderSide.none,
        avatar: Icon(Icons.error, color: Colors.redAccent),
        label: Text('${__species.status}', style: TextStyle(color: Colors.redAccent)),
        backgroundColor: null,
      );
    } else {
      statusWidget = Chip(
        side: BorderSide.none,
        avatar: CustomSpin(color: Theme.of(context).colorScheme.primary),
        label: Text(__species.progress == null ? '${__species.status}' : '${__species.progress}%'),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.25),
      );
    }
    return SizedBox(child: statusWidget, width: 110);
  }

  Widget _cardItemBuilder(Species __species) {
    bool speciesSelected = __species == _species;
    Widget leading = __species.iconUrl != null
        ? CircleAvatar(
            child: Image.network(__species.iconUrl!),
          )
        : CircleAvatar(
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.25),
            child: Text('${__species.name!.substring(0, 1).toUpperCase()}', style: TextStyle(fontSize: 20)),
          );

    Widget? progressWidget;
    if (!__species.statusDone) {
      progressWidget = Text('${__species.progress ?? ''}%  ${__species.msg ?? ''}', style: TextStyle(height: 1.5, fontWeight: FontWeight.w300));
    }

    return Material(
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(width: 2, color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(10)),
      // color: Colors.grey[850],
      // borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: leading,
            title: Text('${__species.name}'),
            subtitle: progressWidget,
            selected: speciesSelected,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            onTap: () {},
            // trailing: Icon(Icons.keyboard_arrow_right_rounded),
            // trailing: _statusWidget(__species),
          ),
          Divider(height: 1.0, color: Theme.of(context).dividerColor),
          Spacer(),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(width: 10),
              _statusWidget(__species),
              Spacer(),
              TextButton.icon(
                icon: Icon(Icons.info, size: 18),
                label: Text('About'),
                onPressed: () => __showProjectDetail(__species),
                style: TextButton.styleFrom(minimumSize: Size(100, 42)),
              ),
              SizedBox(width: 1, height: 20, child: VerticalDivider(width: 1, thickness: 1)),
              TextButton.icon(
                icon: Icon(Icons.list, size: 18),
                label: Text('Data List'),
                onPressed: () => __onSpeciesTap(__species, 'track'),
                style: TextButton.styleFrom(minimumSize: Size(100, 42)),
              ),
              // IconButton(
              //   tooltip: 'Edit Species',
              //   icon: Icon(Icons.edit),
              //   onPressed: () => _addOrEditSpecies(context, __species),
              // ),
              SizedBox(width: 1, height: 20, child: VerticalDivider(width: 1, thickness: 1)),
              TextButton.icon(
                icon: Icon(Icons.delete, size: 18),
                label: Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red, minimumSize: Size(100, 42)),
                onPressed: () => _deleteConfirm(context, __species),
              )
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }

  void __onSpeciesTap(Species __species, String clickType) {
    if (__species.statusError) {
      showWarnNotification(
        title: Text('Species error'),
        subtitle: Text('${_species!.msg}'),
        duration: Duration(milliseconds: 3500),
      );
      return;
    }
    if (__species.statusError || !__species.statusDone) {
      showWarnNotification(
        title: Text('Species status is not ready!'),
        subtitle: Text('Species is ${__species.status}, please wait a few minutes!'),
        duration: Duration(milliseconds: 3500),
      );
      return;
    }
    _onSpeciesTap(__species, clickType);
  }

  void _deleteConfirm(BuildContext context, Species species) async {
    var dialog = (context) => AlertDialog(
          title: Text('Delete Project ?'),
          content: Text("Are you sure want to delete project { ${species.name} } ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('DELETE'),
            ),
            SizedBox(width: 10),
          ],
        );
    var result = await showDialog(context: context, builder: dialog);
    if (result) {
      _logic.deleteSpecies(species);
    }
  }

  void _addOrEditSpecies([Species? species = null]) async {
    var result = await Navigator.of(context).pushNamed(
      RoutePath.manage_genome_edit,
      arguments: SpeciesEditParams(widget.siteItem, species, widget.account),
    );
    _logic.loadData();
  }

  void _onSpeciesTap(Species species, [String? type]) {
    Navigator.of(context).pushNamed(
      type == 'track' ? RoutePath.manage_genome_tracks : RoutePath.manage_sc_list,
      arguments: SpeciesEditParams(widget.siteItem, species, widget.account, asDialog: false),
    );
  }

  @override
  void dispose() {
    Get.delete<SpeciesLogic>();
    super.dispose();
  }

  __showProjectDetail(Species _species) {
    Navigator.of(context).pushNamed(
      RoutePath.project_home_page,
      arguments: SpeciesEditParams(widget.siteItem, _species, widget.account, asDialog: false),
    );
  }
}
