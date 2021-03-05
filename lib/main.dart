import 'dart:convert';

import 'package:flutter/material.dart';
import 'mixin.dart';
import 'package:postgrest/postgrest.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html';

void main() {
  runApp(MyApp());
}

List<String> items = ['1', '2', '3 4'];

void routeNames(BuildContext context, String name) {
  switch (name) {
    case '1':
      Navigator.popAndPushNamed(context, '/1');
      break;
    case '2':
      Navigator.popAndPushNamed(context, '/2');
      break;
    case '3 4':
      Navigator.popAndPushNamed(context, '/');
      break;
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
        actions: returnNavBarList(context, items, routeNames),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Launch screen'),
          onPressed: () {
            // Navigate to the second screen when tapped.
            Navigator.pushNamed(context, '/second');
          },
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Second Screen"),
          actions: returnNavBarList(context, items, routeNames)),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first screen when tapped.

            Navigator.pushNamed(context, '/a');
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jens Kapitza',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => FirstScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/1': (context) => SecondScreen(),
        '/2': (context) => MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

var container = Container(
  // grey box
  child: Text(
    "Lorem ipsum",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w900,
      fontFamily: "Georgia",
    ),
  ),
  width: 320,
  margin: EdgeInsets.all(100),
  height: 240,
  color: Colors.grey[300],
);

class Album {
  final int a;
  final String b;

  Album({this.a, this.b});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      a: json['a'],
      b: json['b'],
    );
  }
}

Future<Album> fetchAlbum() async {
  final response = await http
      .get('http://localhost:3000/test?select=%2A&order=%22a%22.desc');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body)[0]);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  //Loading counter value on start
  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt('counter') ?? 0);
    });
  }

  //Incrementing counter after click
  _incrementCounter2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt('counter') ?? 0) + 1;
      prefs.setInt('counter', _counter);

      var url = 'http://localhost:3000';
      var client = PostgrestClient(url);

      var response = client
          .from('test')
          .insert([
            {'a': 100 + _counter, 'b': '11 $_counter ONLINE'}
          ])
          .execute()
          .whenComplete(() {
            setState(() {
              futureAlbum = fetchAlbum();
            });
          });
    });
  }

  int _counter;

  Widget rootW = null;
  var futureAlbum = fetchAlbum();
  String title = "test";
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _incrementCounter2();

/*
      response.whenComplete(() {
        response = client.from('test').select().order('a').execute();

        //print(response.toJson());
        response.then((value) {
          print(value.toJson()['data'][0]);

          title = (value.toJson()['data'][0]['a']).toString();
        });
      });

      */

      final pdf = pw.Document();

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text("Hello World dast ist ein test  $_counter"),
            ); // Center
          })); // Page

      var uint = pdf.save();
/*
      uint.then((value) {
        final blob = Blob([value], 'application/pdf');
        AnchorElement(
          href: Url.createObjectUrlFromBlob(blob).toString(),
        )
          ..setAttribute("download", "data.pdf")
          ..click();
      });

      */
    });
  }

  void _delCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
/*
      webFile.InputElement uploadInput = webFile.FileUploadInputElement();

      uploadInput.onChange.listen((e) {
        // read file content as dataURL
        final files = uploadInput.files;
        if (files.length == 1) {
          final file = files[0];
          webFile.FileReader reader = webFile.FileReader();

          reader.onLoadEnd.listen((e) {
            setState(() {
              title = reader.result;
            });
          });

          reader.onError.listen((fileEvent) {
            setState(() {
              title = "Some Error occured while reading the file";
            });
          });

          reader.readAsText(file);
        }
      });

      uploadInput.click();
      */
    });
  }

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
        title: Text(title),
        actions: returnNavBarList(context, items, routeNames),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
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
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            if (_counter % 2 == 0) container,
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            FutureBuilder<Album>(
              future: futureAlbum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.b);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        child: Row(
          children: [
            FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: _delCounter,
              tooltip: 'Increment222',
              child: Icon(Icons.delete),
            ),
          ],
        ),
        margin: EdgeInsets.all(50),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
