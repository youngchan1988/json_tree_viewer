import 'package:flutter/material.dart';
import 'package:json_tree_viewer/json_tree_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _expandedAll = false;
  final _toggleObject = <bool>[true, false];

  final _jsonArray = [
    {"message": "Hello world", "year": 2022},
    {"message": "你好世界", "year": 2022}
  ];

  final _jsonObject = <String, dynamic>{
    "message": ["你好世界", "Hello world"],
    "date": {"year": 2022, "month": 1, "day": 29},
    "cities": [
      {
        "name": "Beijing",
        "country": "China",
        "whereami": false,
      },
      {
        "name": "Shanghai",
        "country": "China",
        "whereami": true,
      },
      {"name": "Tokyo", "country": "Japan"}
    ]
  };
  dynamic _data;

  @override
  void initState() {
    _data = _jsonObject;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Json Viewer'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _expandedAll = true;
                      });
                    },
                    icon: Icon(Icons.unfold_more)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _expandedAll = false;
                      });
                    },
                    icon: Icon(Icons.unfold_less)),
                const SizedBox(
                  width: 16,
                ),
                ToggleButtons(
                  children: [Text('Object'), Text('Array')],
                  isSelected: _toggleObject,
                  onPressed: (index) {
                    setState(() {
                      _toggleObject.fillRange(0, _toggleObject.length, false);
                      _toggleObject[index] = true;
                      switch (index) {
                        case 0:
                          _data = _jsonObject;
                          break;
                        case 1:
                          _data = _jsonArray;
                          break;
                      }
                    });
                  },
                )
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: JsonTreeViewer(
                  data: _data,
                  expandedAll: _expandedAll,
                ),
              ),
            ),
          ],
        ));
  }
}
