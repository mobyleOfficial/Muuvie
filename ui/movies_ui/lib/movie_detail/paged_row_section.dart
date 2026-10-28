import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies_ui/movie_detail/movie_section.dart';

/// One page of a [PagedRowSection]: the items and whether there are more.
typedef RowPage<T> = ({List<T> items, bool hasNext});

/// A titled row that scrolls sideways and asks for the next page near its
/// end. Hidden while the first page loads, when it fails or comes empty.
class PagedRowSection<T> extends StatefulWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double height;
  final Future<Result<RowPage<T>>> Function(int page) loadPage;
  final Widget Function(BuildContext context, T item) itemBuilder;

  const PagedRowSection({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    required this.height,
    required this.loadPage,
    required this.itemBuilder,
  });

  @override
  State<PagedRowSection<T>> createState() => _PagedRowSectionState<T>();
}

class _PagedRowSectionState<T> extends State<PagedRowSection<T>> {
  final List<T> _items = [];
  int _page = 0;
  bool _hasNext = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasNext) return;
    setState(() => _loading = true);
    final result = await widget.loadPage(_page + 1);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          _items.addAll(data.items);
          _page++;
          _hasNext = data.hasNext;
        // A later page that fails stops the row where it is.
        case Failure():
          _hasNext = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();
    final showLoader = _loading && _items.isNotEmpty;

    return MovieSection(
      title: widget.title,
      actionLabel: widget.actionLabel,
      onAction: widget.onAction,
      padContent: false,
      child: SizedBox(
        height: widget.height,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.axis == Axis.horizontal &&
                notification.metrics.extentAfter < 300) {
              _loadMore();
            }
            return false;
          },
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _items.length + (showLoader ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => index == _items.length
                ? const Center(child: MuuvieActivityIndicator())
                : widget.itemBuilder(context, _items[index]),
          ),
        ),
      ),
    );
  }
}
