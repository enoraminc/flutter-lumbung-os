import 'dart:async';

import 'package:flutter/material.dart';

import '../window/window.dart';
import 'desktop_app.dart';
import 'desktop_items.dart';
import 'dock.dart';

class Desktop extends StatefulWidget {
  const Desktop({
    required this.groupedApps,
    required this.standaloneApps,
    required this.backgroundImage,
    this.desktopBuilder,
    this.dockBuilder,
    super.key,
  });

  final Map<String, List<DesktopApp>> groupedApps;
  final List<DesktopApp> standaloneApps;

  final Widget Function(DesktopItems)? desktopBuilder;
  final Widget Function(Dock)? dockBuilder;

  final ImageProvider backgroundImage;

  @override
  State<Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> {
  var _shouldRebuild = false;
  final _windowKeys = <Key>[];
  final _minimizedWindowKeys = <Key>[];
  final _windows = <Key, Window>{};

  late StreamController<Key> _unHideWindowNotifier;

  @override
  void initState() {
    super.initState();
    _unHideWindowNotifier = StreamController<Key>.broadcast();
  }

  @override
  void dispose() {
    _unHideWindowNotifier.close();
    super.dispose();
  }

  void _bringToFront(Key key) {
    if (_windows.keys.last != key) {
      final window = _windows.remove(key);
      if (window != null) {
        _windows[key] = window;
        _shouldRebuild = true;
      }
    }
  }

  void _unMinimize(Key key) {
    if (_minimizedWindowKeys.contains(key)) {
      _unHideWindowNotifier.sink.add(key);
      _minimizedWindowKeys.remove(key);
      _shouldRebuild = true;
    }
    _bringToFront(key);
  }

  void _rebuildOnChange() {
    if (_shouldRebuild) {
      setState(() => _shouldRebuild = false);
    }
  }

  void _addWindow(
    DesktopApp desktopApp,
    double screenWidth,
    double screenHeight,
  ) {
    final key = UniqueKey();
    final window = Window(
      key: key,
      title: desktopApp.title,
      app: desktopApp.app,
      whenFocusRequested: () {
        _bringToFront(key);
        _rebuildOnChange();
      },
      onCloseTap: () => setState(() {
        _windowKeys.remove(key);
        _windows.remove(key);
      }),
      onMinimizeTap: () => setState(
        () => _minimizedWindowKeys.add(key),
      ),
      unHideWindowStream: _unHideWindowNotifier.stream,
      width: desktopApp.width,
      height: desktopApp.height,
      isFixedSize: desktopApp.isFixedSize,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );
    setState(() {
      _windowKeys.add(key);
      _windows[key] = window;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupedApps = widget.groupedApps;
    final standaloneApps = widget.standaloneApps;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: widget.backgroundImage,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final dekstopItems = DesktopItems(
              groupedApps: groupedApps,
              standaloneApps: standaloneApps,
              onItemTap: (desktopApp) => _addWindow(
                desktopApp,
                constraints.maxWidth,
                constraints.maxHeight,
              ),
            );
            final dock = Dock(
              windowKeys: _windowKeys,
              minimizedWindowKeys: _minimizedWindowKeys,
              windows: _windows,
              onItemTap: (key) {
                _unMinimize(key);
                _rebuildOnChange();
              },
            );
            return Stack(
              fit: StackFit.expand,
              children: [
                if (widget.desktopBuilder != null)
                  widget.desktopBuilder!(dekstopItems)
                else
                  dekstopItems,
                ..._windows.values,
                // if (_windows.isNotEmpty)
                if (widget.dockBuilder != null)
                  widget.dockBuilder!(dock)
                else
                  dock
              ],
            );
          }),
        ),
      ),
    );
  }
}
