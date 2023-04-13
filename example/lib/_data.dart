import 'package:flutter/material.dart' show Icons;

import 'package:lumbung_os/lumbung_os.dart';

import 'screen/auto_count.dart';
import 'screen/calculator.dart';
import 'screen/manual_count.dart';

const groupedApps = <String, List<DesktopApp>>{
  // 'Games': [
  //   DesktopApp(
  //     'TikTakToe',
  //     Icons.insert_drive_file,
  //     TikTakToe(),
  //   ),
  // ],
  // 'Misc': [
  //   DesktopApp(
  //     'Some Split View',
  //     Icons.insert_drive_file,
  //     SomeSplitView(),
  //   ),
  //   DesktopApp(
  //     'Some Grid View',
  //     Icons.insert_drive_file,
  //     SomeGridView(),
  //   ),
  // ],
};

const standaloneApps = <DesktopApp>[
  DesktopApp(
    'Auto Counter',
    Icons.insert_drive_file,
    AutoCount(),
  ),
  DesktopApp(
    'Manual Counter',
    Icons.insert_drive_file,
    ManualCount(),
  ),
  DesktopApp(
    'Calculator',
    Icons.insert_drive_file,
    Calculator(),
    width: 234,
    height: 330,
    isFixedSize: true,
  ),
];
