import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';

class PaginationState {
  late int _currentPage;
  late int _totalPage;
  late int _pageSize;
  late int _totalCount;
  late int _selectedCount;
  late List<int> _pageSizeList;

  PaginationState({
    int currentPage = 1,
    int pageSize = 20,
    int totalCount = 0,
    int selectedCount = 0,
    List<int> pageSizeList = const [10, 20, 50, 100],
  }) {
    _pageSizeList = pageSizeList;
    _selectedCount = selectedCount;
    _currentPage = currentPage;
    _pageSize = pageSize;
    _totalCount = totalCount;
    _totalPage = (_totalCount / _pageSize).ceil();
  }

  List<int> get pageSizeList => _pageSizeList;

  int get selectedCount => _selectedCount;

  int get currentPage => _currentPage;

  void update({
    int? currentPage,
    int? pageSize,
    int? totalCount,
    List<int>? pageSizeList,
    int? selectedCount,
  }) {
    _currentPage = currentPage ?? _currentPage;
    if (pageSize != null) {
      _pageSize = pageSize;
      _currentPage = 1;
      _totalPage = (_totalCount / _pageSize).ceil();
    }

    if (totalCount != null && totalCount != _totalCount) {
      _totalCount = totalCount;
      _totalPage = (_totalCount / _pageSize).ceil();
      _currentPage = 1;
    }
    if (selectedCount != null) _selectedCount = selectedCount;
  }

  int get totalPage => _totalPage;

  int get pageSize => _pageSize;

  void set pageSize(int pageSize) {
    _pageSize = pageSize;
    _currentPage = 1;
    _totalPage = (_totalCount / _pageSize).ceil();
  }

  int get totalCount => _totalCount;

  bool get isFirstPage => _currentPage == 1;

  bool get isLastPage => _currentPage == _totalPage;

  int get pageStart => (_currentPage - 1) * _pageSize;

  int get pageEnd => ((_currentPage) * _pageSize).clamp(0, totalCount);

  void toPage(int page) {
    _currentPage = page;
  }

  firstPage() {
    _currentPage = 1;
  }

  previousPage() {
    int n = _currentPage - 1;
    if (n < 1) n = 1;
    _currentPage = n;
  }

  nextPage() {
    int n = _currentPage + 1;
    if (n > _totalPage) n = _totalPage;
    _currentPage = n;
  }

  lastPage() {
    _currentPage = _totalPage;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationState &&
          runtimeType == other.runtimeType &&
          _currentPage == other._currentPage &&
          _totalPage == other._totalPage &&
          _pageSize == other._pageSize &&
          _totalCount == other._totalCount &&
          _selectedCount == other._selectedCount;

  @override
  int get hashCode => _currentPage.hashCode ^ _totalPage.hashCode ^ _pageSize.hashCode ^ _totalCount.hashCode ^ _selectedCount.hashCode;

  List<int> pageList(int count) {
    int startPage = 1;
    int end = totalPage;

    List<int> pages = [];
    int c = currentPage;

    int _s = currentPage - count;
    int _e = currentPage + count;

    if (_s < 1) _s = 1;
    if (_e > totalPage) _e = totalPage;

    pages = List.generate(_e - _s + 1, (index) => _s + index);
    if (_s > 1) pages.insert(0, 1);
    if (_e < totalPage) pages.add(totalPage);
    return pages;
  }
}

class PaginationWidget extends StatefulWidget {
  final PaginationState paginationState;

  final ValueChanged<int>? onPageChange;

  const PaginationWidget({
    Key? key,
    required this.paginationState,
    this.onPageChange,
  }) : super(key: key);

  @override
  State<PaginationWidget> createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<PaginationWidget> {
  PaginationState get _paginationState => widget.paginationState;

  @override
  void didUpdateWidget(covariant PaginationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
  }

  _firstPage() {
    _paginationState.firstPage();
    setState(() {});
    widget.onPageChange?.call(_paginationState.currentPage);
  }

  _previousPage() {
    _paginationState.previousPage();
    setState(() {});
    widget.onPageChange?.call(_paginationState.currentPage);
  }

  _nextPage() {
    _paginationState.nextPage();
    setState(() {});
    widget.onPageChange?.call(_paginationState.currentPage);
  }

  _lastPage() {
    _paginationState.lastPage();
    setState(() {});
    widget.onPageChange?.call(_paginationState.currentPage);
  }

  _toPage(int page) {
    _paginationState.toPage(page);
    setState(() {});
    widget.onPageChange?.call(_paginationState.currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Row(
        children: [
          Text('Total: ${_paginationState.totalCount}'),
          if (_paginationState._selectedCount > 0) Text(', ${_paginationState._selectedCount} selected'),
          Spacer(),
          Wrap(
            spacing: 8,
            runAlignment: WrapAlignment.spaceEvenly,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _btn(
                icon: Icon(Icons.first_page),
                tooltip: 'first',
                onPressed: _paginationState.isFirstPage ? null : _firstPage,
              ),
              // _btn(
              //   icon: Icon(Icons.chevron_left),
              //   onPressed: _paginationState.isFirstPage ? null : _previousPage,
              //   tooltip: 'previous',
              // ),
              ..._paginationState.pageList(constraints.maxWidth < 400 ? 1 : 3).map((i) {
                return i == _paginationState.currentPage
                    ? _btn(
                        icon: Text('${i}', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _toPage(i),
                      )
                    : TextButton(
                        onPressed: () => _toPage(i),
                        child: Text('${i}'),
                        style: TextButton.styleFrom(
                          minimumSize: Size(36, 34),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        ),
                      );
              }),
              // _btn(
              //   icon: Icon(Icons.chevron_right),
              //   onPressed: _paginationState.isLastPage ? null : _nextPage,
              //   tooltip: 'next',
              // ),
              _btn(
                icon: Icon(Icons.last_page),
                onPressed: _paginationState.isLastPage ? null : _lastPage,
                tooltip: 'last',
              ),
              PopupMenuButton<int>(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  child: Text('${_paginationState.pageSize}/page'),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (c) {
                  return _paginationState.pageSizeList
                      .map(
                        (e) => PopupMenuItem<int>(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text('${e}', style: TextStyle(color: e == _paginationState.pageSize ? Theme.of(context).colorScheme.primary : null)),
                          ),
                          value: e,
                        ),
                      )
                      .toList();
                },
                onSelected: (int pageSize) {
                  _paginationState.update(pageSize: pageSize);
                  setState(() {});
                  widget.onPageChange?.call(_paginationState.currentPage);
                },
              ),
              // DropdownButtonHideUnderline(
              //   child: DropdownButton<int>(
              //     items: _paginationState.pageSizeList.map((e) => DropdownMenuItem<int>(value: e, child: Text('${e}'))).toList(),
              //     onChanged: (v) {
              //       if (v != null) {
              //         _paginationState.pageSize = v;
              //         setState(() {});
              //       }
              //     },
              //     value: _paginationState.pageSize,
              //   ),
              // )
            ],
          )
        ],
      ),
    );
  }

  Widget _btn({required Widget icon, VoidCallback? onPressed, String? tooltip, Color? color}) {
    return OutlinedButton(
      onPressed: onPressed,
      child: icon,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(36, 34),
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        side: BorderSide(color: color ?? Theme.of(context).dividerColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      padding: EdgeInsets.zero,
      iconSize: 20,
      splashRadius: 20,
      constraints: BoxConstraints.tightFor(width: 32, height: 32),
      tooltip: tooltip,
    );
  }
}
