// ignore_for_file: avoid_multiple_declarations_per_line
import 'dart:async';
import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../util/const.dart';
import 'title_bar.dart';

class Window extends StatefulWidget {
  const Window({
    required Key key,
    required this.title,
    required this.app,
    required this.whenFocusRequested,
    required this.onCloseTap,
    required this.onMinimizeTap,
    required this.unHideWindowStream,
    required this.width,
    required this.height,
    required this.isFixedSize,
    required double screenWidth,
    required double screenHeight,
  })  : availableWidth = screenWidth + windowOuterPaddingTimes2,
        availableHeight = screenHeight - dockHeight + windowOuterPaddingTimes2,
        super(key: key);

  final String title;
  final Widget app;
  final VoidCallback whenFocusRequested;
  final VoidCallback onCloseTap;
  final VoidCallback onMinimizeTap;
  final Stream<Key> unHideWindowStream;

  final double? width;
  final double? height;
  final bool isFixedSize;
  final double availableWidth;
  final double availableHeight;

  @override
  State<Window> createState() => _WindowState();
}

class _WindowState extends State<Window> {
  final _random = Random();
  double _dx = 0, _dxLast = 0;
  double _dy = 0, _dyLast = 0;
  double _width = 0, _widthLast = 0;
  double _height = 0, _heightLast = 0;

  bool _isMinimized = false, _isMaximized = false;

  late final StreamSubscription<void> _unHideWindowSubscription;

