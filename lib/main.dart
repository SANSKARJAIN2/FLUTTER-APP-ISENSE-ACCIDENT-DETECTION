import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:sensors/sensors.dart';
import 'dart:io';
//import 'package:isenseaccidentdetection/firebase_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ACCIDENT DETECTION APP",
      theme: ThemeData.dark(),
      home: GetLocationPage(),
    );
  }
}

class GetLocationPage extends StatefulWidget {
  @override
  GetLocationPageState createState() => GetLocationPageState();
}

class GetLocationPageState extends State<GetLocationPage> {
  @override
  /*void initState(){
    super.initState();
    new FirebaseNotifications().setUpFirebase();

  }*/
  var notifcationData;
  FirebaseMessaging _firebaseMessaging;
   String DeviceToken;
  void setUpFirebase() {
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) {
      print(token);
      DeviceToken = token;
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        print("setState function comming");
        setState(() {
          notifcationData = message;
          print("notification variable updated");
          //messageFromServer = notifcationData['notification'];
          updatemessage(message['notification']['body']);
          print("updatemessagefunction done");
        });

      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        print("setState function comming");
        setState(() {
          notifcationData = message;
          print("notification variable updated");
          //messageFromServer = notifcationData['notification'];
          updatemessage(message['notification']['body']);
          print("updatemessagefunction done");
        });

      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        print("setState function comming");
        setState(() {
          notifcationData = message;
          print("notification variable updated");
          //messageFromServer = notifcationData['notification'];
          updatemessage(message['notification']['body']);
          print("updatemessagefunction done");
        });

      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  TextEditingController _controller = TextEditingController();
  LocationData _locationDatavar;
  UserAccelerometerEvent acceleration;
  bool decide = true;
  http.Response response;
  String messageToShow = 'START ACCIDENT DETECTION FEATURE';
  String messageFromServer = "ACCIDENT DETECTION APP  \n  \t DRIVE SAFE, STAY SAFE";
//  final channel = IOWebSocketChannel.connect('ws://echo.websocket.org');

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("GPS"),
      ),
      body: _buildBody(),
    );
  }


  getrequest(double lat, double longitude) async {
    print("sending GET request");
    String url = "https://isensetest.herokuapp.com//accidentevent";
    url = url + "?lat=" + lat.toString() + "&longi=" + longitude.toString() + "&Token=" + DeviceToken.toString();
    if (decide) {
      http.Response response = await http.get(url);
      decide = false;
    }

    print(response.body);
  }

  //TextEditingController _controller = TextEditingController();

  updatemessage(String message){
    setState(() {
      messageFromServer = message;
    });

  print("message from server =======>>>>>>  $messageFromServer");
  }

  Widget _buildBody() {
    setUpFirebase();

    getGpslocation(false);
    return Padding(
      padding: const EdgeInsets.all(22.00),
      //child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(messageFromServer.toString()),


          Padding(
              padding: const EdgeInsets.all(20.00),
              child: RaisedButton(
                onPressed: () {
//_connectSocket01();
                  getGpslocation(false);
                  acceleration = deviceAcceleration();
                  messageToShow = "ACTIVATED";
                  print(_controller);
                },
                child: Text(messageToShow.toString())
              ))
        ],
      ),

    );



    //Text(messageFromServer.toString()),
  }
bool accidentDecide = true;
  deviceAcceleration() {
    //var listener;
    userAccelerometerEvents.listen((UserAccelerometerEvent event) async {
      //listener = event;
   print(event);

      if ((event.x.abs() > 2.00 ||
          event.y.abs() > 2.00 ||
          event.z.abs() > 2.00) && accidentDecide) {
        accidentDecide = false;
        print(decide);
        if (decide ??= true) {
          //getrequest(_locationDatavar.latitude, _locationDatavar.longitude);
          //decide = false;
          _neverSatisfied();
          accidentDetected().then((value) {
            getrequest(_locationDatavar.latitude, _locationDatavar.longitude);
            decide = false;
          }, onError: (error) {
            print(error);
          });

          setState(() {
            messageToShow =
            "accident detected, contacted the servers, help is on the way at you location";
          });
        }
      }
    });
  }
bool TokenRefresh = true;
  getGpslocation(bool wait) async {

  if(TokenRefresh){
    DeviceToken = await _firebaseMessaging.getToken();

    TokenRefresh = false;
    print('device token  == =======  $DeviceToken');
    print("\n");
    print('device token  == =======  $DeviceToken');

  }

    var _location = new Location();
    {
      setState(() {
        _location.onLocationChanged().listen((LocationData currentLocation) {
          _locationDatavar = currentLocation;
          //x = x+1;
        });
      });
    }
  }

  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ACCIDENT DETECTED !!!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                //Text('Accident detected'),
                Text('Tap within 10 seconds to cancel the HELP'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('call Isafe assist'),
              onPressed: () {
                setState(() {
                  messageToShow = 'RESTARTING THE ACCIDENT DETECTION MODULE, IT TAKES 10 SECONDS';
                });

                accidentDetected().then((value){
                  decide = true;
                  accidentDecide = true;
                  setState(() {
                    messageToShow = "ACTIVATED";
                  });
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("call now"),
              onPressed: () {
                getrequest(
                    _locationDatavar.latitude, _locationDatavar.longitude);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("cancel"),
              onPressed: () {
                decide = false;
                setState(() {
                  messageToShow = "RESTARING ACCIDENT DETECTION MODULE IT TAKES 10 SECONDS";
                });

                accidentDetected().then((value){
                  decide = true;
                  accidentDecide = true;
                  setState(() {
                    messageToShow = "ACTIVATED";
                  });
                });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> accidentDetected() async {
    await Future.delayed(Duration(seconds: 10));
  }


}


