import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_smart_genome/components/md/md_preview.dart';
import 'package:flutter_smart_genome/page/site/deploy_intro.dart';
import 'package:flutter_smart_genome/page/site/script_params_widget.dart';
import 'package:flutter_smart_genome/widget/basic/alert_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/base/ui_config.dart';
import 'package:flutter_smart_genome/components/sgs_logo.dart';
import 'package:flutter_smart_genome/page/site/password_field.dart';
import 'package:flutter_smart_genome/page/site/ssh_form_widget.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/util/native_window_util/title_bar_wrapper/title_bar_wrapper.dart';
import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';
import 'package:get/get.dart';

import 'package:xterm/xterm.dart';

import 'create_server_page_logic.dart';

Widget createServerPage() => CreateServerPage();

class CreateServerPage extends StatefulWidget {
  const CreateServerPage({Key? key}) : super(key: key);

  @override
  _CreateServerPageState createState() => _CreateServerPageState();
}

class _CreateServerPageState extends State<CreateServerPage> {
  late ScrollController _scrollController;
  CreateServerPageLogic logic = Get.put(CreateServerPageLogic());

  List<Step> _createSteps() {
    return [
      Step(
        title: Text('Select target device', style: Theme.of(context).textTheme.titleLarge),
        content: Container(child: Text('You can deploy sgs to this computer or a remote server'), alignment: Alignment.centerLeft),
        isActive: logic.currentStep == StepType.choose_target,
      ),
      Step(
        title: Text('Connect to target device', style: Theme.of(context).textTheme.titleLarge),
        isActive: logic.currentStep == StepType.connect_server,
        content: Container(child: Text('Connect to target device, ssh is need for remote server.'), alignment: Alignment.centerLeft),
      ),
      Step(
        title: Text('Check server api ports', style: Theme.of(context).textTheme.titleLarge),
        content: Container(child: Text('Custom ports for api server and web font!'), alignment: Alignment.centerLeft),
        isActive: logic.currentStep == StepType.set_params,
      ),
      Step(
        title: Text('Deploy SGS', style: Theme.of(context).textTheme.titleLarge),
        isActive: logic.currentStep!.index >= StepType.deploy_sgs.index,
        state: logic.stepState,
        content: Container(child: Text('Deploy sgs to target devices, this may take a while!'), alignment: Alignment.centerLeft),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    bool showLeading = !(DeviceOS.isMacOS || DeviceOS.isWeb);
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: showLeading,
      //   toolbarHeight: ui_config.HORIZONTAL_TOOL_BAR_HEIGHT,
      //   titleSpacing: 0,
      //   title: Container(
      //     height: ui_config.HORIZONTAL_TOOL_BAR_HEIGHT,
      //     child: AppTitleBar(
      //       child: Row(
      //         mainAxisSize: MainAxisSize.max,
      //         children: [
      //           SgsLogo(),
      //           Text('Deploy New Server'),
      //         ],
      //       ),
      //     ),
      //   ),
      //   actions: [
      //     if (!showLeading)
      //       TextButton.icon(
      //         onPressed: () {
      //           Navigator.of(context).maybePop();
      //         },
      //         icon: Icon(Icons.exit_to_app),
      //         label: Text('Exit'),
      //       ),
      //   ],
      // ),
      body: Stack(
        children: [
          GetBuilder<CreateServerPageLogic>(
            builder: _builder,
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: IconButton(
                icon: Icon(Icons.close, size: 28),
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                tooltip: 'Exit',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _builder(CreateServerPageLogic logic) {
    Widget right = Container();

    switch (logic.currentStep!) {
      case StepType.choose_target:
        right = _buildTarget();
        break;
      case StepType.connect_server:
        if (logic.target == SgsTarget.local) {
          right = _buildStateWidget();
        } else {
          right = _buildRemoteServerForm();
        }
        break;
      case StepType.set_params:
      // right = _animatedStepWidget(
      //     widget: ScriptParamsWidget(
      //   onSubmit: (mysql, apiPort, webPort) {
      //     logic.confirmParams(serverHost: logic.host, mysqlPort: mysql, apiPort: apiPort, webPort: webPort);
      //   },
      //   onBack: () {
      //     logic.chooseTarget();
      //   },
      // ));
      // break;
      // case StepType.check_permission:
      //   break;
      case StepType.deploy_sgs:
      case StepType.install_finish:
      case StepType.error:
        right = _buildStateWidget();
        break;
    }
    // return _buildStateWidget();
    if (isMobile(context)) {
      return Container(child: right, padding: EdgeInsets.symmetric(horizontal: 10));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepper(),
        // VerticalDivider(thickness: 2, width: 2),
        Expanded(
          child: Container(
            child: Column(
              children: [
                MoveAreaWrapper(),
                Expanded(child: right),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
      ],
    );
  }

  Widget _deployStateWidget() {
    switch (logic.currentStep) {
      case StepType.deploy_sgs:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildWaitingWidgets(),
        );
        break;
      case StepType.install_finish:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildFinishWidgets(),
        );
        break;
      case StepType.error:
        return _buildError();
        break;
      default:
        break;
    }
    return Container();
  }

  Widget _buildError() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Error: ${logic.error ?? ""}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }

  _buildStepper() {
    int curStep = logic.currentStep!.index <= StepType.deploy_sgs.index ? logic.currentStep!.index : StepType.deploy_sgs.index;
    Widget stepper = Stepper(
      steps: _createSteps(),
      controlsBuilder: (c, d) {
        return Row();
      },
      currentStep: curStep,
    );
    stepper = TweenAnimationBuilder<double>(
      tween: Tween(begin: .0, end: 1.0),
      curve: Curves.decelerate,
      duration: Duration(milliseconds: 1000),
      builder: (c, v, child) {
        return Container(
          alignment: Alignment(0.0, -(0.7 + v * .2)),
          child: Opacity(opacity: v, child: child),
        );
      },
      child: stepper,
    );
    Widget left = Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Color.lerp(Get.theme.primaryColor, Colors.black, .85) : Color.lerp(Get.theme.primaryColor, Colors.white, .85),
      ),
      alignment: Alignment.center,
      constraints: BoxConstraints(minWidth: 360, maxWidth: 500),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          MoveAreaWrapper(),
          SizedBox(height: 60),
          SgsLogo(fontSize: 40),
          SizedBox(height: 20),
          Text('Deploy SGS', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900)),
          SizedBox(height: 20),
          Expanded(child: stepper),
          // Center(child: stepper),
        ],
      ),
    );
    return left;
  }

  Widget _buildTarget() {
    Widget w = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Where do you want to install SGS Service ?',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, fontSize: 30),
        ),
        SizedBox(height: 30),
        ElevatedButton.icon(
          icon: Icon(Icons.computer, size: 22),
          label: Text('This Computer'),
          onPressed: logic.clickLocalDevice,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(100, 60),
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton.icon(
          icon: Icon(MaterialCommunityIcons.server, size: 18),
          label: Text('Remote Computer'),
          onPressed: logic.setRemoteTarget,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(100, 60),
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(height: 30),
        Expanded(
          child: Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Card(
              child: MdPreview(data: deployIntro, shrinkWrap: false),
            ),
          ),
        ),
        SizedBox(height: 30),
      ],
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.ease,
      duration: Duration(milliseconds: 1000),
      builder: (context, v, c) {
        return Container(
          margin: EdgeInsets.only(top: 20),
          alignment: Alignment(0, -.2 + (.2 * v)),
          child: Opacity(opacity: v, child: c),
        );
      },
      child: w,
    );
  }

