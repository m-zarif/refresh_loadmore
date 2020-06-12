library refresh_loadmore;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RefreshLoadmore extends StatefulWidget {
  /// callback function on pull down to refresh | 下拉刷新时的回调函数
  final Future<void> Function() onRefresh;

  /// callback function on pull up to load more data | 上拉以加载更多数据的回调函数
  final Future<void> Function() onLoadmore;

  /// Whether it is the last page, if it is true, you can not load more | 是否为最后一页，如果为true，则无法加载更多
  final bool isLastPage;

  /// children widget | 子组件列表
  final List<Widget> children;

  /// Prompt text when there is no more data at the bottom | 底部没有更多数据时的提示文字
  final String noMoreText;

  /// [noMoreText] text style | [noMoreText]的文字样式
  final TextStyle noMoreTextStyle;

  const RefreshLoadmore({
    Key key,
    @required this.children,
    @required this.isLastPage,
    this.noMoreText,
    this.noMoreTextStyle,
    this.onRefresh,
    this.onLoadmore,
  }) : super(key: key);
  @override
  _RefreshLoadmoreState createState() => _RefreshLoadmoreState();
}

class _RefreshLoadmoreState extends State<RefreshLoadmore> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  ScrollController _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        if (_isLoading) {
          return;
        }

        setState(() {
          _isLoading = true;
        });

        if (widget.onLoadmore != null) {
          await widget.onLoadmore();
        }

        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onRefresh == null) {
      return Scrollbar(
        child: ListView(
          controller: _scrollController,
          children: widget.children,
        ),
      );
    }
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        if (_isLoading) return;
        await widget.onRefresh();
      },
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(),

        /// Solve the problem that there are too few items to pull down and refresh | 解决item太少，无法下拉刷新的问题
        controller: _scrollController,
        children: <Widget>[
          Column(children: widget.children),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16),
                child: _isLoading
                    ? CupertinoActivityIndicator()
                    : Text(
                        widget.isLastPage
                            ? widget.noMoreText ?? 'No more data'
                            : '',
                        style: widget.noMoreTextStyle ??
                            TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).disabledColor,
                            ),
                      ),
              )
            ],
          )
        ],
      ),
    );
  }
}
