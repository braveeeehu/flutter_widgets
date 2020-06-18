import 'dart:async';

import 'package:flutter/material.dart';

class CustomBanner extends StatefulWidget {
  final List<String> _images;
  final double height;
  final ValueChanged<int> onTap;
  final Curve curve;

  CustomBanner(
    this._images, {
    this.height = 200,
    this.onTap,
    this.curve = Curves.linear,
  }) : assert(_images != null);

  @override
  _CustomBannerState createState() => _CustomBannerState();
}

class _CustomBannerState extends State<CustomBanner> {
  PageController _pageController;
  int _curIndex;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _curIndex = widget._images.length * 5;
    _pageController = PageController(initialPage: _curIndex);
    _initTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _buildPageView(),
        _buildIndicator(),
      ],
    );
  }

  Widget _buildIndicator() {
    var length = widget._images.length;
    return Positioned(
      bottom: 10,
      child: Row(
        children: widget._images.map((s) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: ClipOval(
              child: Container(
                width: 8,
                height: 8,
                color: s == widget._images[_curIndex % length] ? Colors.white : Colors.grey,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPageView() {
    var length = widget._images.length;
    return Container(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          if (_curIndex == index) return;
          setState(() {
            _curIndex = index;
            if (index == 0) {
              _curIndex = length;
              _changePage();
            }
          });
        },
        itemBuilder: (context, index) {
          return GestureDetector(
            onPanDown: (details) {
              _cancelTimer();
            },
            onTap: () => widget.onTap(index % length),
            child: Image.network(
              widget._images[index % length],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  _cancelTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
      _initTimer();
    }
  }

  /// 初始化定时任务
  _initTimer() {
    if (_timer == null && (widget._images?.length ?? 0) > 1) {
      _timer = Timer.periodic(Duration(seconds: 3), (t) {
        if (!mounted) return;
        _curIndex++;
        _pageController.animateToPage(
          _curIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.linear,
        );
      });
    }
  }

  _changePage() {
    Timer(Duration(milliseconds: 300), () {
      if (!mounted) return;
      _pageController.jumpToPage(_curIndex);
    });
  }
}
