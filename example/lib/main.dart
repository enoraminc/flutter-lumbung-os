import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:lumbung_os/lumbung_os.dart';

import '_data.dart';
import '_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await precache(mainBackgroundImage);

  runZonedGuarded<void>(
    () => runApp(const _App()),
    (error, stack) => log(
      'Some explosion here...',
      error: error,
      stackTrace: stack,
    ),
  );
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'Lumbung OS',
        home: Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: mainBackgroundImage,
              ),
            ),
            child: SafeArea(
              child: Desktop(
                groupedApps: groupedApps,
                standaloneApps: standaloneApps,
              ),
            ),
          ),
        ),
      );
}
