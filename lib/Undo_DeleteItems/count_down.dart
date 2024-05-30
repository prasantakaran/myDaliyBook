// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:another_flushbar/flushbar.dart';

class CountDown extends StatefulWidget {
  const CountDown({super.key, required this.duration});
  final Duration duration;

  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  String get counterText {
    final Duration count = controller.duration! * controller.value;
    return count.inSeconds.toString();
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    controller.reverse(from: 1);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, index) {
          return Stack(
            children: [
              SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Colors.white,
                  value: controller.value,
                  strokeWidth: 2,
                ),
              ),
              Text(
                counterText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }
}

class Flushbars {
  static Flushbar undo({
    required String msg,
    required VoidCallback onUndo,
    required Duration duration,
  }) {
    return Flushbar<void>(
      messageText: Text(
        msg,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      icon: CountDown(duration: duration),
      backgroundColor: Colors.black,
      flushbarPosition: FlushbarPosition.BOTTOM,
      duration: duration,
      borderRadius: BorderRadius.circular(8),
      margin: EdgeInsets.all(8),
      mainButton: TextButton(
        onPressed: onUndo,
        child: Text('Undo'),
      ),
    );
  }
}
