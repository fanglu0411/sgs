import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/basic/fast_rich_text.dart';

class PaginationWidget extends StatefulWidget {
  final int totalCount;
  final int page;
  final int pageSize;
  final ValueChanged<int>? onPageChange;

  const PaginationWidget({
    Key? key,
    required this.totalCount,
    this.page = 1,
    required this.pageSize,
    this.onPageChange,
  }) : super(key: key);

  @override
  State<PaginationWidget> createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<PaginationWidget> {
  late int _currentPage;
  late int _totalPage;
  late int _pageSize;
  late int _totalCount;

  @override
  void didUpdateWidget(covariant PaginationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageSize != _pageSize || widget.totalCount != _totalCount) {
      _init();
    }
  }

  _init() {
    _totalCount = widget.totalCount;
    _pageSize = widget.pageSize;
    _totalPage = (_totalCount / _pageSize).ceil();
    _currentPage = widget.page;
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _firstPage() {
    _toPage(1);
  }

  _previousPage() {
    int n = _currentPage - 1;
    if (n < 1) n = 1;
    _toPage(n);
  }

  _nextPage() {
    int n = _currentPage + 1;
    if (n > _totalPage) n = _totalPage;
    _toPage(n);
  }

  _lastPage() {
    _toPage(_totalPage);
  }

  _toPage(int page) {
    _currentPage = page;
    setState(() {});
    widget.onPageChange?.call(page);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Row(
        children: [
          FastRichText(
            textStyle: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: '${_currentPage}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              TextSpan(text: '/${_totalPage} of ${widget.totalCount}'),
            ],
          ),
          Spacer(),
          _btn(
            icon: Icon(Icons.first_page),
            tooltip: 'first',
            onPressed: _currentPage == 1 ? null : _firstPage,
          ),
          _btn(
            icon: Icon(Icons.chevron_left),
            onPressed: _currentPage == 1 ? null : _previousPage,
            tooltip: 'previous',
          ),
          _btn(
            icon: Icon(Icons.chevron_right),
            onPressed: _currentPage == _totalPage ? null : _nextPage,
            tooltip: 'next',
          ),
          _btn(
            icon: Icon(Icons.last_page),
            onPressed: _currentPage == _totalPage ? null : _lastPage,
            tooltip: 'last',
          ),
        ],
      ),
    );
  }

  Widget _btn({required Icon icon, VoidCallback? onPressed, String? tooltip}) {
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
