// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:lumbung_os/_extensions/build_context.dart';

import '../util/const.dart';
import 'desktop_app.dart';

class DesktopItems extends StatelessWidget {
  const DesktopItems({
    required this.groupedApps,
    required this.standaloneApps,
    required this.onItemTap,
    super.key,
  });
  // : assert(
  //         // TODO(albert): tests!
  //         groupedApps.length > 0 || standaloneApps.length > 0,
  //         'one should provide apps!',
  //       );

  final Map<String, List<DesktopApp>> groupedApps;
  final List<DesktopApp> standaloneApps;
  final ValueSetter<DesktopApp> onItemTap;

  @override
  Widget build(BuildContext context) =>
      (groupedApps.isEmpty && standaloneApps.isEmpty)
          ? const SizedBox()
          : _DesktopItems(
              isRtl: true,
              children: [
                ...groupedApps.entries
                    .map(
                      (entry) => DesktopApp(
                        entry.key,
                        Icons.folder,
                        _DesktopItems(
                          children: entry.value.map(
                            (desktopApp) => _DesktopItem(
                              desktopApp,
                              onTap: () => onItemTap(desktopApp),
                            ),
                          ),
                        ),
                      ),
                    )
                    .map(
                      (desktopApp) => _DesktopItem(
                        desktopApp,
                        onTap: () => onItemTap(desktopApp),
                      ),
                    ),
                ...standaloneApps.map(
                  (desktopApp) => _DesktopItem(
                    desktopApp,
                    onTap: () => onItemTap(desktopApp),
                  ),
                ),
              ],
            );
}

class _DesktopItems extends StatelessWidget {
  const _DesktopItems({
    Key? key,
    required this.children,
    this.isRtl = false,
  }) : super(key: key);

  final Iterable<Widget> children;

  final bool isRtl;

  @override
  Widget build(BuildContext context) => Container(
        height: double.infinity,
        padding: const EdgeInsets.all(desktopItemSpacing),
        // color: Colors.red,
        child: Wrap(
          spacing: desktopItemSpacing,
          runSpacing: desktopItemSpacing,
          textDirection: isRtl ? TextDirection.rtl : null,
          direction: isRtl ? Axis.vertical : Axis.horizontal,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [...children],
        ),
      );
}

class _DesktopItem extends StatelessWidget {
  const _DesktopItem(
    this.desktopApp, {
    required this.onTap,
  });

  final DesktopApp desktopApp;
  final VoidCallback onTap;

  Key get _itemKey => Key(desktopApp.title.toLowerCase().split(' ').join('-'));

  @override
  Widget build(BuildContext context) => GestureDetector(
        key: _itemKey,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 80,
            height: 80,
            // color: Colors.blue,
            constraints: const BoxConstraints(
              maxWidth: 80,
              maxHeight: 80,
            ),
            child: Column(
              children: [
                Icon(
                  desktopApp.icon,
                  color: Colors.lightBlue,
                  size: desktopIconSize,
                ),
                Text(
                  desktopApp.title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: context.tt.bodyMedium?.copyWith(
                    shadows: const [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 6,
                      ),
                    ],
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
