// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class TextApp extends StatefulWidget {
  const TextApp({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  State<TextApp> createState() => _TextAppState();
}

class _TextAppState extends State<TextApp> {
  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          widget.text,
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
          ),
        ),
      );
}
