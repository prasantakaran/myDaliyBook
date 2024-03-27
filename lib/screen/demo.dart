import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.green,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.check_circle, color: Colors.white, size: 100.0),
              Text('Payment successful',
                  style: TextStyle(color: Colors.white, fontSize: 24.0)),
              Text('₹1,200',
                  style: TextStyle(color: Colors.white, fontSize: 48.0)),
              SizedBox(height: 50.0),
              Container(
                color: Colors.grey[800],
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Text('Prasanta', style: TextStyle(color: Colors.white)),
                    Text('Nov 24, 2023 | 08:52 PM',
                        style: TextStyle(color: Colors.white)),
                    Text('Card | pay_N4MJjtNkZfyPpb',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
