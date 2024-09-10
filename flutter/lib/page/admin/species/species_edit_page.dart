import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/mixin/scaffold_key_mixin.dart';
import 'package:flutter_smart_genome/network/api/simple_request.dart';
import 'package:flutter_smart_genome/network/http_response.dart';
import 'package:flutter_smart_genome/page/admin/species/species_base_edit.dart';
import 'package:flutter_smart_genome/service/abs_platform_service.dart';

import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';

class SpeciesEditParams {
  final Species? species;
  final SiteItem site;
  final AccountBean account;
  final bool asDialog;

  SpeciesEditParams(this.site, this.species, this.account, {this.asDialog = true});
}

class SpeciesEditPage extends StatefulWidget {
  final Species? species;
  final SiteItem site;
  final AccountBean account;
  final ValueChanged<Species>? onBack;

  final ValueChanged<Species>? onSpeciesCreate;

  const SpeciesEditPage({
    Key? key,
    this.species,
    this.onBack,
    required this.site,
    required this.account,
    this.onSpeciesCreate,
  }) : super(
          key: key,
        );

  @override
  _SpeciesEditPageState createState() => _SpeciesEditPageState();
}

class _SpeciesEditPageState extends State<SpeciesEditPage> with ScaffoldKeyMixin, TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;

  Function? _toastDismiss;

  Species? _species;

  bool _confirmExit = true;

  @override
  void initState() {
    super.initState();
    _species = widget.species;
  }

  @override
  void didUpdateWidget(SpeciesEditPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _species = widget.species;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        return _confirmExit;
      },
      child: Scaffold(
        key: scaffoldKey,
        // backgroundColor: Colors.transparent,
        appBar: AppBar(
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
          // backgroundColor: Colors.green,
          // systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Text(null == _species || _species!.isEmpty ? 'Add Project' : 'Edit Project'),
          centerTitle: false,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: SpeciesBaseForm(
        map: _species?.basicMap(),
        host: widget.site.url,
        onSubmit: _onSubmit,
      ),
    );
  }

  _onSubmit(Map<String, dynamic> formValues) async {
    _toastDismiss = BotToast.showLoading(clickClose: true);
    bool _isCreate = _species == null || _species!.isEmpty;

//    var event = _isCreate ? CreateEvent(formValues, widget.site) : UpdateEvent(_species.id, formValues, widget.site);
//    BlocProvider.of<SpeciesBloc>(context).add(event);

    if (_isCreate) {
      if ((formValues['isDir'] ?? false)) {
        //select dir, batch add tracks
        _submitBatch(formValues);
        return;
      }

      var result = await AbsPlatformService.get(widget.site)!.createSpecies(
        host: widget.site.url,
        body: formValues,
      );
      _dismiss();

      if (result.success) {
        Map rst = result.body;
        _species = Species.fromMap({...formValues, "species_id": rst['species_id']});
        logger.d(_species);
        showSuccessNotification(title: Text('Add species success!'));
        // _setNextStep();
        if (widget.onSpeciesCreate != null) {
          widget.onSpeciesCreate?.call(_species!);
        } else {
          Navigator.of(context).pop(_species);
        }
      } else {
        showErrorNotification(title: Text('Add species fail!'), subtitle: Text('${result.error ?? ''}'));
      }
    } else {
      //only request update
      _dismiss();
//      showSnackBarWithMsg('update species');
      showToast(text: 'Update is not available', backgroundColor: Colors.red);
    }
  }

  void _submitBatch(Map<String, dynamic> formValues) async {
    HttpResponseBean resp = await postJson(
      path: '${widget.site.url}/api/species/bulk',
      data: {
        "folder_path": formValues['fasta_file'],
        "species_name": formValues['species_name'],
      },
      cache: false,
    );
    // logger.d(resp.bodyStr);
    await Future.delayed(Duration(milliseconds: 1500));
    _dismiss();
    if (resp.success) {
      Map rst = resp.body;
      _species = Species.fromMap({'species_name': formValues['species_name'], "species_id": rst['species_id']});
      showSuccessNotification(title: Text('Batch generate track success'));
      widget.onSpeciesCreate?.call(_species!);
    } else {
      showErrorNotification(title: Text('Batch generate track success'), subtitle: Text('${resp.error ?? ''}'));
    }
  }

  @override
  bool get wantKeepAlive => true;

  void _dismiss() {
    if (_toastDismiss != null) _toastDismiss!();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
    _dismiss();
  }
}
