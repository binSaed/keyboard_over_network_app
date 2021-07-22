import 'package:api_manger/api_manger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Keyboard over network'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, @required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Button(keyName: 'up'),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(keyName: 'left'),
                Button(keyName: 'space'),
                Button(keyName: 'right'),
              ],
            ),
            SizedBox(height: 32),
            Button(keyName: 'down'),
          ],
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({Key key, @required this.keyName}) : super(key: key);
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 60,
      child: ElevatedButton(
          onPressed: () => sendKeyEventToApi(keyName),
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          )),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              keyName,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          )),
    );
  }
}

final apiManager = ApiManager(
  Dio(BaseOptions(
    baseUrl: 'http://192.168.1.4:3000/',
  )),
  defaultErrorMessage: () => 'error',
  networkErrorMessage: () => 'network_error_message',
  errorGeneralParser: (dynamic body) => body['message'],
  getUserToken: () => '',
  onNetworkChanged: (bool connected) {
    showToast(
        message: (connected ? 'back_online' : 'no_internet_connection'),
        backgroundColor: connected ? Colors.green : Colors.red);
  },
  isDevelopment: true,
);

Future<void> sendKeyEventToApi(String keyCode) async {
  final req = await apiManager.post<String>(
    '/api/Keyboard/event',
    (body) => body['message'],
    postBody: <String, dynamic>{'keyCode': keyCode},
  );
  if (req.status == ApiStatus.SUCCESS) return showToast(message: req.data);

  showToast(message: req.error, backgroundColor: Colors.red);
}

void showToast(
    {@required String message, Color backgroundColor = Colors.black}) {
  if (message?.isEmpty ?? true) return;
  HapticFeedback
      .lightImpact(); //light vibration to let the user focus on what happened
  Fluttertoast.cancel(); //remove old toasts
  Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0);
}
