import 'package:flutter/material.dart';

import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }


  var _random = new math.Random();

  double _posX = 100;
  double _posY = 100;

  double _dx = 0;
  double _dy = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 10.0,
            left: 10.0,
            width: 100.0,
            height: 100.0,
            child: panel('FIX'),
          ),
          Positioned(
            top: _random.nextDouble() * 300,
            left: _random.nextDouble() * 100,
            width: 100,
            height: 100,
            child: panel('RANDOM'),
          ),
          GestureDetector(
            onVerticalDragStart:(/* DragStartDetails */ details) {
              print("onVerticalDragStart local dx:${details.localPosition.dx} dy:${details.localPosition.dy} global dx:${details.globalPosition.dx} dy:${details.globalPosition.dy}");

              _dx = details.globalPosition.dx;
              _dy = details.globalPosition.dy;
            },
            onVerticalDragUpdate:(DragUpdateDetails details){
              print("onVerticalDragUpdate local dx:${details.localPosition.dx} dy:${details.localPosition.dy} global dx:${details.globalPosition.dx} dy:${details.globalPosition.dy}");
              setState(() {
                _posX = _posX + (details.globalPosition.dx - _dx);
                _posY = _posY + (details.globalPosition.dy - _dy);
              });
              _dx = details.globalPosition.dx;
              _dy = details.globalPosition.dy;
            },
            onVerticalDragEnd:(/* DragStartDetails */ details) {
              print("onVerticalDragEnd");
            },
            onTap: () {
            },
            child : Stack(
              children: [
                _movePanel(_posX , _posY , "Draggable"),
              ],
            )
          ),

        ]
      ),
    );
  }

  Widget _movePanel(double x , double y, String labelText) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: x,
          top: y,
          width: 100.0,
          height: 100.0,
          child: Container(color: Colors.indigo,
              child:Card(
                color: Colors.blue,
                child: Center(
                  child: Text(labelText),
                ),
              )),
        ),
      ],
    );
  }

  Widget panel(String labelText) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1.0,
            blurRadius: 10.0,
            offset: Offset(10, 10),
          ),
        ],
      ),
      width: 200.0,
      height: 100.0,
      child: Card(
        color: Colors.blue,
        child: Center(
          child: Text(labelText),
        ),
      ),
    );
  }

}
