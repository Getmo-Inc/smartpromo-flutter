import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MethodChannel _smartPromo() {
    return MethodChannel('br.com.getmo.smartpromo');
  }

  Map _createConfig() {
    return {
      "campaign": "E3F3BBEABC8344FB",
      "key": "QXS7TR2M3KQF2A9G",
      "secret":
          "gRXdR9aV4QxpXBarMq6G9rsz25MwkdryKU2mShYJkaPstguV7QnN6YPJ8CUytL97",
      "color": "#18AC4F",
      "isHomolog": true
    };
  }

  Map _createConsumer() {
    return {
      "cpf": "23365159037",
      "name": "Consumer Name",
      "email": "mail@mail.com",
      "phone": "51999999999",
      "birthday": "2000-12-31",
      "gender": "F", // M, F, NB, NI
      "address": {
        "streetName": "Rua A",
        "streetNumber": "100",
        "complement": "Apto 200",
        "neighborhood": "Partenon",
        "city": "Porto Alegre",
        "state": "RS",
        "zipCode": "91530060",
      }
    };
  }

  void _go() {
    var config = _createConfig();
    config["consumer"] = _createConsumer();
    _smartPromo().invokeMethod('go', config);
  }

  void _scan() async {
    var config = _createConfig();
    config["consumerID"] = "23365159037";
    _smartPromo().invokeMethod('scan', config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            width: double.infinity,
            child: TextButton(
              child: Text('Go'),
              onPressed: _go,
            ),
          )),
          Expanded(
              child: Container(
            width: double.infinity,
            child: TextButton(
              child: Text('Scan'),
              onPressed: _scan,
            ),
          )),
        ],
      ),
    );
  }
}
