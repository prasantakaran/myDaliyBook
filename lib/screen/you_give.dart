import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class YouGive extends StatefulWidget {
  const YouGive({super.key});

  @override
  State<YouGive> createState() => _YouGiveState();
}

class _YouGiveState extends State<YouGive> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('You will Give'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width * 0.50,
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width * 0.50,
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