  Widget _animatedStepWidget({required Widget widget, Duration duration = const Duration(milliseconds: 500), direction = 1.0}) {
    return TweenAnimationBuilder<double>(
      key: Key('${widget.hashCode}'),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.ease,
      duration: duration,
      builder: (context, v, c) {
        return Container(
          margin: EdgeInsets.only(top: 20),
          alignment: Alignment(0, .2 - (.2 * v)),
          child: Opacity(opacity: v, child: c),
        );
      },
      child: widget,
    );
  }

  Widget _buildRemoteServerForm() {
    Widget form = Card(
      // color: Theme.of(context).dialogBackgroundColor,
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 20, 30, 30),
        child: TitledWidget(
          mainAxisSize: MainAxisSize.min,
          title: Text('Connect to remote server', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: AlertWidget.info(
              message: FastRichText(
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, height: 1.5, fontWeight: FontWeight.w400, fontFamily: MONOSPACED_FONT),
                children: [
                  TextSpan(text: 'connect server by '),
                  TextSpan(text: 'ssh', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900)),
                  TextSpan(text: ', make sure your server '),
                  TextSpan(text: 'ssh', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900)),
                  TextSpan(text: ' is enabled.\n'),
                  TextSpan(text: 'Passwords are not stored!'),
                ],
              ),
            ),
          ),
          child: SshFormWidget(onSubmit: logic.connectServer),
          onBack: logic.chooseTarget,
        ),
      ),
    );
    // return form;
    return _animatedStepWidget(widget: form);
  }

  Widget _buildStateWidget() {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      // alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 30, bottom: 30, left: 20, right: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitledWidget(
              mainAxisSize: MainAxisSize.max,
              onBack: logic.onBack,
              title: Text(
                'Deploy SGS',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            _deployStateWidget(),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 30, 30, 30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.all(10),
                    // height: 200,
                    child: logic.terminal != null
                        ? TerminalView(
                            logic.terminal!,
                            scrollController: _scrollController,
                          )
                        : Container(),
                  ),
                  if (logic.currentStep == StepType.set_params)
                    Container(
                      color: Colors.black54.withOpacity(.5),
                      child: _animatedStepWidget(
                        widget: ScriptParamsWidget(
                          host: logic.host,
                          dataPath: logic.defaultDataPath,
                          onSubmit: (mysql, apiPort, webPort, path) {
                            logic.confirmParams(serverHost: logic.host, mysqlPort: mysql, apiPort: apiPort, webPort: webPort, path: path);
                          },
                          onBack: () {
                            logic.chooseTarget();
                          },
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWaitingWidgets() {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomSpin(color: Theme.of(context).colorScheme.primary),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Text(logic.title ?? "this may take a while ...", style: Theme.of(context).textTheme.bodyLarge),
      ),
    ];
  }

  List<Widget> _buildFinishWidgets() {
    final text = ' SGS path: ${logic.sgsPath}\n'
        'Data path: ${logic.sgsPath}/api\n'
        '  Api-url: ${logic.apiUrl}\n'
        '  Web-url: ${logic.webUrl}\n'
        'API-Token: ${logic.parseToken ?? 'token get error'}';
    return [
      Text('SGS Service Deployed success! Api server is already added to server list.', style: Theme.of(context).textTheme.titleMedium),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.8),
        ),
        child: SelectableText(
          text,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 18,
                height: 1.35,
                fontFamily: MONOSPACED_FONT,
                fontFamilyFallback: MONOSPACED_FONT_BACK,
              ),
        ),
      ),
      SizedBox(height: 10),
      Row(children: [
        // ElevatedButton(
        //   onPressed: () {
        //     Navigator.of(context).popAndPushNamed(RoutePath.login);
        //   },
        //   child: Text('Add data now'),
        // ),
        // SizedBox(width: 20),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Back to browser'),
        ),
      ]),
      SizedBox(height: 20),
    ];
  }

  void _showConfirmForm() async {
    var dialog = AlertDialog(
      title: Text('Re-Install SGS?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('SGS is already installed, do you really want to re-install now?'),
          AlertWidget.warning(message: Text('Tips: reinstall just clear your db data.')),
        ],
      ),
      actions: [
        TextButton(
          child: Text('NO'),
          onPressed: () {
            Navigator.of(context).pop('No');
          },
        ),
        ElevatedButton(
          child: Text('YES'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.of(context).pop('Yes');
          },
        ),
      ],
    );
    var result = await showDialog(
      context: context,
      builder: (c) => dialog,
      barrierDismissible: false,
    );
    logic.sendCommand(result ?? 'NO');
  }

  bool _rootAuthDialogShowing = false;

  void _showRootPasswordForm() async {
    if (_rootAuthDialogShowing) return;
    TextEditingController _controller = TextEditingController();
    var dialog = AlertDialog(
      title: FastRichText(
        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, fontFamily: MONOSPACED_FONT),
        children: [
          TextSpan(text: 'Require '),
          TextSpan(text: 'root ', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900)),
          TextSpan(text: 'password!'),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: PasswordField(
          controller: _controller,
          onSubmitted: (v) {
            if (_controller.text.length == 0) {
              return;
            }
            Navigator.of(context).pop(_controller.text);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_controller.text.length == 0) {
              return;
            }
            Navigator.of(context).pop(_controller.text);
          },
          child: Text('Authorize'),
        ),
      ],
    );
    _rootAuthDialogShowing = true;
    var result = await showDialog(context: context, builder: (c) => dialog, barrierDismissible: false);
    _rootAuthDialogShowing = false;
    if (result != null) {
      logic.sendCommand(result);
    }
  }

  @override
  void dispose() {
    Get.delete<CreateServerPageLogic>();
    super.dispose();
  }
}

class TitledWidget extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? child;
  final VoidCallback? onBack;
  final MainAxisSize mainAxisSize;

  const TitledWidget({
    Key? key,
    this.title,
    this.subtitle,
    this.child,
    this.onBack,
    this.mainAxisSize = MainAxisSize.min,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onBack != null)
              IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 22,
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_ios, size: 22),
                color: Theme.of(context).textTheme.displayMedium!.color,
                tooltip: 'BACK',
              ),
            if (title != null)
              Padding(
                padding: EdgeInsets.all(4),
                child: title,
              ),
          ],
        ),
        SizedBox(height: 10),
        if (subtitle != null)
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: subtitle,
          ),
        if (child != null) child!,
      ],
    );
  }
}
