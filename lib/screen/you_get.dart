import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class YouGet extends StatefulWidget {
  const YouGet({super.key});

  @override
  State<YouGet> createState() => _YouGetState();
}

class _YouGetState extends State<YouGet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('You will Get'),
      ),
    );
  }
}