  @override
  void initState() {
    super.initState();

    _unHideWindowSubscription = widget.unHideWindowStream
        .where((event) => widget.key == event)
        .listen((_) => _toggleMinimize());

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _width = widget.width ?? widget.availableWidth * 0.6;
        _height = widget.height ?? widget.availableHeight * 0.6;
        _checkMinSize();

        _dx = _random.nextDouble() * (widget.availableWidth - _width);
        _dy = _random.nextDouble() * (widget.availableHeight - _height);
      });
    });
  }

  @override
  void dispose() {
    _unHideWindowSubscription.cancel();
    super.dispose();
  }

  void _onDragTop(double dy) {
    _dy += dy;
    _height -= dy;
    _checkMinSize();
  }

  void _onDragRight(double dx) {
    _width += dx;
    _checkMinSize();
  }

  void _onDragBottom(double dy) {
    _height += dy;
    _checkMinSize();
  }

  void _onDragLeft(double dx) {
    _dx += dx;
    _width -= dx;
    _checkMinSize();
  }

  void _checkMinSize() {
    if (_width < windowMinWidth) {
      _width = windowMinWidth;
    }

    if (_height < windowMinHeight) {
      _height = windowMinHeight;
    }
  }

  void _toggleMinimize() {
    setState(() => _isMinimized = !_isMinimized);
    if (_isMinimized) {
      widget.onMinimizeTap();
    }
  }

  void _toggleMaximize() {
    setState(() {
      if (_isMaximized) {
        _isMaximized = false;
        _width = _widthLast;
        _height = _heightLast;
        _dx = _dxLast;
        _dy = _dyLast;
      } else {
        _isMaximized = true;
        _widthLast = _width;
        _heightLast = _height;
        _dxLast = _dx;
        _dyLast = _dy;

        _width = widget.availableWidth;
        _height = widget.availableHeight;
        _dx = _dy = -windowOuterPadding;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_width == 0 && _height == 0) {
      return const SizedBox();
    }

    return AnimatedPositioned(
      left: _dx,
      top: _dy,
      duration: windowTransitionMillis,
      child: Visibility(
        maintainState: true,
        visible: !_isMinimized,
        child: Listener(
          onPointerDown: (_) => widget.whenFocusRequested(),
          child: Stack(
            children: [
              AnimatedContainer(
                width: _width,
                height: _height,
                duration: windowTransitionMillis,
                padding: const EdgeInsets.all(windowOuterPadding),
                child: _WindowDecoration(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TitleBar(
                        widget.title,
                        isFixedSizeWindow: widget.isFixedSize,
                        isMaximizedWindow: _isMaximized,
                        onTitleBarDrag: (dx, dy) => setState(() {
                          _dx += dx;
                          _dy += dy;
                        }),
                        onCloseTap: widget.onCloseTap,
                        onMinimizeTap: _toggleMinimize,
                        onToggleMaximizeTap: _toggleMaximize,
                      ),
                      const ColoredBox(
                        color: windowBodySeparatorColor,
                        child: SizedBox(height: 1),
                      ),
                      Expanded(
                        child: ColoredBox(
                          color: windowBodyColor,
                          child: widget.app,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!widget.isFixedSize) ...[
                // left
                _BorderDragArea(
                  onHorizontalDragUpdate: (details) => setState(
                    () => _onDragLeft(details.delta.dx),
                  ),
                  right: null,
                ),
                // right
                _BorderDragArea(
                  onHorizontalDragUpdate: (details) => setState(
                    () => _onDragRight(details.delta.dx),
                  ),
                  left: null,
                ),
                // top
                _BorderDragArea(
                  onVerticalDragUpdate: (details) => setState(
                    () => _onDragTop(details.delta.dy),
                  ),
                  bottom: null,
                ),
                // bottom
                _BorderDragArea(
                  onVerticalDragUpdate: (details) => setState(
                    () => _onDragBottom(details.delta.dy),
                  ),
                  top: null,
                ),
                // top-left
                _CornerDragArea(
                  onPanUpdate: (details) => setState(() {
                    _onDragTop(details.delta.dy);
                    _onDragLeft(details.delta.dx);
                  }),
                  right: null,
                  bottom: null,
                ),
                // top-right
                _CornerDragArea(
                  onPanUpdate: (details) => setState(() {
                    _onDragTop(details.delta.dy);
                    _onDragRight(details.delta.dx);
                  }),
                  bottom: null,
                  left: null,
                ),
                // bottom-right
                _CornerDragArea(
                  onPanUpdate: (details) => setState(() {
                    _onDragBottom(details.delta.dy);
                    _onDragRight(details.delta.dx);
                  }),
                  top: null,
                  left: null,
                ),
                // bottom-left
                _CornerDragArea(
                  onPanUpdate: (details) => setState(() {
                    _onDragBottom(details.delta.dy);
                    _onDragLeft(details.delta.dx);
                  }),
                  top: null,
                  right: null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WindowDecoration extends StatelessWidget {
  const _WindowDecoration({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: windowDecoration,
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: windowBorderRadius,
            child: child,
          ),
        ),
      );
}

abstract class _DragArea extends StatelessWidget {
  const _DragArea(
    this.left,
    this.top,
    this.right,
    this.bottom,
    Key? key,
  ) : super(key: key);

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
}

class _BorderDragArea extends _DragArea {
  const _BorderDragArea({
    this.onHorizontalDragUpdate,
    this.onVerticalDragUpdate,
    double? left = 0,
    double? top = 0,
    double? right = 0,
    double? bottom = 0,
    Key? key,
  }) : super(left, top, right, bottom, key);

  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragUpdateCallback? onVerticalDragUpdate;

  @override
  Widget build(BuildContext context) {
    final isHorizontal = right == null || left == null;
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: GestureDetector(
        onHorizontalDragUpdate: onHorizontalDragUpdate,
        onVerticalDragUpdate: onVerticalDragUpdate,
        child: MouseRegion(
          cursor: isHorizontal
              ? SystemMouseCursors.resizeLeftRight
              : SystemMouseCursors.resizeUpDown,
          child: SizedBox(
            width: isHorizontal ? 8 : null,
            height: isHorizontal ? null : 8,
          ),
        ),
      ),
    );
  }
}

class _CornerDragArea extends _DragArea {
  const _CornerDragArea({
    required this.onPanUpdate,
    double? left = 0,
    double? top = 0,
    double? right = 0,
    double? bottom = 0,
    Key? key,
  }) : super(left, top, right, bottom, key);

  final GestureDragUpdateCallback onPanUpdate;

  @override
  Widget build(BuildContext context) => Positioned(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        child: GestureDetector(
          onPanUpdate: onPanUpdate,
          child: MouseRegion(
            cursor:
                bottom == null && right == null || top == null && left == null
                    ? SystemMouseCursors.resizeUpLeftDownRight
                    : SystemMouseCursors.resizeUpRightDownLeft,
            child: const SizedBox(height: 12, width: 12),
          ),
        ),
      );
}
