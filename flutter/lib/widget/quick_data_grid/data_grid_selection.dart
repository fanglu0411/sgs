import 'package:dartx/dartx.dart';

class DataGridSelection {
  late Map<int, bool> _selection;

  late Map<int, Map<int, bool>> _paginatedSelection;

  late Map<int, bool> _pageSelectAll;

  bool isPaginated = false;

  late int _currentPage = 1;

  bool get isSelectAll => _pageSelectAll[_currentPage] ?? false;

  int get totalSelectedCount => isPaginated ? _paginatedSelectedCount : _selection.filter((e) => e.value).length;

  int get _paginatedSelectedCount => _paginatedSelection.values.map((e) => e.filter((e) => e.value).length).sum();

  void setCurrentPage(int page, int count) {
    _currentPage = page;
    if (_paginatedSelection[page] == null) {
      _paginatedSelection[page] = Map.fromIterables(List.generate(count, (index) => index + 1), List.generate(count, (index) => false));
    }
  }

  int get currentPage => _currentPage;

  DataGridSelection({required this.isPaginated}) {
    _currentPage = 1;
    _selection = {};
    _paginatedSelection = {};
    _pageSelectAll = {};
  }

  List<int> pageSelection(int page) {
    return (_paginatedSelection[page] ?? {}).filter((e) => e.value).keys.toList();
  }

  void onSelectionChange(int row, bool checked) {
    if (_paginatedSelection[_currentPage] == null) {
      _paginatedSelection[_currentPage] = {};
    }
    _paginatedSelection[_currentPage]![row] = checked;
    if (!checked) {
      _pageSelectAll[_currentPage] = false;
    } else {
      _pageSelectAll[_currentPage] = !_paginatedSelection[_currentPage]!.values.any((v) => !v);
    }
  }

  void clear() {
    _selection.clear();
    _paginatedSelection.clear();
    _currentPage = 1;
  }

  void toggleAll(bool? v) {
    if (v == null) return;
    for (var k in (_paginatedSelection[_currentPage] ?? {}).keys) {
      _paginatedSelection[_currentPage]![k] = v;
    }
    _pageSelectAll[_currentPage] = v;
  }

  bool isSelectRow(int row) {
    return _paginatedSelection[_currentPage]?[row] ?? false;
  }
}
