import 'package:flutter/material.dart';

///带加载更多listview
class LoadMoreListView extends StatefulWidget {
  LoadMoreListView({
    this.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    @required this.itemBuilder,
    this.separatorBuilder,
    @required this.itemCount,
    this.loadMoreBuilder,
    this.noMoreBuilder,
    this.hasMore = false,
    this.onLoadMore,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
  });

  final Key key;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController controller;
  final bool primary;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  final WidgetBuilder loadMoreBuilder;
  final WidgetBuilder noMoreBuilder;
  final int itemCount;
  final bool hasMore;
  final Future Function() onLoadMore;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double cacheExtent;

  @override
  _LoadMoreListViewState createState() => _LoadMoreListViewState();
}

class _LoadMoreListViewState extends State<LoadMoreListView> {
  bool isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (isLoadingMore || !widget.hasMore) return false;
          isLoadingMore = true;
          _handleLoadMore(context, notification, widget.onLoadMore).then((data) {
            isLoadingMore = false;
          }).catchError((e) {
            isLoadingMore = false;
          });
          return false;
        },
        child: ListView.separated(
          key: widget.key,
          scrollDirection: widget.scrollDirection,
          reverse: widget.reverse,
          controller: widget.controller,
          primary: widget.primary,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          padding: widget.padding,
          itemCount: widget.itemCount + 1,
          addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
          addRepaintBoundaries: widget.addRepaintBoundaries,
          addSemanticIndexes: widget.addSemanticIndexes,
          cacheExtent: widget.cacheExtent,
          itemBuilder: (context, index) {
            //如果到了表尾
            if (index == widget.itemCount) {
              //继续获取数据
              if (widget.hasMore) {
                //获取数据
//                Future.delayed(Duration(milliseconds: 0), () {
//                  if (onLoadMore != null) onLoadMore();
//                });
                //加载时显示loading
                return widget.loadMoreBuilder != null
                    ? widget.loadMoreBuilder(context)
                    : Container(
                        padding: const EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                      );
              } else {
                //已经加载了100条数据，不再获取数据。
                return widget.noMoreBuilder != null
                    ? widget.noMoreBuilder(context)
                    : Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "没有更多了",
                          style: TextStyle(color: Colors.grey),
                        ));
              }
            }
            //显示单词列表项
            return widget.itemBuilder(context, index);
          },
          separatorBuilder: widget.separatorBuilder != null
              ? widget.separatorBuilder
              : (context, index) => Divider(
                    height: 0,
                    color: Colors.transparent,
                  ),
        ));
  }
}

class LoadMoreSliverList extends StatefulWidget {
  LoadMoreSliverList({
    this.key,
    @required this.itemBuilder,
    this.separatorBuilder,
    @required this.itemCount,
    this.loadMoreBuilder,
    this.noMoreBuilder,
    this.hasMore = false,
    this.onLoadMore,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  });

  final Key key;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  final WidgetBuilder loadMoreBuilder;
  final WidgetBuilder noMoreBuilder;
  final int itemCount;
  final bool hasMore;
  final Future Function() onLoadMore;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;

  @override
  _LoadMoreSliverListState createState() => _LoadMoreSliverListState();
}

class _LoadMoreSliverListState extends State<LoadMoreSliverList> {
  bool isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        if (widget.separatorBuilder != null) {
          //有分隔线
          if (index % 2 == 0) {
            if (index == widget.itemCount * 2 - 1)
              return _buildEndView(context); //加载更多View
            else
              return widget.separatorBuilder(context, index); //分隔线
          } else {
            return widget.itemBuilder(context, index ~/ 2);
          }
        }
        if (index == widget.itemCount) //没有分隔线
          return _buildEndView(context);
        else
          return widget.itemBuilder(context, index);
      },
      childCount: widget.separatorBuilder == null ? widget.itemCount + 1 : widget.itemCount * 2,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
    ));
  }

  Widget _buildEndView(BuildContext context) {
    //继续获取数据
    if (widget.hasMore) {
      if (!isLoadingMore && widget.onLoadMore != null) {
        isLoadingMore = true;
        widget.onLoadMore().then((data) {
          isLoadingMore = false;
        }).catchError((e) {
          isLoadingMore = false;
        });
      }

      //加载时显示loading
      return widget.loadMoreBuilder != null
          ? widget.loadMoreBuilder(context)
          : Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            );
    } else {
      return widget.noMoreBuilder != null
          ? widget.noMoreBuilder(context)
          : Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16.0),
              child: Text(
                "没有更多了",
                style: TextStyle(color: Colors.grey),
              ));
    }
  }
}

Future _handleLoadMore(BuildContext context, ScrollNotification notification, void Function() onLoadMore) async {
  //ScrollUpdateNotification 还有其他可使用，需要自行优化
//  if (notification is ScrollEndNotification) {
  //下滑到最底部
  if (notification.metrics.extentAfter == 0.0) {
//    debugPrint('下滑到最底部');
    if (onLoadMore != null) return onLoadMore();
  }
//  }
  return null;
}
