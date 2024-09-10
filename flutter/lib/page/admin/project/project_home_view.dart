import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/components/md/md_editor.dart';
import 'package:flutter_smart_genome/components/md/md_preview.dart';
import 'package:flutter_smart_genome/page/admin/project/project_demo_md.dart';
import 'package:flutter_smart_genome/service/cache_service.dart';
import 'package:flutter_smart_genome/service/sgs_service_delegate.dart';
import 'package:flutter_smart_genome/widget/basic/custom_bot_widget.dart';
import 'package:flutter_smart_genome/widget/basic/custom_spin.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

class BlockViewLogic extends GetxController with StateMixin<String> {
  // List<PageBlock> blocks = [];
  String? content = '';

  bool _editMode = false;

  bool _edited = false;

  bool get edited => _edited;

  String? _pid;
  String? projectName;
  String serverUrl;

  void set pid(String? pid) => _pid = pid;

  Debouncer? debounce;

  void toggleEditMode() {
    _editMode = !_editMode;
    if (_editMode && (content == null || content!.length == 0)) {
      content = PROJECT_PAGE_DEMO;
    }
    update();
    // change(blocks);
  }

  BlockViewLogic(this._pid, this.projectName, this.serverUrl) {
    print('${_pid}');
    print('${serverUrl}');
  }

  @override
  void onInit() {
    super.onInit();
    debounce = Debouncer(delay: Duration(milliseconds: 5000));
  }

  @override
  void onReady() {
    super.onReady();
    loadBlocks();
  }

  loadBlocks() async {
    change('', status: RxStatus.loading());
    content = await _fetchProjectInfo();
    if (content != null && content!.length > 0) {
      change(content, status: RxStatus.success());
    } else {
      change(content, status: RxStatus.empty());
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  void submitContent(String value) {
    _saveCache(value);
    _updateProjectInfo();
  }

  void onContentChange(String value) {
    _edited = true;
    content = value;
    debounce?.call(() => _saveCache(value));
  }

  void _saveCache(String content) {
    // print('_save: ${_pid}');
    CacheService.get()?.saveProjectInfo(_pid!, content);
  }

  Future<String?> _fetchProjectInfo() async {
    String? content;
    var resp = await SgsServiceDelegate().getSpeciesIntro(host: serverUrl, id: _pid);
    if (resp.success) {
      content = resp.body['species_info'];
    } else {
      content = CacheService.get()?.getCacheProjectInfo(_pid!);
    }
    if ((content == null || content!.length == 0) && _editMode) {
      content = PROJECT_PAGE_DEMO;
    }
    return content;
  }

  CancelFunc? _loadingFunc;

  Future _updateProjectInfo() async {
    if (content == null || content!.length == 0) return;
    _loadingFunc?.call();
    _loadingFunc = BotToast.showLoading(clickClose: false);
    var resp = await SgsServiceDelegate().updateSpeciesIntro(host: serverUrl, id: _pid, speciesName: projectName, content: content!);
    _loadingFunc?.call();
    if (resp.success) {
      _edited = false;
      _editMode = false;
      showToast(text: 'Update project info success!');
      change(content, status: RxStatus.success());
    } else {
      showToast(text: 'Update error!\n${resp.error ?? resp.body}');
    }
  }
}

class ProjectHomeView extends StatelessWidget {
  final Species project;
  final SiteItem site;
  final bool previewOnly;

  // BlockViewLogic logic = Get.put(BlockViewLogic());

  ProjectHomeView({
    super.key,
    required this.project,
    required this.site,
    this.previewOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BlockViewLogic>(
      init: BlockViewLogic(project.id, project.name, site.url),
      autoRemove: true,
      builder: (c) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
            if (!c.edited) {
              Navigator.of(context).pop();
            } else {
              _popConfirm(context);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('${project.name}'),
              actions: [
                if (!c._editMode && !previewOnly)
                  IconButton(
                    onPressed: c.toggleEditMode,
                    icon: Icon(Icons.edit_note),
                    tooltip: 'Edit',
                  ),
                SizedBox(width: 10),
              ],
            ),
            body: c._editMode
                ? MarkdownEditor(
                    onSave: c.submitContent,
                    onChange: c.onContentChange,
                    content: c.content,
                  )
                : c.obx(
                    (state) => Padding(
                      padding: const EdgeInsets.all(20.0),
                      // child: SelectionArea(child: BlocksView(blocks: state!)),
                      child: MdPreview(data: state ?? ''),
                    ),
                    onLoading: Center(child: CustomSpin(color: Theme.of(context).colorScheme.primary)),
                    onError: (String? error) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text(error ?? 'Load info error'),
                      );
                    },
                    onEmpty: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Entypo.emoji_sad, size: 48),
                          SizedBox(height: 12),
                          Text('Project info is empty!', textScaler: TextScaler.linear(1.35)),
                          SizedBox(height: 12),
                          if (!previewOnly) FilledButton(onPressed: c.toggleEditMode, child: Text('Edit'), style: FilledButton.styleFrom(minimumSize: Size(120, 40))),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _popConfirm(BuildContext context) async {
    var result = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Warning!'),
        content: Text('Edit not saved to server! Exit without save?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(c).pop('cancel');
            },
            child: Text('NO'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(c).pop('exit');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text('EXIT'),
          ),
        ],
      ),
    );
    if (result == 'exit') {
      Navigator.of(context).pop();
    }
  }
}
