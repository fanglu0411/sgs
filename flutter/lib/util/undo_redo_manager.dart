import 'package:flutter_smart_genome/page/track/track_control_bar/track_control_bar.dart';

mixin Command {
  void execute(bool undo);
}

class TrackCommand<T> with Command {
  TrackControlAction? action;
  T state;
  T? preState;

  Function? callback;

  TrackCommand({this.preState, required this.state, this.callback});

  @override
  void execute(bool undo) {
    callback?.call(this, undo);
  }

  @override
  String toString() {
    return 'TrackCommand{action: $action, preState: $preState, state: $state}';
  }
}

class UndoRedoManager {
  static final UndoRedoManager _instance = UndoRedoManager._init();

  static UndoRedoManager get() => _instance;

  factory UndoRedoManager() {
    return _instance;
  }

  late List<Command> _commands;

  late List<Command> _redoList;

  bool get canUndo => _commands.length > 1;

  bool get canRedo => _redoList.length > 0;

  UndoRedoManager._init() {
    _commands = [];
    _redoList = [];
  }

  void add(Command command) {
    _commands.insert(0, command);
  }

  void undo() {
    if (!canUndo) return;
    Command command = _commands.removeAt(0);
    _redoList.add(command);
    _commands[0].execute(true);
  }

  void redo() {
    if (!canRedo) return;
    Command command = _redoList.removeAt(0);
    command.execute(false);
  }

  void reset() {
    _commands.clear();
    _redoList.clear();
  }
}