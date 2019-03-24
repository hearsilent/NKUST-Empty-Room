import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_range_slider/flutter_range_slider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NKUST Empty Room',
      debugShowCheckedModeBanner: false,
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
      ),
      home: MyHomePage(title: 'NKUST Empty Room'),
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
  double _lowerValue = 0;
  double _upperValue = 14;

  var sections = [
    'M',
    '1',
    '2',
    '3',
    '4',
    'A',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13'
  ];

  var weekOfDayList = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  String weekOfDay = '星期一';

  var buildings;
  String building;
  Map<String, dynamic> buildingMap;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
          padding: new EdgeInsets.all(16.0),
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Center(
            child: Column(
              // Column is also layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[]
                ..add(
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: (MediaQuery.of(context).size.width - 48) / 2,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: weekOfDay,
                      onChanged: (String newValue) {
                        setState(() {
                          weekOfDay = newValue;
                        });
                      },
                      items: weekOfDayList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Container(
                    width: (MediaQuery.of(context).size.width - 48) / 2,
                    child: FutureBuilder(
                        future:
                            rootBundle.loadString('assets/nkust_classes.json'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState != ConnectionState.done)
                            return new Text('Loading...');

                          buildingMap = json.decode(snapshot.data.toString());
                          buildings = buildingMap.keys.toList();
                          if (building == null) {
                            building = buildings[0];
                          }

                          return DropdownButton<String>(
                            isExpanded: true,
                            value: building,
                            onChanged: (String newValue) {
                              setState(() {
                                building = newValue;
                              });
                            },
                            items: buildings
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          );
                        }),
                  ),
                ]))
                ..add(
                  RangeSlider(
                    min: 0,
                    max: 14,
                    lowerValue: _lowerValue,
                    upperValue: _upperValue,
                    divisions: 14,
                    showValueIndicator: true,
                    valueIndicatorMaxDecimals: 1,
                    valueIndicatorFormatter: (int index, double value) {
                      return sections[value.toInt() % sections.length];
                    },
                    onChanged: (double newLowerValue, double newUpperValue) {
                      setState(() {
                        _lowerValue = newLowerValue;
                        _upperValue = newUpperValue;
                      });
                    },
                  ),
                )
                ..add(
                  SizedBox(height: 8.0),
                )
                ..add(Container(
                  width: double.infinity,
                  height: 48,
                  child: RaisedButton(
                    child: Text('查詢'),
                    onPressed: () {
                      List rooms = new List();
                      for (int i = 0; i < buildingMap[building].length; i++) {
                        var room = buildingMap[building][i];
                        var classes =
                            room['classes'][weekOfDayList.indexOf(weekOfDay)];
                        bool isEmpty = true;
                        for (int j = _lowerValue.toInt();
                            j <= _upperValue.toInt();
                            j++) {
                          if (classes[j] == 0) {
                            isEmpty = false;
                            break;
                          }
                        }
                        if (isEmpty) {
                          rooms.add(room['name']);
                        }
                      }
                      if (rooms.length > 0) {
                        var buffer = new StringBuffer('滿足需求的教室如下：\n');
                        rooms.forEach((room) => buffer.write(room + "\n"));
                        showResultDialog(
                            context,
                            buffer
                                .toString()
                                .substring(0, buffer.toString().length - 1));
                      } else {
                        showResultDialog(context, '您選的範圍沒有滿足需求的教室！');
                      }
                    },
                  ),
                )),
            ),
          )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> showResultDialog(BuildContext context, String msg) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('查詢空堂'),
          content: Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text('朕知道了'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
