import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            height: 150,
            width: 120,
            // decoration: BoxDecoration(
            //   color: Color.fromARGB(255, 126, 123, 123),
            //   borderRadius: BorderRadius.circular(10),
            // ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image.asset(
                //   "assets/images/grab.gif",
                //   height: 40,
                //   width: 40,
                // ),
                // CircularProgressIndicator(
                //     valueColor: AlwaysStoppedAnimation(Colors.blue)),
                SpinKitSpinningLines(
                  color: Colors.cyan,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Loading....",
                  style: TextStyle(fontSize: 8, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
