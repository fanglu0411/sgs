import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/page/session/session_logic.dart';
import 'package:flutter_smart_genome/util/file_util.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/scroll_controller_builder.dart';
import 'package:flutter_smart_genome/widget/loading_widget.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SessionWidget extends StatefulWidget {
  final bool asPage;
  final TrackSession? currentSession;
  final ValueChanged<TrackSession>? onChanged;

  const SessionWidget({
    Key? key,
    this.asPage = false,
    this.currentSession,
    this.onChanged,
  }) : super(key: key);

  @override
  _SessionWidgetState createState() => _SessionWidgetState();
}

class _SessionWidgetState extends State<SessionWidget> {
  TextEditingController? _inputController;

  DateFormat _dateFormat = DateFormat.yMEd();

  // final SessionLogic logic = Get.put(SessionLogic());

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  Widget __builder(BuildContext context, BoxConstraints constraints, SessionLogic logic) {
    TrackSession? _currentSession = logic.currentSession ?? widget.currentSession;
    Widget _widget = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentSession != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Text('Current session', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14)),
            ),
          if (_currentSession != null) _buildCurrentSessionWidget(constraints, _currentSession, logic),
          _inputWidget(),
          Expanded(child: _sessionListWidget(constraints, logic)),
        ],
      ),
    );
    if (widget.asPage) {
      _widget = Scaffold(
        appBar: AppBar(title: Text('Session')),
        body: _widget,
      );
    }
    return _widget;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GetBuilder<SessionLogic>(
          init: SessionLogic(),
          builder: (logic) => __builder(context, constraints, logic),
        );
      },
    );
  }

  _buildCurrentSessionWidget(BoxConstraints constraints, TrackSession session, SessionLogic logic) {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    bool _mobile = isMobile(context, constraints.biggest);
    return Container(
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(5),
        color: _dark ? Colors.grey[700] : Colors.grey[200],
      ),
      child: ListTile(
        selected: true,
        dense: _mobile,
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        horizontalTitleGap: 0,
        title: Text('${session.speciesName}-${session.chrName}:${session.range?.print('..')}'),
        subtitle: Text('${session.url}'),
        trailing: IconButton(
          icon: Icon(MaterialCommunityIcons.content_save_all),
          iconSize: 18,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: 20, height: 20),
          tooltip: 'Save current session',
          onPressed: () {
            logic.addSession(session);
          },
        ),
      ),
    );
  }

  Widget _inputWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      height: 32,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                // border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide()),
                hintText: 'input share url here',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                prefixIcon: Icon(Icons.insert_link, size: 16),
                suffixIcon: IconButton(
                  icon: Icon(AntDesign.enter),
                  iconSize: 18,
                  tooltip: 'GO',
                  padding: EdgeInsets.zero,
                  onPressed: () => _checkUrl(_inputController!.text),
                ),
              ),
              onSubmitted: _checkUrl,
            ),
          ),
        ],
      ),
    );
  }

  void _checkUrl(String url) async {
    var _url = await validateSessionUrl(url);
    if (_url != null) {
      TrackSession? session = await TrackSession.fromUrl(_url);
      if (null != session) _onResult(session);
    } else {
      showToast(text: 'Session Url pass fail.');
    }
  }

  void _onResult(TrackSession session) {
    if (widget.onChanged != null) {
      widget.onChanged!.call(session.copy(autoSave: true));
    } else {
      Navigator.of(context).maybePop(session.copy(autoSave: true));
    }
  }

  Widget _sessionListWidget(BoxConstraints constraints, SessionLogic logic) {
    if (logic.empty) {
      return LoadingWidget(
        loadingState: LoadingState.noData,
        message: 'No session saved',
      );
    }

    bool _mobile = isMobile(context, constraints.biggest);

    var children = logic.sessions.map((session) {
      var _deleteButton = IconButton(
        constraints: BoxConstraints.tightFor(width: 20, height: 20),
        tooltip: 'DELETE',
        padding: EdgeInsets.zero,
        icon: Icon(Icons.delete),
        iconSize: 18,
        onPressed: () => logic.deleteSession(session),
      );
      var siteWidget = Text('${session.url}');
      var time = DateTime.fromMillisecondsSinceEpoch(session.saveTime!);
      var timeWidget = Text(
        '${_dateFormat.format(time)} ${time.hour}:${time.minute}',
        style: Theme.of(context).textTheme.bodySmall,
      );
      var trailing = _mobile ? _deleteButton : Row(mainAxisSize: MainAxisSize.min, children: [timeWidget, _deleteButton]);
      var subtitle = _mobile ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [siteWidget, timeWidget]) : siteWidget;

      return ListTile(
        dense: _mobile,
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        horizontalTitleGap: 0,
        title: Text('${session.speciesName} - ${session.chrName}:${session.range?.print('..')}'),
        subtitle: subtitle,
        trailing: trailing,
        onTap: () => _onResult(session),
      );
    });
    return ListView(
      children: ListTile.divideTiles(tiles: children, context: context).toList(),
    );
  }

  @override
  void dispose() {
    _inputController!.dispose();
    super.dispose();
  }
}
