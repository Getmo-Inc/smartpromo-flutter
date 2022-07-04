import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPromo Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'SmartPromo Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  MethodChannel _smartPromo() {
    return MethodChannel('br.com.getmo.smartpromo');
  }
  
  Map _createConfig() {
    return {
      "campaign": "{campaignID}",
      "key": "{accessKey}",
      "secret": "{secretKey}",
      "color": "#18AC4F"
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

  void _scan() {
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
